package com.r99.r99_shop_api.module.cachetest;

import com.r99.r99_shop_api.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;
import com.r99.r99_shop_api.common.security.Perm;

@RestController
@RequestMapping("/api/v1/cache-test")
@RequiredArgsConstructor
public class CacheTestController {

    private final CacheTestService cacheTestService;

    /**
     * First call for a key: ~2000ms (computed). Repeat calls: a few ms (served from Redis).
     */
    @GetMapping("/{key}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> get(@PathVariable String key) {
        long start = System.currentTimeMillis();
        Map<String, Object> value = cacheTestService.getValue(key);
        long elapsed = System.currentTimeMillis() - start;

        Map<String, Object> body = new LinkedHashMap<>(value);
        body.put("response_time_ms", elapsed);
        body.put("served_from_cache", elapsed < 500);
        return ResponseEntity.ok(ApiResponse.success(body));
    }

    @DeleteMapping("/{key}")
    public ResponseEntity<ApiResponse<String>> evict(@PathVariable String key) {
        cacheTestService.evict(key);
        return ResponseEntity.ok(ApiResponse.success("Evicted cache for key: " + key));
    }
}
