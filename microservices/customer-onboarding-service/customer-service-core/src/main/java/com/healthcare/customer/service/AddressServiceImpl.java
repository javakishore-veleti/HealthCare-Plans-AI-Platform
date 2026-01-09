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
