package com.farmpro.orangemoney.repository;

import com.farmpro.orangemoney.model.OrangeTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrangeTransactionRepository extends JpaRepository<OrangeTransaction, Long> {
}