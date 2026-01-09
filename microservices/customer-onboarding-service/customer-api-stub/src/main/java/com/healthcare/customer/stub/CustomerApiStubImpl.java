package com.healthcare.customer.stub;

import com.healthcare.customer.client.CustomerApiClient;
import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CustomerApiStubImpl implements CustomerApiClient {

    private final CustomerService customerService;

    @Override
    public CustomerDetailResponse createCustomer(CreateCustomerRequest request) {
        return customerService.createCustomer(request);
    }

    @Override
    public CustomerDetailResponse getCustomerById(UUID customerId) {
        return customerService.getCustomerById(customerId);
    }

    @Override
    public CustomerDetailResponse getCustomerByEmail(String email) {
        return customerService.getCustomerByEmail(email);
    }

    @Override
    public PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request) {
        return customerService.searchCustomers(request);
    }

    @Override
    public CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request) {
        return customerService.updateCustomer(customerId, request);
    }

    @Override
    public void deleteCustomer(UUID customerId) {
        customerService.deleteCustomer(customerId);
    }

    @Override
    public void activateCustomer(UUID customerId) {
        customerService.activateCustomer(customerId);
    }

    @Override
    public boolean isEmailAvailable(String email) {
        return customerService.isEmailAvailable(email);
    }
}
