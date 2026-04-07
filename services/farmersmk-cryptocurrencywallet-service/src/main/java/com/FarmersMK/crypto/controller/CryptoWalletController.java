package com.FarmersMK.crypto.controller;

import com.FarmersMK.crypto.dto.CryptoTransactionRequest;
import com.FarmersMK.crypto.model.CryptoTransaction;
import com.FarmersMK.crypto.service.CryptoWalletService;
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