package com.FarmersMK.facebook.service;

import com.FarmersMK.facebook.dto.FacebookPostRequest;
import org.springframework.stereotype.Service;

@Service
public class FacebookService {

    public String createPost(FacebookPostRequest request) {

        String title = request.getTitle();
        String content = request.getContent();

        // Simulated Facebook post logic
        String post = "🚜 farmersmk UPDATE 🚜\n\n"
                + "Title: " + title + "\n"
                + "Content: " + content + "\n\n"
                + "Join farmersmk today and grow your farming business! 🌱";

        // In real case → call Facebook API here

        return post;
    }
}