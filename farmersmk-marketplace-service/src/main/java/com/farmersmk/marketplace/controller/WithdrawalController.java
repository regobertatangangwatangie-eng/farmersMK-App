package com.farmersmk.marketplace.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.math.BigDecimal;

@RestController
@RequestMapping("/api/withdrawals")
public class WithdrawalController {
    @PostMapping("/request")
    public String requestWithdrawal(
            @RequestParam Long sellerId,
            @RequestParam BigDecimal amount,
            @RequestParam MultipartFile goodsPhoto,
            @RequestParam MultipartFile transitDoc,
            @RequestParam MultipartFile companyRegDoc,
            @RequestParam String managerContact
    ) {
        // TODO: Save withdrawal request, store files, set status to pending review
        return "Withdrawal request submitted and pending review.";
    }
}
