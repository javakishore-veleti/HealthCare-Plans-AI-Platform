package com.healthcare.plans.common.constants;

public enum PlanType {
    HMO("Health Maintenance Organization"),
    PPO("Preferred Provider Organization"),
    EPO("Exclusive Provider Organization"),
    POS("Point of Service"),
    HDHP("High Deductible Health Plan");

    private final String description;

    PlanType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
