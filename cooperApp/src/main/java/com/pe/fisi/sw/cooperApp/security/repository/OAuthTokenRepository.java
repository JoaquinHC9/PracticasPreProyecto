package com.pe.fisi.sw.cooperApp.security.repository;

import com.pe.fisi.sw.cooperApp.security.model.OAuthToken;
import reactor.core.publisher.Mono;

public interface OAuthTokenRepository {
    Mono<OAuthToken> findLatestToken();
    Mono<OAuthToken> saveToken(OAuthToken token);
    Mono<Void> deleteAll();
}
