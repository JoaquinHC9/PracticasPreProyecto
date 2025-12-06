package com.pe.fisi.sw.cooperApp.security.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.store.MemoryDataStoreFactory;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.UserCredentials;
import com.pe.fisi.sw.cooperApp.security.exceptions.CustomException;
import com.pe.fisi.sw.cooperApp.security.model.OAuthToken;
import com.pe.fisi.sw.cooperApp.security.repository.OAuthTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.time.Instant;
import java.util.Collections;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthTokenService {

    private final OAuthTokenRepository tokenRepository;
    private static final String DRIVE_SCOPE = "https://www.googleapis.com/auth/drive";
    private static final String USER_ID = "cooperapp_user";

    @Value("${google.drive.redirect-uri}")
    private String redirectUri;

    private static final String CREDENTIALS_FILE = "/etc/secrets/client-secret.json";
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();

    /**
     * Intercambia un authorization code por access token y refresh token
     */
    public Mono<OAuthToken> exchangeCodeForToken(String authorizationCode) {
        return Mono.fromCallable(() -> {
            GoogleAuthorizationCodeFlow flow = createAuthorizationCodeFlow();

            try {
                var tokenResponse = flow
                        .newTokenRequest(authorizationCode)
                        .setRedirectUri(redirectUri)
                        .execute();

                OAuthToken token = OAuthToken.builder()
                        .id(USER_ID)
                        .accessToken(tokenResponse.getAccessToken())
                        .refreshToken(tokenResponse.getRefreshToken())
                        .expiresAt(Instant.now().plusSeconds(tokenResponse.getExpiresInSeconds()))
                        .createdAt(Instant.now())
                        .build();

                log.info("Authorization code intercambiado exitosamente");
                return token;
            } catch (IOException e) {
                log.error("Error intercambiando authorization code: {}", e.getMessage());
                throw new CustomException(HttpStatus.UNAUTHORIZED, "Error en autenticación OAuth: " + e.getMessage());
            }
        }).flatMap(tokenRepository::saveToken);
    }

    /**
     * Obtiene un token de acceso válido, refrescándolo si es necesario
     */
    public Mono<String> getValidAccessToken() {
        return tokenRepository.findLatestToken()
                .switchIfEmpty(Mono.error(new CustomException(HttpStatus.UNAUTHORIZED, "No hay token OAuth configurado. Autentícate primero.")))
                .flatMap(token -> {
                    if (!token.isAccessTokenExpired()) {
                        return Mono.just(token.getAccessToken());
                    }
                    return refreshAccessToken(token);
                });
    }

    /**
     * Refresca el access token usando el refresh token
     */
    private Mono<String> refreshAccessToken(OAuthToken token) {
        return Mono.fromCallable(() -> {
            GoogleAuthorizationCodeFlow flow = createAuthorizationCodeFlow();

            try {
                var tokenResponse = flow
                        .newTokenRequest(token.getRefreshToken())
                        .setRedirectUri(redirectUri)
                        .execute();

                token.updateAccessToken(tokenResponse.getAccessToken(), tokenResponse.getExpiresInSeconds());
                log.info("Access token refrescado exitosamente");
                return token;
            } catch (IOException e) {
                log.error("Error refrescando token: {}", e.getMessage());
                throw new CustomException(HttpStatus.UNAUTHORIZED, "Error refrescando token OAuth");
            }
        }).flatMap(refreshedToken -> tokenRepository.saveToken(refreshedToken)
                .thenReturn(refreshedToken.getAccessToken()));
    }

    /**
     * Obtiene las credenciales de Google usando el token almacenado
     */
    public Mono<GoogleCredentials> getGoogleCredentials() {
        return getValidAccessToken()
                .flatMap(accessToken -> Mono.fromCallable(() -> {
                    try (InputStream in = new FileInputStream(CREDENTIALS_FILE)) {
                        GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY, new InputStreamReader(in));

                        return UserCredentials.newBuilder()
                                .setClientId(clientSecrets.getDetails().getClientId())
                                .setClientSecret(clientSecrets.getDetails().getClientSecret())
                                .setAccessToken(com.google.auth.oauth2.AccessToken.newBuilder()
                                        .setTokenValue(accessToken)
                                        .setExpirationTime(new java.util.Date(System.currentTimeMillis() + 3600000))
                                        .build())
                                .build();
                    } catch (Exception e) {
                        log.error("Error creando GoogleCredentials: {}", e.getMessage());
                        throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, "Error creando credenciales");
                    }
                }));
    }

    /**
     * Crea el flujo de autorización OAuth 2.0
     */
    private GoogleAuthorizationCodeFlow createAuthorizationCodeFlow() throws IOException {
        try (InputStream in = new FileInputStream(CREDENTIALS_FILE)) {
            GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY, new InputStreamReader(in));

            return new GoogleAuthorizationCodeFlow.Builder(
                    new NetHttpTransport(),
                    JSON_FACTORY,
                    clientSecrets,
                    Collections.singletonList(DRIVE_SCOPE))
                    .setDataStoreFactory(MemoryDataStoreFactory.getDefaultInstance())
                    .build();
        }
    }

    /**
     * Obtiene la URL para iniciar el flujo OAuth
     */
    public String getAuthorizationUrl() throws IOException {
        GoogleAuthorizationCodeFlow flow = createAuthorizationCodeFlow();
        return flow.newAuthorizationUrl()
                .setRedirectUri(redirectUri)
                .build();
    }

    /**
     * Limpia los tokens almacenados
     */
    public Mono<Void> clearTokens() {
        return tokenRepository.deleteAll();
    }
}
