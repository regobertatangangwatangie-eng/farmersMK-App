package com.farmersmk.marketplace.repository;

import com.farmersmk.marketplace.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    // Custom queries if needed
}
