package com.healthcare.order.service;

import java.math.BigDecimal;
import java.util.UUID;

public interface ExternalServiceClient {

    CustomerInfo getCustomerInfo(UUID customerId);

    PlanInfo getPlanInfo(UUID planId);

    record CustomerInfo(
            String fullName,
            String email,
            String customerNumber
    ) {}

    record PlanInfo(
            String planCode,
            String planName,
            String metalTier,
            Integer planYear,
            BigDecimal monthlyPremium
    ) {}
}