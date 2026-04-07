package com.FarmersMK.twitter.repository;

import com.FarmersMK.twitter.model.TwitterPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TwitterPostRepository extends JpaRepository<TwitterPost, Long> {
}