package com.farmpro.mastercard.repository;

import com.farmpro.mastercard.model.MastercardTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MastercardTransactionRepository extends JpaRepository<MastercardTransaction, Long> {
}