package com.farmpro.instagram.controller;

import com.farmpro.instagram.dto.InstagramPostRequest;
import com.farmpro.instagram.model.InstagramPost;
import com.farmpro.instagram.service.InstagramService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/instagram")
public class InstagramController {

    private final InstagramService service;

    public InstagramController(InstagramService service) {
        this.service = service;
    }

    // Create advertisement post
    @PostMapping("/ads")
    public InstagramPost createAd(@RequestBody InstagramPostRequest request) {
        return service.createAdPost(request);
    }

    // Redirect endpoint
    @GetMapping("/redirect")
    public String redirectToFarmPro(@RequestParam String url) {
        return "Redirect user to: " + url;
    }
}