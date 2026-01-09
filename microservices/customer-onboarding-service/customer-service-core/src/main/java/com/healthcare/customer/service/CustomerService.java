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
