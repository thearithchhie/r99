package com.r99.r99_shop_api.common.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.springframework.data.domain.Page;

@Getter
public class PageMeta {

    private final int page;

    @JsonProperty("per_page")
    private final int perPage;

    private final long total;

    @JsonProperty("total_pages")
    private final int totalPages;

    @JsonProperty("has_next")
    private final boolean hasNext;

    @JsonProperty("has_previous")
    private final boolean hasPrevious;

    private PageMeta(int page, int perPage, long total, int totalPages, boolean hasNext, boolean hasPrevious) {
        this.page = page;
        this.perPage = perPage;
        this.total = total;
        this.totalPages = totalPages;
        this.hasNext = hasNext;
        this.hasPrevious = hasPrevious;
    }

    public static PageMeta of(Page<?> page) {
        int currentPage = page.getNumber() + 1; // Spring is 0-based
        return new PageMeta(
                currentPage,
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.hasNext(),
                page.hasPrevious()
        );
    }
}
