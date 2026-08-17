package com.r99.r99_shop_api.common.util;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

public class PageableUtil {

    public static final int DEFAULT_PAGE_SIZE = 10;
    private static final Sort DEFAULT_SORT = Sort.by(Sort.Direction.DESC, "id");

    public static Pageable withDefaultSort(Pageable pageable) {
        if (pageable.getSort().isUnsorted()) {
            return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), DEFAULT_SORT);
        }
        return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
                pageable.getSort().and(DEFAULT_SORT));
    }
}
