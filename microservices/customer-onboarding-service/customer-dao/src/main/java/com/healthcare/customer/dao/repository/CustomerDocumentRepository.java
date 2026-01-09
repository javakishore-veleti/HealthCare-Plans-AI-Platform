package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.DocumentStatus;
import com.healthcare.customer.common.constants.DocumentType;
import com.healthcare.customer.common.model.CustomerDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CustomerDocumentRepository extends JpaRepository<CustomerDocument, UUID> {

    List<CustomerDocument> findByCustomerId(UUID customerId);

    List<CustomerDocument> findByCustomerIdAndStatus(UUID customerId, DocumentStatus status);

    List<CustomerDocument> findByCustomerIdAndDocumentType(UUID customerId, DocumentType documentType);

    int countByCustomerId(UUID customerId);

    int countByCustomerIdAndStatus(UUID customerId, DocumentStatus status);

    void deleteByCustomerId(UUID customerId);
}
