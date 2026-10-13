package com.r99.r99_shop_api.module.print.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/print")
@RequiredArgsConstructor
public class PrintRestController {

    private final SimpMessagingTemplate messaging;

    @PostMapping(value = "/push", consumes = "application/json")
    public ResponseEntity<ApiResponse<String>> push(@RequestBody String rawJson) {
        messaging.convertAndSend("/topic/print", rawJson);
        return ResponseEntity.ok(ApiResponse.success("Print job sent"));
    }
}
