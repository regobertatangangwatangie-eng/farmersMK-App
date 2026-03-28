package com.farmpro.crypto.controller;

import com.farmpro.crypto.dto.CryptoTransactionRequest;
import com.farmpro.crypto.model.CryptoTransaction;
import com.farmpro.crypto.service.CryptoWalletService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/crypto")
public class CryptoWalletController {

    private final CryptoWalletService service;

    public CryptoWalletController(CryptoWalletService service) {
        this.service = service;
    }

    @PostMapping("/transfer")
    public CryptoTransaction transfer(@RequestBody CryptoTransactionRequest request) {
        return service.processTransaction(request);
    }
}