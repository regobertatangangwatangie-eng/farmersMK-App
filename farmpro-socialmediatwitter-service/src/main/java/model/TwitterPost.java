package com.farmpro.twitter.model;

import jakarta.persistence.*;

@Entity
public class TwitterPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String content;
    private String link;

    public TwitterPost() {}

    public TwitterPost(String title, String content, String link) {
        this.title = title;
        this.content = content;
        this.link = link;
    }

    public Long getId() { return id; }

    public String getTitle() { return title; }

    public String getContent() { return content; }

    public String getLink() { return link; }

    public void setId(Long id) { this.id = id; }

    public void setTitle(String title) { this.title = title; }

    public void setContent(String content) { this.content = content; }

    public void setLink(String link) { this.link = link; }
}