package com.FarmersMK.mastercard.controller;

import com.FarmersMK.mastercard.dto.MastercardTransactionRequest;
import com.FarmersMK.mastercard.model.MastercardTransaction;
import com.FarmersMK.mastercard.service.MastercardService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mastercard")
public class MastercardController {

    private final MastercardService service;

    public MastercardController(MastercardService service) {
        this.service = service;
    }

    @PostMapping("/pay")
    public MastercardTransaction pay(@RequestBody MastercardTransactionRequest request) {
        return service.processTransaction(request);
    }
}