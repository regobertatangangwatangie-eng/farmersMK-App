package com.farmpro.post.controller;

import com.farmpro.post.model.Post;
import com.farmpro.post.dto.PostRequest;
import com.farmpro.post.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/posts")
@CrossOrigin(origins = "*")
public class PostController {

    @Autowired
    private PostService postService;

    @GetMapping
    public List<Post> getAllPosts() {
        return postService.getAllPosts();
    }

    @PostMapping
    public Post createPost(@RequestBody PostRequest postRequest) {
        return postService.createPost(postRequest);
    }
}