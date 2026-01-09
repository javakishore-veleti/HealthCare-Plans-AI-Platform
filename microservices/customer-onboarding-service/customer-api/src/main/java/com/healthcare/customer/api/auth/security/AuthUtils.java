package com.healthcare.customer.api.auth.security;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

public class AuthUtils {
    
    public static UserAccount getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserAccount) {
            return (UserAccount) authentication.getPrincipal();
        }
        return null;
    }
    
    public static UUID getCurrentUserId() {
        UserAccount user = getCurrentUser();
        return user != null ? user.getId() : null;
    }
    
    public static boolean isAuthenticated() {
        return getCurrentUser() != null;
    }
}
