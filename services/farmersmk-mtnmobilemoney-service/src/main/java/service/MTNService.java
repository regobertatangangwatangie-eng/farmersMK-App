package com.FarmersMK.mtnmobilemoney.service;

import com.FarmersMK.mtnmobilemoney.dto.MTNTransactionRequest;
import com.FarmersMK.mtnmobilemoney.model.MTNTransaction;
import com.FarmersMK.mtnmobilemoney.repository.MTNTransactionRepository;
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