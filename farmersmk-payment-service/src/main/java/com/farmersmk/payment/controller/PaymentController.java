package com.farmersmk.payment.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    @PostMapping("/negotiate")
    public ResponseEntity<String> negotiate(@RequestBody String negotiationDetails) {
        // TODO: Implement negotiation logic
        return ResponseEntity.ok("Negotiation started");
    }

    @PostMapping("/pay")
    public ResponseEntity<String> pay(@RequestBody PaymentRequest paymentRequest) {
        String method = paymentRequest.getMethod();
        switch (method.toLowerCase()) {
            case "mtn_mobile_money":
                // Integrate MTN Mobile Money payment logic here
                // Use phone number: +237675142175
                return ResponseEntity.ok("MTN Mobile Money payment processed to +237675142175");
            case "usdt":
                // Integrate USDT (TRC20) payment logic here
                // Use address: TVMsNvsMk22oguXnxmZHDBoFYP8LPHaWx3
                return ResponseEntity.ok("USDT (TRC20) payment processed to TVMsNvsMk22oguXnxmZHDBoFYP8LPHaWx3");
            case "master_card":
            case "visa_card":
            case "orange_money":
                // TODO: Integrate these payment methods in the future
                return ResponseEntity.ok("Integration for this payment method is coming soon.");
            default:
                return ResponseEntity.badRequest().body("Unsupported payment method");
        }
    }

    // DTO for payment request
    public static class PaymentRequest {
        private String method;
        private String details;

        public String getMethod() { return method; }
        public void setMethod(String method) { this.method = method; }
        public String getDetails() { return details; }
        public void setDetails(String details) { this.details = details; }
    }
}
