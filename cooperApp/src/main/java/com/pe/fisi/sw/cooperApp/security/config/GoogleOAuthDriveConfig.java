package com.pe.fisi.sw.cooperApp.security.config;

import com.pe.fisi.sw.cooperApp.security.service.OAuthTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "google.drive.auth-type", havingValue = "oauth", matchIfMissing = false)
@RequiredArgsConstructor
@Slf4j
public class GoogleOAuthDriveConfig {

    private final OAuthTokenService oAuthTokenService;
    
    /**
     * Servicio reactivo que proporciona un Drive client con credenciales OAuth actualizadas
     */
    @Bean
    public GoogleOAuthDriveService googleOAuthDriveService() {
        log.info("Inicializando Google Drive con OAuth");
        return new GoogleOAuthDriveService(oAuthTokenService);
    }
}
