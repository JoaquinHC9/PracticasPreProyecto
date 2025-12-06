package com.pe.fisi.sw.cooperApp.security.controller;

import com.pe.fisi.sw.cooperApp.security.exceptions.CustomException;
import com.pe.fisi.sw.cooperApp.security.service.OAuthTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.io.IOException;

@RestController
@RequestMapping("/v1/oauth")
@RequiredArgsConstructor
@Slf4j
public class OAuthController {
    
    private final OAuthTokenService oAuthTokenService;
    
    /**
     * Redirige al usuario a Google para autenticarse
     * GET /v1/oauth/authorize
     */
    @GetMapping("/authorize")
    public Mono<ResponseEntity<String>> authorize() {
        return Mono.fromCallable(() -> {
            try {
                String authorizationUrl = oAuthTokenService.getAuthorizationUrl();
                log.info("URL de autorización generada");
                return ResponseEntity.ok(authorizationUrl);
            } catch (IOException e) {
                log.error("Error generando URL de autorización: {}", e.getMessage());
                throw new CustomException(HttpStatus.INTERNAL_SERVER_ERROR, "Error en autorización OAuth");
            }
        });
    }
    
    /**
     * Callback que recibe el authorization code de Google
     * GET /v1/oauth/callback?code=xxxxx
     */
    @GetMapping("/callback")
    public Mono<ResponseEntity<String>> handleCallback(@RequestParam String code) {
        log.info("Authorization code recibido");
        
        return oAuthTokenService.exchangeCodeForToken(code)
                .map(token -> {
                    log.info("Token almacenado exitosamente");
                    return ResponseEntity.ok("Autenticación exitosa. Tu cuenta Google está vinculada a CooperApp.");
                })
                .onErrorResume(error -> {
                    log.error("Error en callback OAuth: {}", error.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                            .body("Error en autenticación: " + error.getMessage()));
                });
    }
    
    /**
     * Limpia los tokens OAuth almacenados
     * POST /v1/oauth/logout
     */
    @PostMapping("/logout")
    public Mono<ResponseEntity<String>> logout() {
        return oAuthTokenService.clearTokens()
                .thenReturn(ResponseEntity.ok("Sesión OAuth cerrada"));
    }
    
    /**
     * Verifica si hay un token OAuth válido configurado
     * GET /v1/oauth/status
     */
    @GetMapping("/status")
    public Mono<ResponseEntity<String>> checkStatus() {
        return oAuthTokenService.getValidAccessToken()
                .map(token -> ResponseEntity.ok("Token OAuth válido configurado"))
                .onErrorResume(error -> 
                    Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                            .body("No hay token OAuth configurado. Ejecuta: GET /v1/oauth/authorize")));
    }
}
