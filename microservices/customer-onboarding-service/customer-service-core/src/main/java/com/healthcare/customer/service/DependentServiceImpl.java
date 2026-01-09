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
