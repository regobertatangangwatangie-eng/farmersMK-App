package com.farmersmk.marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WithdrawalRequest {
    private Long id;
    private Long sellerId;
    private BigDecimal amount;
    private String goodsPhotoUrl;
    private String transitDocUrl;
    private String companyRegDocUrl;
    private String managerContact;
    private String status;
    private LocalDateTime requestedAt;
    // getters and setters
}
