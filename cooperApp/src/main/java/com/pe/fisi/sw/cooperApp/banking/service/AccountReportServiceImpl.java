package com.pe.fisi.sw.cooperApp.banking.service;

import com.pe.fisi.sw.cooperApp.banking.dto.ReportRequest;
import com.pe.fisi.sw.cooperApp.banking.repository.AccountRepository;
import com.pe.fisi.sw.cooperApp.files.service.GoogleUploadDriveService;
import com.pe.fisi.sw.cooperApp.notifications.model.NotificationEvent;
import com.pe.fisi.sw.cooperApp.notifications.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(name = "google.drive.auth-type", havingValue = "oauth", matchIfMissing = false)
public class AccountReportServiceImpl implements AccountReportService {
    private final AccountRepository repository;
    private final GoogleUploadDriveService uploader;
    private final NotificationService notificationService;
    
    @Override
    public Mono<NotificationEvent> reportAccount(ReportRequest request, List<FilePart> files) {
        return repository.getOwnerUidOfAccount(request.getCuentaUid())
                .flatMap(ownerUid ->
                        Flux.fromIterable(files)
                                .flatMap(filePart -> {
                                    // Guardar temporalmente cada archivo
                                    return Mono.fromCallable(() -> {
                                        java.io.File tempFile = java.io.File.createTempFile("upload-", filePart.filename());
                                        return tempFile;
                                    }).flatMap(tempFile ->
                                            filePart.transferTo(tempFile.toPath())
                                                    .thenReturn(tempFile)
                                    );
                                })
                                .collectList()
                                .flatMap(tempFiles -> {
                                    // Subir a Google Drive usando OAuth
                                    return uploader.uploadFilesReactive(tempFiles, request.getCuentaUid())
                                            .doFinally(signalType -> {
                                                // Eliminar archivos temporales
                                                tempFiles.forEach(java.io.File::delete);
                                            });
                                })
                                .flatMap(urlsConcatenadas ->
                                    notificationService.notifyAccountReport(
                                            request.getCuentaUid(),
                                            request.getReporterId(),
                                            ownerUid,
                                            request.getMotivo(),
                                            urlsConcatenadas
                                    )
                                )
                );
    }
}
