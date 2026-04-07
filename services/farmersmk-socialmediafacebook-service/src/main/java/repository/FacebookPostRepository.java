package com.FarmersMK.facebook.repository;

import com.FarmersMK.facebook.model.FacebookPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FacebookPostRepository extends JpaRepository<FacebookPost, Long> {
}