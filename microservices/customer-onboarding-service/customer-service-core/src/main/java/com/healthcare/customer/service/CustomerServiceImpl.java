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
