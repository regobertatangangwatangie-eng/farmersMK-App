package com.farmpro.mtnmobilemoney.repository;

import com.farmpro.mtnmobilemoney.model.MTNTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MTNTransactionRepository extends JpaRepository<MTNTransaction, Long> {
}