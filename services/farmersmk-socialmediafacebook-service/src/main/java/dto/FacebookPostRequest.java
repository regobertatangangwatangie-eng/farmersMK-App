package com.FarmersMK.facebook.dto;

public class FacebookPostRequest {

    private String title;
    private String content;

    public FacebookPostRequest() {}

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}