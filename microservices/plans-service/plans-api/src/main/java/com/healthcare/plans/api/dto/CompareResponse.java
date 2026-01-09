package com.healthcare.plans.api.dto;

import com.healthcare.plans.common.model.Plan;
import java.util.List;

public class CompareResponse {
    
    private List<Plan> plans;
    
    public CompareResponse() {}
    
    public CompareResponse(List<Plan> plans) {
        this.plans = plans;
    }
    
    public List<Plan> getPlans() { return plans; }
    public void setPlans(List<Plan> plans) { this.plans = plans; }
}
