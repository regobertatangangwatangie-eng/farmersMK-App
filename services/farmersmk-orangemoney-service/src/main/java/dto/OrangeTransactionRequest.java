package com.FarmersMK.orangemoney.dto;

public class OrangeTransactionRequest {

    private String phoneNumber;
    private Double amount;
    private String description;

    // Getters & Setters
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}