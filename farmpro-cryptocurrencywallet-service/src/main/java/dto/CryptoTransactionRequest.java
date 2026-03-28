package com.farmpro.crypto.dto;

public class CryptoTransactionRequest {

    private String walletAddress;
    private double amount;
    private String cryptoType;
    private String description;

    public String getWalletAddress() { return walletAddress; }
    public void setWalletAddress(String walletAddress) { this.walletAddress = walletAddress; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getCryptoType() { return cryptoType; }
    public void setCryptoType(String cryptoType) { this.cryptoType = cryptoType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}