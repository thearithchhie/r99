package com.r99.r99_shop_api.common.security;

public final class Perm {

    private Perm() {}

    public static final class Module {
        public static final String USER             = "USER";
        public static final String ROLE             = "ROLE";
        public static final String PERMISSION       = "PERMISSION";
        public static final String CUSTOMER         = "CUSTOMER";
        public static final String PRODUCT          = "PRODUCT";
        public static final String PRODUCT_CATEGORY = "PRODUCT_CATEGORY";
        public static final String PRODUCT_LINE     = "PRODUCT_LINE";
        public static final String PRODUCT_MODEL    = "PRODUCT_MODEL";
        public static final String ORDER            = "ORDER";
        public static final String STOCK            = "STOCK";
        public static final String DELIVERY         = "DELIVERY";
        public static final String DRIVER           = "DRIVER";
        public static final String COMMISSION       = "COMMISSION";
        public static final String SUPPLIER         = "SUPPLIER";
        public static final String PURCHASE         = "PURCHASE";
        public static final String EXPENSE          = "EXPENSE";
        public static final String EXPENSE_CATEGORY = "EXPENSE_CATEGORY";
        public static final String MEDIA            = "MEDIA";
        public static final String AUDIT_LOG        = "AUDIT_LOG";
        public static final String PAYROLL          = "PAYROLL";
        public static final String PRINT            = "PRINT";
    }

    public static final class Action {
        public static final String CREATE = "create";
        public static final String READ   = "read";
        public static final String UPDATE = "update";
        public static final String DELETE = "delete";
    }
}
