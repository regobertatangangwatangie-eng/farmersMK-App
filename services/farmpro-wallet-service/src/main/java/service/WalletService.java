package com.farmpro.wallet.service;

import com.farmpro.wallet.dto.WalletRequest;
import com.farmpro.wallet.model.Transaction;
import com.farmpro.wallet.model.Wallet;
import com.farmpro.wallet.repository.TransactionRepository;
import com.farmpro.wallet.repository.WalletRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class WalletService {

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    public Wallet createWallet(WalletRequest request) {
        Wallet wallet = new Wallet();
        wallet.setOwner(request.getOwner());
        wallet.setBalance(0);
        return walletRepository.save(wallet);
    }

    public List<Wallet> getAllWallets() {
        return walletRepository.findAll();
    }

    public Wallet deposit(Long walletId, double amount) {
        Wallet wallet = walletRepository.findById(walletId).orElseThrow();

        wallet.setBalance(wallet.getBalance() + amount);

        Transaction tx = new Transaction();
        tx.setWallet(wallet);
        tx.setAmount(amount);
        tx.setType("DEPOSIT");

        transactionRepository.save(tx);

        return walletRepository.save(wallet);
    }
}