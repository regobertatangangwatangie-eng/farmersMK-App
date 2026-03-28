package com.farmpro.visacard.service;

import com.farmpro.visacard.dto.VISAcardTransactionRequest;
import com.farmpro.visacard.model.VISAcardTransaction;
import com.farmpro.visacard.repository.VISAcardTransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class VISAcardService {

    private final VISAcardTransactionRepository repository;

    public VISAcardService(VISAcardTransactionRepository repository) {
        this.repository = repository;
    }

    public VISAcardTransaction processTransaction(VISAcardTransactionRequest request) {
        VISAcardTransaction tx = new VISAcardTransaction();
        tx.setCardNumber(request.getCardNumber());
        tx.setAmount(request.getAmount());
        tx.setCurrency(request.getCurrency());
        tx.setDescription(request.getDescription());
        return repository.save(tx);
    }
}