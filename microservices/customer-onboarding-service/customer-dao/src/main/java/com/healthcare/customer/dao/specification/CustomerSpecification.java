package com.healthcare.customer.dao.specification;

import com.healthcare.customer.common.dto.request.CustomerSearchRequest;
import com.healthcare.customer.common.model.Address;
import com.healthcare.customer.common.model.Customer;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

public class CustomerSpecification {

    public static Specification<Customer> buildSpecification(CustomerSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (StringUtils.hasText(request.getEmail())) {
                predicates.add(cb.equal(cb.lower(root.get("email")), request.getEmail().toLowerCase()));
            }

            if (StringUtils.hasText(request.getPhone())) {
                predicates.add(cb.or(
                    cb.equal(root.get("phone"), request.getPhone()),
                    cb.equal(root.get("mobilePhone"), request.getPhone())
                ));
            }

            if (StringUtils.hasText(request.getFirstName())) {
                predicates.add(cb.like(cb.lower(root.get("firstName")), 
                    "%" + request.getFirstName().toLowerCase() + "%"));
            }

            if (StringUtils.hasText(request.getLastName())) {
                predicates.add(cb.like(cb.lower(root.get("lastName")), 
                    "%" + request.getLastName().toLowerCase() + "%"));
            }

            if (StringUtils.hasText(request.getCustomerNumber())) {
                predicates.add(cb.equal(root.get("customerNumber"), request.getCustomerNumber()));
            }

            if (request.getStatus() != null) {
                predicates.add(cb.equal(root.get("status"), request.getStatus()));
            }

            if (StringUtils.hasText(request.getStateCode()) || StringUtils.hasText(request.getZipCode())) {
                Join<Customer, Address> addressJoin = root.join("addresses", JoinType.INNER);
                addressJoin.on(cb.isTrue(addressJoin.get("isPrimary")));

                if (StringUtils.hasText(request.getStateCode())) {
                    predicates.add(cb.equal(addressJoin.get("stateCode"), request.getStateCode()));
                }

                if (StringUtils.hasText(request.getZipCode())) {
                    predicates.add(cb.equal(addressJoin.get("zipCode"), request.getZipCode()));
                }
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
