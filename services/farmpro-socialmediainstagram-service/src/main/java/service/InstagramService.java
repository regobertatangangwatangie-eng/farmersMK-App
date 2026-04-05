package com.farmpro.instagram.service;

import com.farmpro.instagram.dto.InstagramPostRequest;
import com.farmpro.instagram.model.InstagramPost;
import com.farmpro.instagram.repository.InstagramPostRepository;
import org.springframework.stereotype.Service;

@Service
public class InstagramService {

    private final InstagramPostRepository repository;

    public InstagramService(InstagramPostRepository repository) {
        this.repository = repository;
    }

    public InstagramPost createAdPost(InstagramPostRequest request) {

        InstagramPost post = new InstagramPost();

        // 🔥 Auto-generate FARMERPRO advertisement
        post.setTitle("🚜 Join FARMERPRO Today!");
        post.setContent(
                "Boost your farming business with FARMERPRO 🌱\n" +
                "✔ Access marketplace\n" +
                "✔ Secure payments\n" +
                "✔ Smart agriculture tools\n" +
                "👉 Click to get started NOW!"
        );

        // Redirect to main platform
        post.setRedirectUrl(request.getRedirectUrl());

        return repository.save(post);
    }
}