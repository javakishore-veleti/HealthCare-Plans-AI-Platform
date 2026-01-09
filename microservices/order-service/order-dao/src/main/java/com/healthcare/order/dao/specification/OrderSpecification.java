package com.healthcare.order.dao.specification;

import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.model.Order;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class OrderSpecification {

    public static Specification<Order> buildSpecification(OrderSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getCustomerId() != null) {
                predicates.add(cb.equal(root.get("customerId"), request.getCustomerId()));
            }

            if (StringUtils.hasText(request.getOrderNumber())) {
                predicates.add(cb.equal(root.get("orderNumber"), request.getOrderNumber()));
            }

            if (request.getStatus() != null) {
                predicates.add(cb.equal(root.get("status"), request.getStatus()));
            }

            if (request.getOrderType() != null) {
                predicates.add(cb.equal(root.get("orderType"), request.getOrderType()));
            }

            if (request.getFromDate() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"),
                    request.getFromDate().atStartOfDay()));
            }

            if (request.getToDate() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"),
                    request.getToDate().atTime(LocalTime.MAX)));
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
