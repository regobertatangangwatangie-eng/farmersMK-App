package com.FarmersMK.mastercard.service;

import com.FarmersMK.mastercard.dto.MastercardTransactionRequest;
import com.FarmersMK.mastercard.model.MastercardTransaction;
import com.FarmersMK.mastercard.repository.MastercardTransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class MastercardService {

    private final MastercardTransactionRepository repository;

    public MastercardService(MastercardTransactionRepository repository) {
        this.repository = repository;
    }

    public MastercardTransaction processTransaction(MastercardTransactionRequest request) {

        MastercardTransaction transaction = new MastercardTransaction();
        transaction.setCardNumber(request.getCardNumber());
        transaction.setAmount(request.getAmount());
        transaction.setCurrency(request.getCurrency());
        transaction.setDescription(request.getDescription());

        return repository.save(transaction);
    }
}