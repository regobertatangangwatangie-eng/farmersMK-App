package com.farmpro.visacard.repository;

import com.farmpro.visacard.model.VISAcardTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VISAcardTransactionRepository extends JpaRepository<VISAcardTransaction, Long> {
}