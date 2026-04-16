package com.farmersmk.marketplace.controller;

import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    @PostMapping("/pay")
    public String payToSystem(@RequestParam Long buyerId, @RequestParam Long sellerId, @RequestParam BigDecimal amount) {
        // 1% fee calculation
        BigDecimal fee = amount.multiply(new BigDecimal("0.01"));
        BigDecimal sellerAmount = amount.subtract(fee);
        // TODO: Save transaction, update balances
        return "Payment received. Fee: " + fee + ", Seller credited: " + sellerAmount;
    }
}
