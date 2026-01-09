package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;

import java.util.UUID;

public interface CustomerApiClient {

    CustomerDetailResponse createCustomer(CreateCustomerRequest request);

    CustomerDetailResponse getCustomerById(UUID customerId);

    CustomerDetailResponse getCustomerByEmail(String email);

    PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request);

    CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request);

    void deleteCustomer(UUID customerId);

    void activateCustomer(UUID customerId);

    boolean isEmailAvailable(String email);
}
