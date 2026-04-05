package com.farmpro.facebook.controller;

import com.farmpro.facebook.dto.FacebookPostRequest;
import com.farmpro.facebook.service.FacebookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/facebook")
public class FacebookController {

    @Autowired
    private FacebookService facebookService;

    @PostMapping("/post")
    public String createPost(@RequestBody FacebookPostRequest request) {
        return facebookService.createPost(request);
    }
}