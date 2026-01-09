package com.healthcare.order.api.config;

import com.healthcare.order.service.ExternalServiceClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Component
public class ExternalServiceClientImpl implements ExternalServiceClient {

    private final RestTemplate restTemplate;
    private final String plansServiceUrl;
    private final String customerServiceUrl;

    public ExternalServiceClientImpl(
            @Value("${plans.service.url:http://localhost:8081}") String plansServiceUrl,
            @Value("${customer.service.url:http://localhost:8083}") String customerServiceUrl) {
        this.restTemplate = new RestTemplate();
        this.plansServiceUrl = plansServiceUrl;
        this.customerServiceUrl = customerServiceUrl;
        log.info("External service clients initialized - Plans: {}, Customer: {}",
                plansServiceUrl, customerServiceUrl);
    }

    @Override
    @SuppressWarnings("unchecked")
    public CustomerInfo getCustomerInfo(UUID customerId) {
        try {
            String url = customerServiceUrl + "/api/v1/customers/" + customerId;
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response != null) {
                return new CustomerInfo(
                        (String) response.get("fullName"),
                        (String) response.get("email"),
                        (String) response.get("customerNumber")
                );
            }
        } catch (Exception e) {
            log.warn("Failed to fetch customer {}: {}", customerId, e.getMessage());
        }
        return null;
    }

    @Override
    @SuppressWarnings("unchecked")
    public PlanInfo getPlanInfo(UUID planId) {
        try {
            String url = plansServiceUrl + "/api/v1/plans/" + planId;
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response != null) {
                BigDecimal monthlyPremium = null;
                Object premiumObj = response.get("monthlyPremium");
                if (premiumObj != null) {
                    monthlyPremium = new BigDecimal(premiumObj.toString());
                }

                Integer year = null;
                Object yearObj = response.get("year");
                if (yearObj != null) {
                    year = Integer.parseInt(yearObj.toString());
                }

                return new PlanInfo(
                        (String) response.get("planCode"),
                        (String) response.get("planName"),
                        (String) response.get("metalTier"),
                        year != null ? year : java.time.LocalDate.now().getYear(),
                        monthlyPremium != null ? monthlyPremium : BigDecimal.valueOf(350.00)
                );
            }
        } catch (Exception e) {
            log.warn("Failed to fetch plan {}: {}", planId, e.getMessage());
        }
        return null;
    }
}