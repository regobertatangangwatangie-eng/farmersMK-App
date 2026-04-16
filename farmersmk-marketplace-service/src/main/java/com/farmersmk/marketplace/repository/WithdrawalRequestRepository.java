package com.farmersmk.marketplace.repository;

import com.farmersmk.marketplace.model.WithdrawalRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WithdrawalRequestRepository extends JpaRepository<WithdrawalRequest, Long> {
    // Custom queries if needed
}
