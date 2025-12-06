package com.pe.fisi.sw.cooperApp.security.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OAuthToken {
    private String id;
    private String accessToken;
    private String refreshToken;
    private Instant expiresAt;
    private Instant createdAt;
    private Instant updatedAt;
    
    /**
     * Comprueba si el token de acceso ha expirado
     */
    public boolean isAccessTokenExpired() {
        if (expiresAt == null) {
            return true;
        }
        // Considerar expirado si quedan menos de 5 minutos
        return Instant.now().isAfter(expiresAt.minusSeconds(300));
    }
    
    /**
     * Actualiza el token de acceso y su fecha de expiración
     */
    public void updateAccessToken(String newAccessToken, long expiresInSeconds) {
        this.accessToken = newAccessToken;
        this.expiresAt = Instant.now().plusSeconds(expiresInSeconds);
        this.updatedAt = Instant.now();
    }
}
