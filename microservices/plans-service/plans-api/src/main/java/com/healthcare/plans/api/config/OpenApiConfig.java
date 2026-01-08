package com.healthcare.plans.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI plansServiceOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Plans Service API")
                .description("Healthcare Plans Management Service")
                .version("1.0.0"));
    }
}
