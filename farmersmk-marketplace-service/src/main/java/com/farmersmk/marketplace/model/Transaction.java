package com.farmersmk.marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Transaction {
    private Long id;
    private Long buyerId;
    private Long sellerId;
    private BigDecimal amount;
    private BigDecimal fee;
    private LocalDateTime timestamp;
    private String status;
    // getters and setters
}
