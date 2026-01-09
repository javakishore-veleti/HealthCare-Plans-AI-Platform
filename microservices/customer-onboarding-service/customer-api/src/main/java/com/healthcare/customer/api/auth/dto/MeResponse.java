package com.healthcare.customer.api.auth.dto;

import com.healthcare.customer.api.profile.dto.ProfileDto;
import java.util.List;

public class MeResponse {
    
    private UserDto user;
    private List<ProfileDto> profiles;
    
    public MeResponse() {}
    
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
    
    public List<ProfileDto> getProfiles() { return profiles; }
    public void setProfiles(List<ProfileDto> profiles) { this.profiles = profiles; }
}
