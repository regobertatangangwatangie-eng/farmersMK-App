package com.FarmersMK.orangemoney.repository;

import com.FarmersMK.orangemoney.model.OrangeTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrangeTransactionRepository extends JpaRepository<OrangeTransaction, Long> {
}