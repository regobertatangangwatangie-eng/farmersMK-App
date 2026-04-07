package com.FarmersMK.admin.controller;

import com.FarmersMK.admin.dto.AdminStatsResponse;
import com.FarmersMK.admin.model.AdminUser;
import com.FarmersMK.admin.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    @GetMapping("/users")
    public List<AdminUser> getAllUsers() {
        return adminService.getAllUsers();
    }

    @PostMapping("/users")
    public AdminUser createUser(@RequestBody AdminUser user) {
        return adminService.createUser(user);
    }

    @GetMapping("/stats")
    public AdminStatsResponse getStats() {
        return adminService.getStats();
    }
}