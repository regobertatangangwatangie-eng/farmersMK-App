package com.FarmersMK.crypto.repository;

import com.FarmersMK.crypto.model.CryptoTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CryptoTransactionRepository extends JpaRepository<CryptoTransaction, Long> {
}