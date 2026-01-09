#!/bin/bash

# =============================================================================
# Customer Onboarding Service - Java Source Files Generator (Part 2)
# =============================================================================
# Creates: Repositories, Specifications, Services, Mappers
# =============================================================================

set -e

BASE_DIR="microservices/customer-onboarding-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Customer Onboarding Service - Part 2 (DAO & Service Layers)              ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# REPOSITORIES
# =============================================================================
echo -e "${CYAN}Creating Repositories...${NC}"

REPO_DIR="$BASE_DIR/customer-dao/src/main/java/com/healthcare/customer/dao/repository"
mkdir -p "$REPO_DIR"

cat > "$REPO_DIR/CustomerRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, UUID>, JpaSpecificationExecutor<Customer> {

    Optional<Customer> findByCustomerNumber(String customerNumber);

    Optional<Customer> findByEmail(String email);

    boolean existsByEmail(String email);

    boolean existsByCustomerNumber(String customerNumber);

    List<Customer> findByStatus(CustomerStatus status);

    @Query("SELECT c FROM Customer c LEFT JOIN FETCH c.addresses WHERE c.id = :id")
    Optional<Customer> findByIdWithAddresses(@Param("id") UUID id);

    @Query("SELECT c FROM Customer c " +
           "LEFT JOIN FETCH c.addresses " +
           "LEFT JOIN FETCH c.dependents " +
           "WHERE c.id = :id")
    Optional<Customer> findByIdWithDetails(@Param("id") UUID id);

    @Query("SELECT c FROM Customer c WHERE c.status = :status AND c.emailVerified = false")
    List<Customer> findUnverifiedCustomers(@Param("status") CustomerStatus status);

    @Query("SELECT COUNT(c) FROM Customer c WHERE c.status = :status")
    long countByStatus(@Param("status") CustomerStatus status);
}
EOF
echo -e "${GREEN}✓${NC} CustomerRepository.java"

cat > "$REPO_DIR/AddressRepository.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} AddressRepository.java"

cat > "$REPO_DIR/DependentRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.RelationshipType;
import com.healthcare.customer.common.model.Dependent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DependentRepository extends JpaRepository<Dependent, UUID> {

    List<Dependent> findByCustomerId(UUID customerId);

    List<Dependent> findByCustomerIdAndRelationship(UUID customerId, RelationshipType relationship);

    int countByCustomerId(UUID customerId);

    void deleteByCustomerId(UUID customerId);
}
EOF
echo -e "${GREEN}✓${NC} DependentRepository.java"

cat > "$REPO_DIR/CustomerDocumentRepository.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} CustomerDocumentRepository.java"

cat > "$REPO_DIR/EligibilityCheckRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.EligibilityStatus;
import com.healthcare.customer.common.model.EligibilityCheck;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EligibilityCheckRepository extends JpaRepository<EligibilityCheck, UUID> {

    List<EligibilityCheck> findByCustomerId(UUID customerId);

    List<EligibilityCheck> findByCustomerIdAndStatus(UUID customerId, EligibilityStatus status);

    Optional<EligibilityCheck> findByCustomerIdAndPlanId(UUID customerId, UUID planId);

    @Query("SELECT e FROM EligibilityCheck e WHERE e.customer.id = :customerId AND e.planId = :planId " +
           "AND e.status = 'ELIGIBLE' AND e.expirationDate > :now")
    Optional<EligibilityCheck> findValidEligibility(
        @Param("customerId") UUID customerId,
        @Param("planId") UUID planId,
        @Param("now") LocalDateTime now);

    @Query("SELECT e FROM EligibilityCheck e WHERE e.expirationDate < :now AND e.status = 'ELIGIBLE'")
    List<EligibilityCheck> findExpiredEligibilities(@Param("now") LocalDateTime now);
}
EOF
echo -e "${GREEN}✓${NC} EligibilityCheckRepository.java"

