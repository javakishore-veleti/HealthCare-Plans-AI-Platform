package com.healthcare.plans.common.constants;

public enum MetalTier {
    BRONZE(60),
    SILVER(70),
    GOLD(80),
    PLATINUM(90);

    private final int coveragePercentage;

    MetalTier(int coveragePercentage) {
        this.coveragePercentage = coveragePercentage;
    }

    public int getCoveragePercentage() {
        return coveragePercentage;
    }
}
