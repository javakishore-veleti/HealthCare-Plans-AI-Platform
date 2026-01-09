package com.healthcare.plans.api.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.List;

public class CompareRequest {
    
    @NotEmpty(message = "Plan IDs are required")
    @Size(min = 2, max = 4, message = "Select between 2 and 4 plans to compare")
    private List<String> planIds;
    
    public List<String> getPlanIds() { return planIds; }
    public void setPlanIds(List<String> planIds) { this.planIds = planIds; }
}
