package com.healthcare.plans.dao.specification;

import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.model.Plan;
import com.healthcare.plans.common.model.PlanCategory;
import com.healthcare.plans.common.model.AgeGroup;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

public class PlanSpecification {

    public static Specification<Plan> buildSpecification(PlanSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getYear() != null) {
                predicates.add(cb.equal(root.get("year"), request.getYear()));
            }

            if (StringUtils.hasText(request.getStateCode())) {
                predicates.add(cb.or(
                    cb.equal(root.get("state").get("code"), request.getStateCode()),
                    cb.isTrue(root.get("isNational"))
                ));
            }

            if (request.getIsNational() != null && request.getIsNational()) {
                predicates.add(cb.isTrue(root.get("isNational")));
            }

            if (request.getPlanTypes() != null && !request.getPlanTypes().isEmpty()) {
                predicates.add(root.get("planType").in(request.getPlanTypes()));
            }

            if (request.getMetalTiers() != null && !request.getMetalTiers().isEmpty()) {
                predicates.add(root.get("metalTier").in(request.getMetalTiers()));
            }

            if (request.getStatuses() != null && !request.getStatuses().isEmpty()) {
                predicates.add(root.get("status").in(request.getStatuses()));
            } else {
                predicates.add(cb.equal(root.get("status"), PlanStatus.ACTIVE));
            }

            if (request.getMinPremium() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("monthlyPremium"), request.getMinPremium()));
            }
            if (request.getMaxPremium() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("monthlyPremium"), request.getMaxPremium()));
            }

            if (request.getMaxDeductible() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("annualDeductible"), request.getMaxDeductible()));
            }

            if (request.getCategoryIds() != null && !request.getCategoryIds().isEmpty()) {
                Join<Plan, PlanCategory> catJoin = root.join("categories", JoinType.INNER);
                predicates.add(catJoin.get("id").in(request.getCategoryIds()));
            }

            if (request.getAgeGroupIds() != null && !request.getAgeGroupIds().isEmpty()) {
                Join<Plan, AgeGroup> ageJoin = root.join("ageGroups", JoinType.INNER);
                predicates.add(ageJoin.get("id").in(request.getAgeGroupIds()));
            }

            if (StringUtils.hasText(request.getSearchTerm())) {
                String pattern = "%" + request.getSearchTerm().toLowerCase() + "%";
                predicates.add(cb.or(
                    cb.like(cb.lower(root.get("planName")), pattern),
                    cb.like(cb.lower(root.get("planCode")), pattern)
                ));
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
