package com.FarmersMK.instagram.repository;

import com.FarmersMK.instagram.model.InstagramPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InstagramPostRepository extends JpaRepository<InstagramPost, Long> {
}