cat > "$REPO_DIR/CustomerPlanEnrollmentRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.EnrollmentStatus;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerPlanEnrollmentRepository extends JpaRepository<CustomerPlanEnrollment, UUID> {

    List<CustomerPlanEnrollment> findByCustomerId(UUID customerId);

    List<CustomerPlanEnrollment> findByCustomerIdAndStatus(UUID customerId, EnrollmentStatus status);

    Optional<CustomerPlanEnrollment> findByCustomerIdAndPlanIdAndStatus(UUID customerId, UUID planId, EnrollmentStatus status);

    @Query("SELECT e FROM CustomerPlanEnrollment e WHERE e.customer.id = :customerId " +
           "AND e.status = 'ENROLLED' AND e.effectiveDate <= :date " +
           "AND (e.terminationDate IS NULL OR e.terminationDate > :date)")
    List<CustomerPlanEnrollment> findActiveEnrollments(
        @Param("customerId") UUID customerId,
        @Param("date") LocalDate date);

    @Query("SELECT e FROM CustomerPlanEnrollment e WHERE e.planId = :planId AND e.status = 'ENROLLED'")
    List<CustomerPlanEnrollment> findEnrolledByPlanId(@Param("planId") UUID planId);

    @Query("SELECT COUNT(e) FROM CustomerPlanEnrollment e WHERE e.customer.id = :customerId AND e.status = 'ENROLLED'")
    int countActiveEnrollments(@Param("customerId") UUID customerId);

    boolean existsByCustomerIdAndPlanIdAndStatus(UUID customerId, UUID planId, EnrollmentStatus status);
}
EOF
echo -e "${GREEN}✓${NC} CustomerPlanEnrollmentRepository.java"

# =============================================================================
# SPECIFICATIONS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Specifications...${NC}"

SPEC_DIR="$BASE_DIR/customer-dao/src/main/java/com/healthcare/customer/dao/specification"
mkdir -p "$SPEC_DIR"

cat > "$SPEC_DIR/CustomerSpecification.java" << 'EOF'
package com.healthcare.customer.dao.specification;

import com.healthcare.customer.common.dto.request.CustomerSearchRequest;
import com.healthcare.customer.common.model.Address;
import com.healthcare.customer.common.model.Customer;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

public class CustomerSpecification {

    public static Specification<Customer> buildSpecification(CustomerSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (StringUtils.hasText(request.getEmail())) {
                predicates.add(cb.equal(cb.lower(root.get("email")), request.getEmail().toLowerCase()));
            }

            if (StringUtils.hasText(request.getPhone())) {
                predicates.add(cb.or(
                    cb.equal(root.get("phone"), request.getPhone()),
                    cb.equal(root.get("mobilePhone"), request.getPhone())
                ));
            }

            if (StringUtils.hasText(request.getFirstName())) {
                predicates.add(cb.like(cb.lower(root.get("firstName")), 
                    "%" + request.getFirstName().toLowerCase() + "%"));
            }

            if (StringUtils.hasText(request.getLastName())) {
                predicates.add(cb.like(cb.lower(root.get("lastName")), 
                    "%" + request.getLastName().toLowerCase() + "%"));
            }

            if (StringUtils.hasText(request.getCustomerNumber())) {
                predicates.add(cb.equal(root.get("customerNumber"), request.getCustomerNumber()));
            }

            if (request.getStatus() != null) {
                predicates.add(cb.equal(root.get("status"), request.getStatus()));
            }

            if (StringUtils.hasText(request.getStateCode()) || StringUtils.hasText(request.getZipCode())) {
                Join<Customer, Address> addressJoin = root.join("addresses", JoinType.INNER);
                addressJoin.on(cb.isTrue(addressJoin.get("isPrimary")));

                if (StringUtils.hasText(request.getStateCode())) {
                    predicates.add(cb.equal(addressJoin.get("stateCode"), request.getStateCode()));
                }

                if (StringUtils.hasText(request.getZipCode())) {
                    predicates.add(cb.equal(addressJoin.get("zipCode"), request.getZipCode()));
                }
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerSpecification.java"

# =============================================================================
# SERVICES
# =============================================================================
echo ""
echo -e "${CYAN}Creating Services...${NC}"

SERVICE_DIR="$BASE_DIR/customer-service-core/src/main/java/com/healthcare/customer/service"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/CustomerService.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;

import java.util.UUID;

public interface CustomerService {

    CustomerDetailResponse createCustomer(CreateCustomerRequest request);

    CustomerDetailResponse getCustomerById(UUID customerId);

    CustomerDetailResponse getCustomerByNumber(String customerNumber);

    CustomerDetailResponse getCustomerByEmail(String email);

    PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request);

    CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request);

    void deleteCustomer(UUID customerId);

    void activateCustomer(UUID customerId);

    void suspendCustomer(UUID customerId, String reason);

    boolean isEmailAvailable(String email);
}
EOF
echo -e "${GREEN}✓${NC} CustomerService.java"

cat > "$SERVICE_DIR/AddressService.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.AddressRequest;
import com.healthcare.customer.common.dto.response.AddressResponse;

import java.util.List;
import java.util.UUID;

public interface AddressService {

