package com.FarmersMK.visacard.controller;

import com.FarmersMK.visacard.dto.VISAcardTransactionRequest;
import com.FarmersMK.visacard.model.VISAcardTransaction;
import com.FarmersMK.visacard.service.VISAcardService;
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