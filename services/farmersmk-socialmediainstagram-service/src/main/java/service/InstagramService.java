package com.FarmersMK.instagram.service;

import com.FarmersMK.instagram.dto.InstagramPostRequest;
import com.FarmersMK.instagram.model.InstagramPost;
import com.FarmersMK.instagram.repository.InstagramPostRepository;
import org.springframework.stereotype.Service;

@Service
public class InstagramService {

    private final InstagramPostRepository repository;

    public InstagramService(InstagramPostRepository repository) {
        this.repository = repository;
    }

    public InstagramPost createAdPost(InstagramPostRequest request) {

        InstagramPost post = new InstagramPost();

        // 🔥 Auto-generate farmersmk advertisement
        post.setTitle("🚜 Join farmersmk Today!");
        post.setContent(
                "Boost your farming business with farmersmk 🌱\n" +
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