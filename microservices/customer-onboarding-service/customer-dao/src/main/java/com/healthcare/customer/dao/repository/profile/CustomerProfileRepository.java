package com.healthcare.customer.dao.repository.profile;

import com.healthcare.customer.dao.entity.profile.CustomerProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerProfileRepository extends JpaRepository<CustomerProfile, UUID> {
    List<CustomerProfile> findByUserIdOrderByIsPrimaryDescCreatedAtAsc(UUID userId);
    
    Optional<CustomerProfile> findByIdAndUserId(UUID id, UUID userId);
    
    @Query("SELECT COUNT(p) FROM CustomerProfile p WHERE p.user.id = :userId")
    long countByUserId(UUID userId);
    
    @Query("SELECT p FROM CustomerProfile p WHERE p.user.id = :userId AND p.isPrimary = true")
    Optional<CustomerProfile> findPrimaryByUserId(UUID userId);
    
    boolean existsByUserIdAndIsPrimaryTrue(UUID userId);
}
