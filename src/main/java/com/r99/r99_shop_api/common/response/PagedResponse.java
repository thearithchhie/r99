package com.r99.r99_shop_api.common.response;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import org.springframework.data.domain.Page;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PagedResponse<T> {

    private final Map<String, Object> properties;

    private PagedResponse(String key, List<T> items, PageMeta meta) {
        this.properties = new LinkedHashMap<>();
        this.properties.put(key, items);
        this.properties.put("meta", meta);
    }

    @JsonAnyGetter
    public Map<String, Object> getProperties() {
        return properties;
    }

    public static <T> PagedResponse<T> of(Page<T> page, String key) {
        return new PagedResponse<>(key, page.getContent(), PageMeta.of(page));
    }
}
