package com.FarmersMK.crypto.model;

import jakarta.persistence.*;

@Entity
@Table(name = "crypto_transaction")
public class CryptoTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String walletAddress;
    private double amount;
    private String cryptoType;
    private String description;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getWalletAddress() { return walletAddress; }
    public void setWalletAddress(String walletAddress) { this.walletAddress = walletAddress; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getCryptoType() { return cryptoType; }
    public void setCryptoType(String cryptoType) { this.cryptoType = cryptoType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}