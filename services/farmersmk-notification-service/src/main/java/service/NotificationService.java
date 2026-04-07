package com.FarmersMK.notification.service;

import com.FarmersMK.notification.dto.NotificationRequest;
import com.FarmersMK.notification.model.Notification;
import com.FarmersMK.notification.repository.NotificationRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository repository;

    public NotificationService(NotificationRepository repository) {
        this.repository = repository;
    }

    public Notification sendNotification(NotificationRequest request) {
        Notification notification = new Notification();
        notification.setRecipient(request.getRecipient());
        notification.setMessage(request.getMessage());
        notification.setCreatedAt(LocalDateTime.now());

        return repository.save(notification);
    }

    public List<Notification> getAllNotifications() {
        return repository.findAll();
    }
}