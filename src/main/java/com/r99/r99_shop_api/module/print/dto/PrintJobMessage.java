package com.r99.r99_shop_api.module.print.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class PrintJobMessage {
    private String type;  // "invoice" | "stickers"
    private Object data;
}
