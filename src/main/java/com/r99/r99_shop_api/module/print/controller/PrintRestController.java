package com.r99.r99_shop_api.module.print.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.r99.r99_shop_api.common.security.Perm;

@RestController
@RequestMapping("/api/v1/print")
@RequiredArgsConstructor
public class PrintRestController {

    private final SimpMessagingTemplate messaging;

    @PostMapping(value = "/push", consumes = "application/json")
    @PreAuthorize("@perm.can('" + Perm.Module.PRINT + "', '" + Perm.Action.CREATE + "')")
    public ResponseEntity<ApiResponse<String>> push(@RequestBody String rawJson) {
        messaging.convertAndSend("/topic/print", rawJson);
        return ResponseEntity.ok(ApiResponse.success("Print job sent"));
    }
}
