package com.FarmersMK.orangemoney.service;

import com.FarmersMK.orangemoney.dto.OrangeTransactionRequest;
import com.FarmersMK.orangemoney.model.OrangeTransaction;
import com.FarmersMK.orangemoney.repository.OrangeTransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class OrangeMoneyService {

    private final OrangeTransactionRepository repository;

    public OrangeMoneyService(OrangeTransactionRepository repository) {
        this.repository = repository;
    }

    public OrangeTransaction sendMoney(OrangeTransactionRequest request) {
        OrangeTransaction transaction = new OrangeTransaction();
        transaction.setPhoneNumber(request.getPhoneNumber());
        transaction.setAmount(request.getAmount());
        transaction.setDescription(request.getDescription());
        return repository.save(transaction);
    }
}