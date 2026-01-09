package com.healthcare.customer.service.mapper;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.common.model.*;
import org.mapstruct.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface CustomerMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customerNumber", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "emailVerified", ignore = true)
    @Mapping(target = "phoneVerified", ignore = true)
    @Mapping(target = "ssnEncrypted", ignore = true)
    @Mapping(target = "addresses", ignore = true)
    @Mapping(target = "dependents", ignore = true)
    @Mapping(target = "documents", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Customer toEntity(CreateCustomerRequest request);

    @Mapping(target = "fullName", expression = "java(customer.getFullName())")
    CustomerResponse toResponse(Customer customer);

    @Mapping(target = "fullName", expression = "java(customer.getFullName())")
    @Mapping(target = "addresses", source = "addresses")
    @Mapping(target = "dependents", source = "dependents")
    @Mapping(target = "enrollments", source = "enrollments")
    @Mapping(target = "documentCount", ignore = true)
    CustomerDetailResponse toDetailResponse(Customer customer);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customerNumber", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "dateOfBirth", ignore = true)
    @Mapping(target = "ssnLast4", ignore = true)
    @Mapping(target = "ssnEncrypted", ignore = true)
    @Mapping(target = "emailVerified", ignore = true)
    @Mapping(target = "phoneVerified", ignore = true)
    @Mapping(target = "addresses", ignore = true)
    @Mapping(target = "dependents", ignore = true)
    @Mapping(target = "documents", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget Customer customer, UpdateCustomerRequest request);

    // Address mappings
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "isVerified", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Address toAddressEntity(AddressRequest request);

    AddressResponse toAddressResponse(Address address);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "isVerified", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateAddressEntity(@MappingTarget Address address, AddressRequest request);

    // Dependent mappings
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Dependent toDependentEntity(DependentRequest request);

    @Mapping(target = "fullName", expression = "java(dependent.getFullName())")
    DependentResponse toDependentResponse(Dependent dependent);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "customer", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateDependentEntity(@MappingTarget Dependent dependent, DependentRequest request);

    // Collection mappings
    default List<AddressResponse> mapAddresses(Set<Address> addresses) {
        if (addresses == null) return null;
        return addresses.stream().map(this::toAddressResponse).collect(Collectors.toList());
    }

    default List<DependentResponse> mapDependents(Set<Dependent> dependents) {
        if (dependents == null) return null;
        return dependents.stream().map(this::toDependentResponse).collect(Collectors.toList());
    }
}
