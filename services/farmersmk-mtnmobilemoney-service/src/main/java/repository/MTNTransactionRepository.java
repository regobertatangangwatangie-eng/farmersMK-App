package com.FarmersMK.mtnmobilemoney.repository;

import com.FarmersMK.mtnmobilemoney.model.MTNTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MTNTransactionRepository extends JpaRepository<MTNTransaction, Long> {
}