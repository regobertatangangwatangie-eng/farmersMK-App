package com.farmpro.realtime.controller;

import com.farmpro.realtime.model.Message;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class RealtimeController {

    @MessageMapping("/send")
    @SendTo("/topic/messages")
    public Message send(Message message) {
        return message;
    }
}