package com.FarmersMK.mtnmobilemoney.dto;

public class MTNTransactionRequest {

    private String phoneNumber;
    private Double amount;
    private String description;

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public Double getAmount() {
        return amount;
    }

    public String getDescription() {
        return description;
    }
}