    AddressResponse addAddress(UUID customerId, AddressRequest request);

    AddressResponse updateAddress(UUID customerId, UUID addressId, AddressRequest request);

    void deleteAddress(UUID customerId, UUID addressId);

    List<AddressResponse> getCustomerAddresses(UUID customerId);

    AddressResponse getPrimaryAddress(UUID customerId);

    void setPrimaryAddress(UUID customerId, UUID addressId);
}
EOF
echo -e "${GREEN}✓${NC} AddressService.java"

cat > "$SERVICE_DIR/DependentService.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.DependentRequest;
import com.healthcare.customer.common.dto.response.DependentResponse;

import java.util.List;
import java.util.UUID;

public interface DependentService {

    DependentResponse addDependent(UUID customerId, DependentRequest request);

    DependentResponse updateDependent(UUID customerId, UUID dependentId, DependentRequest request);

    void deleteDependent(UUID customerId, UUID dependentId);

    List<DependentResponse> getCustomerDependents(UUID customerId);

    DependentResponse getDependentById(UUID customerId, UUID dependentId);
}
EOF
echo -e "${GREEN}✓${NC} DependentService.java"

cat > "$SERVICE_DIR/EnrollmentService.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;

import java.util.List;
import java.util.UUID;

public interface EnrollmentService {

    EligibilityResponse checkEligibility(UUID customerId, UUID planId);

    EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request);

    EnrollmentResponse getEnrollmentById(UUID enrollmentId);

    List<EnrollmentResponse> getCustomerEnrollments(UUID customerId);

    List<EnrollmentResponse> getActiveEnrollments(UUID customerId);

    void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason);

    void terminateEnrollment(UUID customerId, UUID enrollmentId, String reason);
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentService.java"

