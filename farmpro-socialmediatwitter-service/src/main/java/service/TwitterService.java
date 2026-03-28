package com.farmpro.twitter.service;

import com.farmpro.twitter.dto.TwitterPostRequest;
import com.farmpro.twitter.model.TwitterPost;
import com.farmpro.twitter.repository.TwitterPostRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TwitterService {

    private final TwitterPostRepository repository;

    public TwitterService(TwitterPostRepository repository) {
        this.repository = repository;
    }

    public TwitterPost createPost(TwitterPostRequest request) {

        // Advertisement content for FARMERPRO
        String content = request.getContent() + 
                " 🚜 Discover FARMERPRO-APP: Boost your farming, payments, and market reach today! 👉 " 
                + request.getLink();

        TwitterPost post = new TwitterPost(
                request.getTitle(),
                content,
                request.getLink()
        );

        return repository.save(post);
    }

    public List<TwitterPost> getAllPosts() {
        return repository.findAll();
    }
}