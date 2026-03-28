package com.farmpro.notification.controller;

import com.farmpro.notification.dto.NotificationRequest;
import com.farmpro.notification.model.Notification;
import com.farmpro.notification.service.NotificationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService service;

    public NotificationController(NotificationService service) {
        this.service = service;
    }

    @PostMapping
    public Notification sendNotification(@RequestBody NotificationRequest request) {
        return service.sendNotification(request);
    }

    @GetMapping
    public List<Notification> getAll() {
        return service.getAllNotifications();
    }
}