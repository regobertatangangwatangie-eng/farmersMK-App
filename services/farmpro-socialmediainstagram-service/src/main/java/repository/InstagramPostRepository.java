package com.farmpro.instagram.repository;

import com.farmpro.instagram.model.InstagramPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InstagramPostRepository extends JpaRepository<InstagramPost, Long> {
}