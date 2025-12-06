package com.pe.fisi.sw.cooperApp.files.service;

import com.google.api.services.drive.Drive;
import com.google.api.services.drive.model.File;
import com.pe.fisi.sw.cooperApp.security.config.GoogleOAuthDriveService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
@ConditionalOnProperty(name = "google.drive.auth-type", havingValue = "oauth", matchIfMissing = false)
public class DriveFolderService {
    private final GoogleOAuthDriveService googleOAuthDriveService;

    /**
     * Crea una subcarpeta en la carpeta raíz de la cuenta personal OAuth
     * Los archivos se guardarán en: My Drive > CooperApp > [cuentaUid_timestamp]
     */
    public Mono<String> createSubFolder(String cuentaUid) {
        return googleOAuthDriveService.getDriveClient()
                .flatMap(driveService -> Mono.fromCallable(() -> {
                    String subFolderName = generateFolderName(cuentaUid);
                    
                    // Primero, obtener o crear la carpeta raíz "CooperApp"
                    String cooperAppFolderId = getOrCreateCooperAppFolder(driveService);
                    
                    // Crear subcarpeta dentro de CooperApp
                    File folderMetadata = new File();
                    folderMetadata.setName(subFolderName);
                    folderMetadata.setMimeType("application/vnd.google-apps.folder");
                    folderMetadata.setParents(Collections.singletonList(cooperAppFolderId));
                    
                    File folder = driveService.files()
                            .create(folderMetadata)
                            .setFields("id")
                            .execute();
                    
                    log.debug("Subcarpeta creada en Google Drive: {} con ID: {}", subFolderName, folder.getId());
                    log.info("Carpeta de reporte creada: {} - Ver en: https://drive.google.com/drive/folders/{}", subFolderName, folder.getId());
                    return folder.getId();
                }));
    }
    
    /**
     * Obtiene el ID de la carpeta "CooperApp" o la crea si no existe
     */
    private String getOrCreateCooperAppFolder(Drive driveService) throws IOException {
        String cooperAppFolderName = "CooperApp";
        
        // Buscar si ya existe la carpeta CooperApp en My Drive
        com.google.api.services.drive.model.FileList result = driveService.files()
                .list()
                .setQ("name='" + cooperAppFolderName + "' and mimeType='application/vnd.google-apps.folder' and trashed=false")
                .setSpaces("drive")
                .setFields("files(id, name)")
                .setPageSize(1)
                .execute();
        
        if (result.getFiles() != null && !result.getFiles().isEmpty()) {
            String folderId = result.getFiles().get(0).getId();
            log.debug("Carpeta CooperApp encontrada con ID: {}", folderId);
            return folderId;
        }
        
        // Si no existe, crearla
        File folderMetadata = new File();
        folderMetadata.setName(cooperAppFolderName);
        folderMetadata.setMimeType("application/vnd.google-apps.folder");
        
        File folder = driveService.files()
                .create(folderMetadata)
                .setFields("id")
                .execute();
        
        log.info("Carpeta CooperApp creada con ID: {}", folder.getId());
        return folder.getId();
    }
    
    /**
     * Valida los parámetros de entrada
     */
    public void validateInputs(List<java.io.File> files, String cuentaUid) {
        if (files == null || files.isEmpty()) {
            throw new IllegalArgumentException("La lista de archivos no puede estar vacía");
        }

        if (cuentaUid == null || cuentaUid.trim().isEmpty()) {
            throw new IllegalArgumentException("El ID de cuenta no puede estar vacío");
        }

        // Validar que todos los archivos existan
        for (java.io.File file : files) {
            if (file == null) {
                throw new IllegalArgumentException("Uno de los archivos es null");
            }
            if (!file.exists()) {
                throw new IllegalArgumentException("El archivo no existe: " + file.getAbsolutePath());
            }
        }
    }

    /**
     * Genera el nombre de la subcarpeta basado en cuenta y timestamp
     */
    public String generateFolderName(String cuentaUid) {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        return String.format("report_%s_%s", cuentaUid, timestamp);
    }

}
