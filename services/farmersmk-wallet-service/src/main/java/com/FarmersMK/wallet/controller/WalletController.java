package com.FarmersMK.wallet.controller;

import com.FarmersMK.wallet.dto.WalletRequest;
import com.FarmersMK.wallet.model.Wallet;
import com.FarmersMK.wallet.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/wallets")
public class WalletController {

    @Autowired
    private WalletService walletService;

    @PostMapping
    public Wallet createWallet(@RequestBody WalletRequest request) {
        return walletService.createWallet(request);
    }

    @GetMapping
    public List<Wallet> getAllWallets() {
        return walletService.getAllWallets();
    }

    @PostMapping("/{id}/deposit")
    public Wallet deposit(@PathVariable Long id, @RequestParam double amount) {
        return walletService.deposit(id, amount);
    }
}