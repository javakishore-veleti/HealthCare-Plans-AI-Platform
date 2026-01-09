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
