package com.healthcare.plans.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.healthcare.plans")
@EntityScan(basePackages = "com.healthcare.plans.common.model")
@EnableJpaRepositories(basePackages = "com.healthcare.plans.dao.repository")
public class PlansApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlansApiApplication.class, args);
    }
}
