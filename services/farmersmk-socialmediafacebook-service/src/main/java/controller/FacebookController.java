package com.FarmersMK.facebook.controller;

import com.FarmersMK.facebook.dto.FacebookPostRequest;
import com.FarmersMK.facebook.service.FacebookService;
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