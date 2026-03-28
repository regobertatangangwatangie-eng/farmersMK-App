package com.farmpro.crypto.service;

import com.farmpro.crypto.dto.CryptoTransactionRequest;
import com.farmpro.crypto.model.CryptoTransaction;
import com.farmpro.crypto.repository.CryptoTransactionRepository;
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