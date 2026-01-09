package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequest {
    
    @NotBlank(message = "Token is required")
    private String token;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$", 
             message = "Password must contain at least one uppercase, one lowercase, and one number")
    private String password;
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
