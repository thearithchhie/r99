package com.r99.r99_shop_api.module.cachetest;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.io.Serializable;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Tiny service to prove Redis caching works end-to-end.
 * getValue() simulates expensive work (2s). The result is cached in Redis for 60s,
 * so the second call for the same key returns instantly with the SAME computedAt.
 */
@Service
public class CacheTestService {

    @Cacheable(value = "cacheTest", key = "#key")
    public Map<String, Object> getValue(String key) {
        try {
            Thread.sleep(2000); // simulate an expensive computation / DB call
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("key", key);
        result.put("computed_at", Instant.now().toString());
        result.put("note", "same computed_at on repeat calls = served from Redis");
        return result;
    }

    @CacheEvict(value = "cacheTest", key = "#key")
    public void evict(String key) {
        // Spring handles removal from Redis via the annotation
    }
}
