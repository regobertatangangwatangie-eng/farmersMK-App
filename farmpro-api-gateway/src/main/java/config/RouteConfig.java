package com.farmpro.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RouteConfig {

    @Bean
    public RouteLocator customRoutes(RouteLocatorBuilder builder) {
        return builder.routes()

                // USER SERVICE
                .route("user-service", r -> r.path("/users/**")
                        .uri("http://localhost:8081"))

                // ADMIN SERVICE
                .route("admin-service", r -> r.path("/admin/**")
                        .uri("http://localhost:8082"))

                // MARKETPLACE SERVICE
                .route("marketplace-service", r -> r.path("/products/**")
                        .uri("http://localhost:8083"))

                .build();
    }
}