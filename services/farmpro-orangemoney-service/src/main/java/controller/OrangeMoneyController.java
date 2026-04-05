package com.farmpro.orangemoney.controller;

import com.farmpro.orangemoney.dto.OrangeTransactionRequest;
import com.farmpro.orangemoney.model.OrangeTransaction;
import com.farmpro.orangemoney.service.OrangeMoneyService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orangemoney")
public class OrangeMoneyController {

    private final OrangeMoneyService orangeMoneyService;

    public OrangeMoneyController(OrangeMoneyService orangeMoneyService) {
        this.orangeMoneyService = orangeMoneyService;
    }

    @PostMapping("/send")
    public ResponseEntity<OrangeTransaction> sendMoney(@RequestBody OrangeTransactionRequest request) {
        OrangeTransaction transaction = orangeMoneyService.sendMoney(request);
        return ResponseEntity.ok(transaction);
    }
}