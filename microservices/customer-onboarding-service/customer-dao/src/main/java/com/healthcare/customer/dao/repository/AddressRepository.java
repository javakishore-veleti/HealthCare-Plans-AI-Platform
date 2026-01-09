package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.AddressType;
import com.healthcare.customer.common.model.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AddressRepository extends JpaRepository<Address, UUID> {

    List<Address> findByCustomerId(UUID customerId);

    Optional<Address> findByCustomerIdAndAddressType(UUID customerId, AddressType addressType);

    Optional<Address> findByCustomerIdAndIsPrimaryTrue(UUID customerId);

    @Modifying
    @Query("UPDATE Address a SET a.isPrimary = false WHERE a.customer.id = :customerId")
    void clearPrimaryAddresses(@Param("customerId") UUID customerId);

    void deleteByCustomerId(UUID customerId);
}
