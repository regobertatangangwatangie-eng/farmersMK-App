package com.farmpro.visacard.controller;

import com.farmpro.visacard.dto.VISAcardTransactionRequest;
import com.farmpro.visacard.model.VISAcardTransaction;
import com.farmpro.visacard.service.VISAcardService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/visacard")
public class VISAcardController {

    private final VISAcardService service;

    public VISAcardController(VISAcardService service) {
        this.service = service;
    }

    @PostMapping("/pay")
    public VISAcardTransaction pay(@RequestBody VISAcardTransactionRequest request) {
        return service.processTransaction(request);
    }
}