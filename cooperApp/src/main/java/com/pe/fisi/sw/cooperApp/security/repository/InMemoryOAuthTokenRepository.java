package com.pe.fisi.sw.cooperApp.security.repository;

import com.pe.fisi.sw.cooperApp.security.model.OAuthToken;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

@Repository
@Slf4j
public class InMemoryOAuthTokenRepository implements OAuthTokenRepository {
    
    private final ConcurrentHashMap<String, OAuthToken> tokenStore = new ConcurrentHashMap<>();
    
    @Override
    public Mono<OAuthToken> findLatestToken() {
        return Mono.fromCallable(() -> {
            OAuthToken token = tokenStore.values().stream()
                    .max((t1, t2) -> t1.getCreatedAt().compareTo(t2.getCreatedAt()))
                    .orElse(null);
            
            if (token == null) {
                log.warn("No se encontró token OAuth");
                return null;
            }
            
            return token;
        });
    }
    
    @Override
    public Mono<OAuthToken> saveToken(OAuthToken token) {
        return Mono.fromCallable(() -> {
            token.setUpdatedAt(Instant.now());
            tokenStore.put(token.getId(), token);
            log.info("Token almacenado en memoria");
            return token;
        });
    }
    
    @Override
    public Mono<Void> deleteAll() {
        return Mono.fromRunnable(() -> {
            tokenStore.clear();
            log.info("Todos los tokens eliminados");
        });
    }
}
