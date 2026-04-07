package com.FarmersMK.twitter.controller;

import com.FarmersMK.twitter.dto.TwitterPostRequest;
import com.FarmersMK.twitter.model.TwitterPost;
import com.FarmersMK.twitter.service.TwitterService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/twitter/posts")
public class TwitterController {

    private final TwitterService service;

    public TwitterController(TwitterService service) {
        this.service = service;
    }

    @PostMapping
    public TwitterPost createPost(@RequestBody TwitterPostRequest request) {
        return service.createPost(request);
    }

    @GetMapping
    public List<TwitterPost> getAll() {
        return service.getAllPosts();
    }
}