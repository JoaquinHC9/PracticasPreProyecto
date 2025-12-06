package com.pe.fisi.sw.cooperApp.security.config;

import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.drive.Drive;
import com.google.auth.http.HttpCredentialsAdapter;
import com.pe.fisi.sw.cooperApp.security.service.OAuthTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

/**
 * Servicio que proporciona un Drive client con credenciales OAuth actualizadas dinámicamente
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GoogleOAuthDriveService {
    
    private final OAuthTokenService oAuthTokenService;
    private static final String APPLICATION_NAME = "cooperApp";
    
    /**
     * Obtiene un Drive client con credenciales OAuth válidas (y refrescadas si es necesario)
     */
    public Mono<Drive> getDriveClient() {
        return oAuthTokenService.getGoogleCredentials()
                .map(googleCredentials -> new Drive.Builder(
                        new NetHttpTransport(),
                        GsonFactory.getDefaultInstance(),
                        new HttpCredentialsAdapter(googleCredentials))
                        .setApplicationName(APPLICATION_NAME)
                        .build())
                .doOnSuccess(drive -> log.debug("Drive client creado con credenciales OAuth"))
                .doOnError(error -> log.error("Error creando Drive client: {}", error.getMessage()));
    }
}
