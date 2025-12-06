package com.pe.fisi.sw.cooperApp.files.service;

import com.google.api.client.http.FileContent;
import com.google.api.services.drive.Drive;
import com.pe.fisi.sw.cooperApp.security.config.GoogleOAuthDriveService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(name = "google.drive.auth-type", havingValue = "oauth", matchIfMissing = false)
public class GoogleDriveFileService {
    private final GoogleOAuthDriveService googleOAuthDriveService;

    /**
     * Sube los archivos a la carpeta especificada de forma REACTIVA
     */
    public Mono<List<String>> uploadFilesToFolderReactive(List<File> files, String folderId) {
        return Flux.fromIterable(files)
                .flatMap(file -> uploadSingleFileReactive(file, folderId))
                .collectList()
                .doOnNext(urls -> log.debug("Todos los archivos subidos exitosamente"))
                .doOnError(error -> log.error("Error subiendo archivos: {}", error.getMessage()));
    }

    /**
     * Sube un archivo individual de forma REACTIVA
     */
    private Mono<String> uploadSingleFileReactive(File file, String folderId) {
        return Mono.just(file)
                .flatMap(f -> {
                    if (!f.exists() || !f.canRead()) {
                        return Mono.error(new IOException("No se puede leer el archivo: " + f.getAbsolutePath()));
                    }
                    return Mono.just(f);
                })
                .flatMap(f -> googleOAuthDriveService.getDriveClient()
                        .flatMap(driveService -> Mono.fromCallable(() -> {
                            com.google.api.services.drive.model.File fileMetadata =
                                    new com.google.api.services.drive.model.File();
                            String fileName = addTimestampToFileName(f.getName());
                            fileMetadata.setName(fileName);
                            fileMetadata.setParents(Collections.singletonList(folderId));

                            FileContent mediaContent = new FileContent(getMimeType(f), f);

                            com.google.api.services.drive.model.File uploadedFile = driveService.files()
                                    .create(fileMetadata, mediaContent)
                                    .setFields("id")
                                    .execute();

                            makeFilePublic(driveService, uploadedFile.getId());
                            String fileUrl = generateFileUrl(uploadedFile.getId());

                            log.debug("Archivo subido: {} -> {}", f.getName(), fileUrl);
                            return fileUrl;
                        })));
    }

    /**
     * Sube los archivos a la carpeta especificada (SÍNCRONO - legacy)
     */
    public List<String> uploadFilesToFolder(List<java.io.File> files, String folderId) throws IOException {
        List<String> urls = new ArrayList<>();

        for (java.io.File file : files) {
            if (!file.exists() || !file.canRead()) {
                throw new IOException("No se puede leer el archivo: " + file.getAbsolutePath());
            }

            String fileUrl = uploadSingleFile(file, folderId);
            urls.add(fileUrl);

            log.debug("Archivo subido: {} -> {}", file.getName(), fileUrl);
        }

        return urls;
    }

    /**
     * Sube un archivo individual a Google Drive (SÍNCRONO - legacy)
     */
    public String uploadSingleFile(java.io.File file, String folderId) throws IOException {
        com.google.api.services.drive.model.File fileMetadata = new com.google.api.services.drive.model.File();
        // Agregar timestamp al nombre del archivo para evitar conflictos
        String fileName = addTimestampToFileName(file.getName());
        fileMetadata.setName(fileName);
        fileMetadata.setParents(Collections.singletonList(folderId));

        FileContent mediaContent = new FileContent(getMimeType(file), file);

        com.google.api.services.drive.model.File uploadedFile = null;
        try {
            throw new IOException("Modo legacy no soportado en OAuth. Usa uploadSingleFileReactive");
        } catch (IOException e) {
            log.error("Error subiendo archivo: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Hace un archivo público para que cualquiera con el enlace pueda verlo
     */
    private void makeFilePublic(Drive driveService, String fileId) throws IOException {
        com.google.api.services.drive.model.Permission permission =
                new com.google.api.services.drive.model.Permission()
                        .setType("anyone")
                        .setRole("reader");

        driveService.permissions()
                .create(fileId, permission)
                .execute();

        log.debug("Archivo {} configurado como público", fileId);
    }


    /**
     * Genera la URL de visualización del archivo en Google Drive
     */
    public String generateFileUrl(String fileId) {
        return String.format("https://drive.google.com/file/d/%s/view", fileId);
    }

    /**
     * Detecta el tipo MIME del archivo
     */
    public String getMimeType(java.io.File file) {
        try {
            String mimeType = java.nio.file.Files.probeContentType(file.toPath());
            return mimeType != null ? mimeType : "application/octet-stream";
        } catch (IOException e) {
            log.warn("No se pudo determinar el tipo MIME para: {}", file.getName());
            return "application/octet-stream";
        }
    }

    /**
     * Agrega timestamp al nombre del archivo para evitar conflictos
     */
    public String addTimestampToFileName(String originalName) {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));

        int lastDotIndex = originalName.lastIndexOf('.');
        if (lastDotIndex == -1) {
            return originalName + "_" + timestamp;
        }

        String nameWithoutExtension = originalName.substring(0, lastDotIndex);
        String extension = originalName.substring(lastDotIndex);
        return nameWithoutExtension + "_" + timestamp + extension;
    }
}
