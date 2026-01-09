package com.healthcare.customer.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {
    "com.healthcare.customer"
})
@EntityScan(basePackages = {
    "com.healthcare.customer.dao.entity",
    "com.healthcare.customer.common.model"
})
@EnableJpaRepositories(basePackages = {
    "com.healthcare.customer.dao.repository"
})
public class CustomerApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(CustomerApiApplication.class, args);
    }
}
