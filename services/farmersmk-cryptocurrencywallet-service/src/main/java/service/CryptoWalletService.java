package com.FarmersMK.crypto.service;

import com.FarmersMK.crypto.dto.CryptoTransactionRequest;
import com.FarmersMK.crypto.model.CryptoTransaction;
import com.FarmersMK.crypto.repository.CryptoTransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class CryptoWalletService {

    private final CryptoTransactionRepository repository;

    public CryptoWalletService(CryptoTransactionRepository repository) {
        this.repository = repository;
    }

    public CryptoTransaction processTransaction(CryptoTransactionRequest request) {
        CryptoTransaction tx = new CryptoTransaction();
        tx.setWalletAddress(request.getWalletAddress());
        tx.setAmount(request.getAmount());
        tx.setCryptoType(request.getCryptoType());
        tx.setDescription(request.getDescription());
        return repository.save(tx);
    }
}