package com.FarmersMK.admin.service;

import com.FarmersMK.admin.dto.AdminStatsResponse;
import com.FarmersMK.admin.model.AdminUser;
import com.FarmersMK.admin.repository.AdminUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    @Autowired
    private AdminUserRepository repository;

    public List<AdminUser> getAllUsers() {
        return repository.findAll();
    }

    public AdminUser createUser(AdminUser user) {
        return repository.save(user);
    }

    public AdminStatsResponse getStats() {
        long totalUsers = repository.count();

        AdminStatsResponse stats = new AdminStatsResponse();
        stats.setTotalUsers(totalUsers);
        stats.setActiveUsers(totalUsers); // simple logic for now
        stats.setSystemHealth("OK");

        return stats;
    }
}