package com.FarmersMK.twitter.dto;

public class TwitterPostRequest {

    private String title;
    private String content;
    private String link;

    public TwitterPostRequest() {}

    public String getTitle() { return title; }

    public String getContent() { return content; }

    public String getLink() { return link; }

    public void setTitle(String title) { this.title = title; }

    public void setContent(String content) { this.content = content; }

    public void setLink(String link) { this.link = link; }
}