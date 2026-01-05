package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.ProviderType;
import com.healthcare.plans.common.model.HealthcareProvider;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface HealthcareProviderRepository extends JpaRepository<HealthcareProvider, UUID>, 
                                                      JpaSpecificationExecutor<HealthcareProvider> {
    
    Optional<HealthcareProvider> findByProviderCode(String providerCode);
    
    boolean existsByProviderCode(String providerCode);
    
    Page<HealthcareProvider> findByProviderTypeAndStatus(ProviderType providerType, String status, Pageable pageable);
    
    @Query("SELECT COUNT(p) FROM HealthcareProvider p WHERE p.status = 'active'")
    long countActiveProviders();
}
