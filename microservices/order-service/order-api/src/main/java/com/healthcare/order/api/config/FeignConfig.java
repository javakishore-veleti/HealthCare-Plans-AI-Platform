package com.healthcare.order.api.config;

import org.springframework.context.annotation.Configuration;

/**
 * Feign configuration - currently disabled in favor of RestTemplate.
 *
 * To enable Feign clients, uncomment the annotations below and ensure
 * all external services are available at startup.
 */
@Configuration
// @EnableFeignClients(basePackages = {
//     "com.healthcare.plans.client",
//     "com.healthcare.customer.client"
// })
public class FeignConfig {
    // Feign beans can be added here when enabled
}