# Service Implementations
cat > "$SERVICE_DIR/CustomerServiceImpl.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.common.model.*;
import com.healthcare.customer.dao.repository.*;
import com.healthcare.customer.dao.specification.CustomerSpecification;
import com.healthcare.customer.service.mapper.CustomerMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;
    private final AddressRepository addressRepository;
    private final CustomerDocumentRepository documentRepository;
    private final CustomerMapper customerMapper;

    @Override
    public CustomerDetailResponse createCustomer(CreateCustomerRequest request) {
        log.info("Creating new customer with email: {}", request.getEmail());

        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered: " + request.getEmail());
        }

        Customer customer = customerMapper.toEntity(request);
        customer.setCustomerNumber(generateCustomerNumber());
        customer.setStatus(CustomerStatus.PENDING);

        // Add primary address if provided
        if (request.getPrimaryAddress() != null) {
            Address address = customerMapper.toAddressEntity(request.getPrimaryAddress());
            address.setCustomer(customer);
            address.setIsPrimary(true);
            customer.getAddresses().add(address);
        }

        Customer savedCustomer = customerRepository.save(customer);
        log.info("Created customer with ID: {} and number: {}", savedCustomer.getId(), savedCustomer.getCustomerNumber());

        return customerMapper.toDetailResponse(savedCustomer);
    }

    @Override
    @Transactional(readOnly = true)
    public CustomerDetailResponse getCustomerById(UUID customerId) {
        Customer customer = customerRepository.findByIdWithDetails(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));
        
        CustomerDetailResponse response = customerMapper.toDetailResponse(customer);
        response.setDocumentCount(documentRepository.countByCustomerId(customerId));
        return response;
    }

    @Override
    @Transactional(readOnly = true)
    public CustomerDetailResponse getCustomerByNumber(String customerNumber) {
        Customer customer = customerRepository.findByCustomerNumber(customerNumber)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerNumber));
        return customerMapper.toDetailResponse(customer);
    }

    @Override
    @Transactional(readOnly = true)
    public CustomerDetailResponse getCustomerByEmail(String email) {
        Customer customer = customerRepository.findByEmail(email)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found with email: " + email));
        return customerMapper.toDetailResponse(customer);
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request) {
        Sort sort = buildSort(request.getSortBy(), request.getSortDirection());
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize(), sort);

        Page<Customer> customerPage = customerRepository.findAll(
            CustomerSpecification.buildSpecification(request), pageable);

        return PagedResponse.<CustomerResponse>builder()
            .content(customerPage.getContent().stream()
                .map(customerMapper::toResponse)
                .collect(Collectors.toList()))
            .page(customerPage.getNumber())
            .size(customerPage.getSize())
            .totalElements(customerPage.getTotalElements())
            .totalPages(customerPage.getTotalPages())
            .first(customerPage.isFirst())
            .last(customerPage.isLast())
            .build();
    }

    @Override
    public CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        if (request.getEmail() != null && !request.getEmail().equals(customer.getEmail())) {
            if (customerRepository.existsByEmail(request.getEmail())) {
                throw new IllegalArgumentException("Email already registered: " + request.getEmail());
            }
            customer.setEmailVerified(false);
        }

        customerMapper.updateEntity(customer, request);
        Customer savedCustomer = customerRepository.save(customer);
        return customerMapper.toDetailResponse(savedCustomer);
    }

    @Override
    public void deleteCustomer(UUID customerId) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));
        
        customer.setStatus(CustomerStatus.TERMINATED);
        customerRepository.save(customer);
        log.info("Soft-deleted customer: {}", customerId);
    }

    @Override
    public void activateCustomer(UUID customerId) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));
        
        customer.setStatus(CustomerStatus.ACTIVE);
        customerRepository.save(customer);
        log.info("Activated customer: {}", customerId);
    }

    @Override
    public void suspendCustomer(UUID customerId, String reason) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));
        
        customer.setStatus(CustomerStatus.SUSPENDED);
        customerRepository.save(customer);
        log.info("Suspended customer: {} - Reason: {}", customerId, reason);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isEmailAvailable(String email) {
        return !customerRepository.existsByEmail(email);
    }

    private String generateCustomerNumber() {
        String prefix = "CUS";
        long timestamp = System.currentTimeMillis() % 1000000;
        int random = (int) (Math.random() * 1000);
        return String.format("%s%06d%03d", prefix, timestamp, random);
    }

    private Sort buildSort(String sortBy, String sortDirection) {
        String field = StringUtils.hasText(sortBy) ? sortBy : "createdAt";
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;
        return Sort.by(direction, field);
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerServiceImpl.java"

cat > "$SERVICE_DIR/AddressServiceImpl.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.AddressRequest;
import com.healthcare.customer.common.dto.response.AddressResponse;
import com.healthcare.customer.common.model.Address;
import com.healthcare.customer.common.model.Customer;
import com.healthcare.customer.dao.repository.AddressRepository;
import com.healthcare.customer.dao.repository.CustomerRepository;
import com.healthcare.customer.service.mapper.CustomerMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class AddressServiceImpl implements AddressService {

    private final CustomerRepository customerRepository;
    private final AddressRepository addressRepository;
    private final CustomerMapper customerMapper;

    @Override
    public AddressResponse addAddress(UUID customerId, AddressRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        Address address = customerMapper.toAddressEntity(request);
        address.setCustomer(customer);

        if (Boolean.TRUE.equals(request.getIsPrimary())) {
            addressRepository.clearPrimaryAddresses(customerId);
            address.setIsPrimary(true);
        }

        Address savedAddress = addressRepository.save(address);
        log.info("Added address {} for customer {}", savedAddress.getId(), customerId);
        return customerMapper.toAddressResponse(savedAddress);
    }

    @Override
    public AddressResponse updateAddress(UUID customerId, UUID addressId, AddressRequest request) {
        Address address = addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found: " + addressId));

        if (!address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }

        customerMapper.updateAddressEntity(address, request);

        if (Boolean.TRUE.equals(request.getIsPrimary())) {
            addressRepository.clearPrimaryAddresses(customerId);
            address.setIsPrimary(true);
        }

        Address savedAddress = addressRepository.save(address);
        return customerMapper.toAddressResponse(savedAddress);
    }

    @Override
    public void deleteAddress(UUID customerId, UUID addressId) {
        Address address = addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found: " + addressId));

        if (!address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }

        addressRepository.delete(address);
        log.info("Deleted address {} for customer {}", addressId, customerId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AddressResponse> getCustomerAddresses(UUID customerId) {
        return addressRepository.findByCustomerId(customerId).stream()
            .map(customerMapper::toAddressResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public AddressResponse getPrimaryAddress(UUID customerId) {
        return addressRepository.findByCustomerIdAndIsPrimaryTrue(customerId)
            .map(customerMapper::toAddressResponse)
            .orElse(null);
    }

    @Override
    public void setPrimaryAddress(UUID customerId, UUID addressId) {
        Address address = addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found: " + addressId));

        if (!address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }

        addressRepository.clearPrimaryAddresses(customerId);
        address.setIsPrimary(true);
        addressRepository.save(address);
        log.info("Set primary address {} for customer {}", addressId, customerId);
    }
}
EOF
echo -e "${GREEN}✓${NC} AddressServiceImpl.java"

cat > "$SERVICE_DIR/DependentServiceImpl.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.DependentRequest;
import com.healthcare.customer.common.dto.response.DependentResponse;
import com.healthcare.customer.common.model.Customer;
import com.healthcare.customer.common.model.Dependent;
import com.healthcare.customer.dao.repository.CustomerRepository;
import com.healthcare.customer.dao.repository.DependentRepository;
import com.healthcare.customer.service.mapper.CustomerMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class DependentServiceImpl implements DependentService {

    private final CustomerRepository customerRepository;
    private final DependentRepository dependentRepository;
    private final CustomerMapper customerMapper;

    @Override
    public DependentResponse addDependent(UUID customerId, DependentRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        Dependent dependent = customerMapper.toDependentEntity(request);
        dependent.setCustomer(customer);

        Dependent savedDependent = dependentRepository.save(dependent);
        log.info("Added dependent {} for customer {}", savedDependent.getId(), customerId);
        return customerMapper.toDependentResponse(savedDependent);
    }

    @Override
    public DependentResponse updateDependent(UUID customerId, UUID dependentId, DependentRequest request) {
        Dependent dependent = dependentRepository.findById(dependentId)
            .orElseThrow(() -> new IllegalArgumentException("Dependent not found: " + dependentId));

        if (!dependent.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Dependent does not belong to customer");
        }

        customerMapper.updateDependentEntity(dependent, request);
        Dependent savedDependent = dependentRepository.save(dependent);
        return customerMapper.toDependentResponse(savedDependent);
    }

    @Override
    public void deleteDependent(UUID customerId, UUID dependentId) {
        Dependent dependent = dependentRepository.findById(dependentId)
            .orElseThrow(() -> new IllegalArgumentException("Dependent not found: " + dependentId));

        if (!dependent.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Dependent does not belong to customer");
        }

        dependentRepository.delete(dependent);
        log.info("Deleted dependent {} for customer {}", dependentId, customerId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DependentResponse> getCustomerDependents(UUID customerId) {
        return dependentRepository.findByCustomerId(customerId).stream()
            .map(customerMapper::toDependentResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public DependentResponse getDependentById(UUID customerId, UUID dependentId) {
        Dependent dependent = dependentRepository.findById(dependentId)
            .orElseThrow(() -> new IllegalArgumentException("Dependent not found: " + dependentId));

        if (!dependent.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Dependent does not belong to customer");
        }

        return customerMapper.toDependentResponse(dependent);
    }
}
EOF
echo -e "${GREEN}✓${NC} DependentServiceImpl.java"

cat > "$SERVICE_DIR/EnrollmentServiceImpl.java" << 'EOF'
package com.healthcare.customer.service;

import com.healthcare.customer.common.constants.EligibilityStatus;
import com.healthcare.customer.common.constants.EnrollmentStatus;
import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.common.model.Customer;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import com.healthcare.customer.common.model.EligibilityCheck;
import com.healthcare.customer.dao.repository.CustomerPlanEnrollmentRepository;
import com.healthcare.customer.dao.repository.CustomerRepository;
import com.healthcare.customer.dao.repository.EligibilityCheckRepository;
import com.healthcare.customer.service.mapper.EnrollmentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class EnrollmentServiceImpl implements EnrollmentService {

    private final CustomerRepository customerRepository;
    private final CustomerPlanEnrollmentRepository enrollmentRepository;
    private final EligibilityCheckRepository eligibilityRepository;
    private final EnrollmentMapper enrollmentMapper;

    // TODO: Inject PlanApiClient for inter-service communication
    // private final PlanApiClient planApiClient;

    @Override
    public EligibilityResponse checkEligibility(UUID customerId, UUID planId) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        // Check if there's a valid existing eligibility
        EligibilityCheck existing = eligibilityRepository
            .findValidEligibility(customerId, planId, LocalDateTime.now())
            .orElse(null);

        if (existing != null) {
            return enrollmentMapper.toEligibilityResponse(existing);
        }

        // Perform new eligibility check
        EligibilityCheck check = EligibilityCheck.builder()
            .customer(customer)
            .planId(planId)
            .checkDate(LocalDateTime.now())
            .expirationDate(LocalDateTime.now().plusDays(30))
            .build();

        // TODO: Call plans-service to get plan details and verify eligibility
        // PlanDetailResponse plan = planApiClient.getPlanById(planId);

        // Basic eligibility checks
        boolean ageVerified = verifyAge(customer);
        boolean residenceVerified = !customer.getAddresses().isEmpty();
        boolean incomeVerified = true; // Simplified for now

        check.setAgeVerified(ageVerified);
        check.setResidenceVerified(residenceVerified);
        check.setIncomeVerified(incomeVerified);

        if (ageVerified && residenceVerified) {
            check.setStatus(EligibilityStatus.ELIGIBLE);
            check.setEligibilityReason("Customer meets all eligibility requirements");
        } else {
            check.setStatus(EligibilityStatus.NOT_ELIGIBLE);
            StringBuilder reason = new StringBuilder("Not eligible: ");
            if (!ageVerified) reason.append("Age not verified. ");
            if (!residenceVerified) reason.append("Residence not verified. ");
            check.setEligibilityReason(reason.toString());
        }

        EligibilityCheck savedCheck = eligibilityRepository.save(check);
        log.info("Eligibility check for customer {} and plan {}: {}", customerId, planId, savedCheck.getStatus());

        return enrollmentMapper.toEligibilityResponse(savedCheck);
    }

    @Override
    public EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        // Check if already enrolled in this plan
        if (enrollmentRepository.existsByCustomerIdAndPlanIdAndStatus(
                customerId, request.getPlanId(), EnrollmentStatus.ENROLLED)) {
            throw new IllegalArgumentException("Customer is already enrolled in this plan");
        }

        // Verify eligibility
        EligibilityCheck eligibility = eligibilityRepository
            .findValidEligibility(customerId, request.getPlanId(), LocalDateTime.now())
            .orElseThrow(() -> new IllegalArgumentException("No valid eligibility found. Please check eligibility first."));

        if (eligibility.getStatus() != EligibilityStatus.ELIGIBLE) {
            throw new IllegalArgumentException("Customer is not eligible for this plan");
        }

        // TODO: Get plan details from plans-service
        // PlanDetailResponse plan = planApiClient.getPlanById(request.getPlanId());

        CustomerPlanEnrollment enrollment = CustomerPlanEnrollment.builder()
            .customer(customer)
            .planId(request.getPlanId())
            .planCode("PLAN-" + request.getPlanId().toString().substring(0, 8))  // TODO: Get from plans-service
            .planName("Healthcare Plan")  // TODO: Get from plans-service
            .status(EnrollmentStatus.ENROLLED)
            .effectiveDate(request.getEffectiveDate())
            .memberId(generateMemberId(customer))
            .groupNumber("GRP" + LocalDate.now().getYear())
            .includeDependents(Boolean.TRUE.equals(request.getIncludeDependents()))
            .autoRenew(Boolean.TRUE.equals(request.getAutoRenew()))
            .build();

        CustomerPlanEnrollment savedEnrollment = enrollmentRepository.save(enrollment);
        log.info("Enrolled customer {} in plan {}", customerId, request.getPlanId());

        return enrollmentMapper.toEnrollmentResponse(savedEnrollment);
    }

    @Override
    @Transactional(readOnly = true)
    public EnrollmentResponse getEnrollmentById(UUID enrollmentId) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));
        return enrollmentMapper.toEnrollmentResponse(enrollment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EnrollmentResponse> getCustomerEnrollments(UUID customerId) {
        return enrollmentRepository.findByCustomerId(customerId).stream()
            .map(enrollmentMapper::toEnrollmentResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<EnrollmentResponse> getActiveEnrollments(UUID customerId) {
        return enrollmentRepository.findActiveEnrollments(customerId, LocalDate.now()).stream()
            .map(enrollmentMapper::toEnrollmentResponse)
            .collect(Collectors.toList());
    }

    @Override
    public void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));

        if (!enrollment.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Enrollment does not belong to customer");
        }

        enrollment.setStatus(EnrollmentStatus.CANCELLED);
        enrollment.setCancellationReason(reason);
        enrollment.setTerminationDate(LocalDate.now());
        enrollmentRepository.save(enrollment);

        log.info("Cancelled enrollment {} for customer {} - Reason: {}", enrollmentId, customerId, reason);
    }

    @Override
    public void terminateEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));

        if (!enrollment.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Enrollment does not belong to customer");
        }

        enrollment.setStatus(EnrollmentStatus.TERMINATED);
        enrollment.setCancellationReason(reason);
        enrollment.setTerminationDate(LocalDate.now());
        enrollmentRepository.save(enrollment);

        log.info("Terminated enrollment {} for customer {} - Reason: {}", enrollmentId, customerId, reason);
    }

    private boolean verifyAge(Customer customer) {
        if (customer.getDateOfBirth() == null) return false;
        int age = LocalDate.now().getYear() - customer.getDateOfBirth().getYear();
        return age >= 0 && age <= 120;
    }

    private String generateMemberId(Customer customer) {
        return "MBR" + customer.getCustomerNumber() + LocalDate.now().getYear();
    }
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentServiceImpl.java"

# =============================================================================
# MAPPERS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Mappers...${NC}"

MAPPER_DIR="$BASE_DIR/customer-service-core/src/main/java/com/healthcare/customer/service/mapper"
mkdir -p "$MAPPER_DIR"

cat > "$MAPPER_DIR/CustomerMapper.java" << 'EOF'
package com.healthcare.customer.service.mapper;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.common.model.*;
import org.mapstruct.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface CustomerMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customerNumber", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "emailVerified", ignore = true)
    @Mapping(target = "phoneVerified", ignore = true)
    @Mapping(target = "ssnEncrypted", ignore = true)
    @Mapping(target = "addresses", ignore = true)
    @Mapping(target = "dependents", ignore = true)
    @Mapping(target = "documents", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Customer toEntity(CreateCustomerRequest request);

    @Mapping(target = "fullName", expression = "java(customer.getFullName())")
    CustomerResponse toResponse(Customer customer);

    @Mapping(target = "fullName", expression = "java(customer.getFullName())")
    @Mapping(target = "addresses", source = "addresses")
    @Mapping(target = "dependents", source = "dependents")
    @Mapping(target = "enrollments", source = "enrollments")
    @Mapping(target = "documentCount", ignore = true)
    CustomerDetailResponse toDetailResponse(Customer customer);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customerNumber", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "dateOfBirth", ignore = true)
    @Mapping(target = "ssnLast4", ignore = true)
    @Mapping(target = "ssnEncrypted", ignore = true)
    @Mapping(target = "emailVerified", ignore = true)
    @Mapping(target = "phoneVerified", ignore = true)
    @Mapping(target = "addresses", ignore = true)
    @Mapping(target = "dependents", ignore = true)
    @Mapping(target = "documents", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget Customer customer, UpdateCustomerRequest request);

    // Address mappings
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "isVerified", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Address toAddressEntity(AddressRequest request);

    AddressResponse toAddressResponse(Address address);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "isVerified", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateAddressEntity(@MappingTarget Address address, AddressRequest request);

    // Dependent mappings
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Dependent toDependentEntity(DependentRequest request);

    @Mapping(target = "fullName", expression = "java(dependent.getFullName())")
    DependentResponse toDependentResponse(Dependent dependent);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateDependentEntity(@MappingTarget Dependent dependent, DependentRequest request);

    // Collection mappings
    default List<AddressResponse> mapAddresses(Set<Address> addresses) {
        if (addresses == null) return null;
        return addresses.stream().map(this::toAddressResponse).collect(Collectors.toList());
    }

    default List<DependentResponse> mapDependents(Set<Dependent> dependents) {
        if (dependents == null) return null;
        return dependents.stream().map(this::toDependentResponse).collect(Collectors.toList());
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerMapper.java"

cat > "$MAPPER_DIR/EnrollmentMapper.java" << 'EOF'
package com.healthcare.customer.service.mapper;

import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import com.healthcare.customer.common.model.EligibilityCheck;
import org.mapstruct.*;

import java.math.BigDecimal;
import java.util.Set;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface EnrollmentMapper {

    @Mapping(target = "customerId", source = "customer.id")
    EligibilityResponse toEligibilityResponse(EligibilityCheck check);

    @Mapping(target = "netPremium", expression = "java(calculateNetPremium(enrollment))")
    EnrollmentResponse toEnrollmentResponse(CustomerPlanEnrollment enrollment);

    default List<EnrollmentResponse> mapEnrollments(Set<CustomerPlanEnrollment> enrollments) {
        if (enrollments == null) return null;
        return enrollments.stream().map(this::toEnrollmentResponse).collect(Collectors.toList());
    }

    default BigDecimal calculateNetPremium(CustomerPlanEnrollment enrollment) {
        if (enrollment.getMonthlyPremium() == null) return null;
        BigDecimal subsidy = enrollment.getSubsidyAmount() != null ? enrollment.getSubsidyAmount() : BigDecimal.ZERO;
        return enrollment.getMonthlyPremium().subtract(subsidy);
    }
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentMapper.java"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Part 2 Complete - DAO & Service Layers Created!                          ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run setup-customer-service-java-part3.sh${NC}"