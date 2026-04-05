package com.farmpro.mtnmobilemoney.service;

import com.farmpro.mtnmobilemoney.dto.MTNTransactionRequest;
import com.farmpro.mtnmobilemoney.model.MTNTransaction;
import com.farmpro.mtnmobilemoney.repository.MTNTransactionRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MTNService {

    private final MTNTransactionRepository repository;

    // ✅ CONSTRUCTOR INJECTION (FIXES YOUR ERROR)
    public MTNService(MTNTransactionRepository repository) {
        this.repository = repository;
    }

    public MTNTransaction createTransaction(MTNTransactionRequest request) {
        MTNTransaction transaction = new MTNTransaction();

        transaction.setPhoneNumber(request.getPhoneNumber());
        transaction.setAmount(request.getAmount());
        transaction.setDescription(request.getDescription());

        return repository.save(transaction);
    }

    public List<MTNTransaction> getAllTransactions() {
        return repository.findAll();
    }
}