package com.FarmersMK.mtnmobilemoney.controller;

import com.FarmersMK.mtnmobilemoney.dto.MTNTransactionRequest;
import com.FarmersMK.mtnmobilemoney.model.MTNTransaction;
import com.FarmersMK.mtnmobilemoney.service.MTNService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/mtn")
public class MTNController {

    private final MTNService mtnService;

    // ✅ FIX: constructor injection
    public MTNController(MTNService mtnService) {
        this.mtnService = mtnService;
    }

    @PostMapping
    public MTNTransaction create(@RequestBody MTNTransactionRequest request) {
        return mtnService.createTransaction(request);
    }

    @GetMapping
    public List<MTNTransaction> getAll() {
        return mtnService.getAllTransactions();
    }
}