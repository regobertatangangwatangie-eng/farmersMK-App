package com.farmersmk.marketplace.repository;

import com.farmersmk.marketplace.model.BusinessAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusinessAccountRepository extends JpaRepository<BusinessAccount, Long> {
    // Custom queries if needed
}
