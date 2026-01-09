package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.AddressRequest;
import com.healthcare.customer.common.dto.response.AddressResponse;
import com.healthcare.customer.service.AddressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/customers/{customerId}/addresses")
@RequiredArgsConstructor
@Tag(name = "Address", description = "Customer address management APIs")
public class AddressController {

    private final AddressService addressService;

    @PostMapping
    @Operation(summary = "Add address", description = "Add a new address for a customer")
    public ResponseEntity<AddressResponse> addAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody AddressRequest request) {
        AddressResponse response = addressService.addAddress(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get addresses", description = "Get all addresses for a customer")
    public ResponseEntity<List<AddressResponse>> getAddresses(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<AddressResponse> responses = addressService.getCustomerAddresses(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/primary")
    @Operation(summary = "Get primary address", description = "Get the primary address for a customer")
    public ResponseEntity<AddressResponse> getPrimaryAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        AddressResponse response = addressService.getPrimaryAddress(customerId);
        if (response == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{addressId}")
    @Operation(summary = "Update address", description = "Update an existing address")
    public ResponseEntity<AddressResponse> updateAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId,
            @Valid @RequestBody AddressRequest request) {
        AddressResponse response = addressService.updateAddress(customerId, addressId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{addressId}")
    @Operation(summary = "Delete address", description = "Delete an address")
    public ResponseEntity<Void> deleteAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId) {
        addressService.deleteAddress(customerId, addressId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{addressId}/set-primary")
    @Operation(summary = "Set primary address", description = "Set an address as the primary address")
    public ResponseEntity<Void> setPrimaryAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId) {
        addressService.setPrimaryAddress(customerId, addressId);
        return ResponseEntity.ok().build();
    }
}
