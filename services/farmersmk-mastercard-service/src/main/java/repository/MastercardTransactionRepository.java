package com.FarmersMK.mastercard.repository;

import com.FarmersMK.mastercard.model.MastercardTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MastercardTransactionRepository extends JpaRepository<MastercardTransaction, Long> {
}