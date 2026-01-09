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
