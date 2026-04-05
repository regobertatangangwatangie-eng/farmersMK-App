package com.farmpro.mastercard.controller;

import com.farmpro.mastercard.dto.MastercardTransactionRequest;
import com.farmpro.mastercard.model.MastercardTransaction;
import com.farmpro.mastercard.service.MastercardService;
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