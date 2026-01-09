package com.healthcare.customer.api.profile.controller;

import com.healthcare.customer.api.auth.security.AuthUtils;
import com.healthcare.customer.api.profile.dto.*;
import com.healthcare.customer.api.profile.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/profiles")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001"})
public class ProfileController {
    
    private final ProfileService profileService;
    
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }
    
    @GetMapping
    public ResponseEntity<List<ProfileDto>> getProfiles() {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        List<ProfileDto> profiles = profileService.getProfilesByUserId(userId);
        return ResponseEntity.ok(profiles);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProfileDto> getProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.getProfileById(id, userId);
        return ResponseEntity.ok(profile);
    }
    
    @PostMapping
    public ResponseEntity<ProfileDto> createProfile(@Valid @RequestBody CreateProfileRequest request) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.createProfile(request, userId);
        return ResponseEntity.ok(profile);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ProfileDto> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateProfileRequest request) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.updateProfile(id, request, userId);
        return ResponseEntity.ok(profile);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        profileService.deleteProfile(id, userId);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Profile deleted successfully");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{id}/set-primary")
    public ResponseEntity<ProfileDto> setPrimaryProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.setPrimaryProfile(id, userId);
        return ResponseEntity.ok(profile);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getProfileStats() {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("count", profileService.getProfileCount(userId));
        stats.put("maxAllowed", profileService.getMaxProfilesPerUser());
        stats.put("canAddMore", profileService.getProfileCount(userId) < profileService.getMaxProfilesPerUser());
        
        return ResponseEntity.ok(stats);
    }
}
