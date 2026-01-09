package com.healthcare.customer.api.profile.dto;

import com.healthcare.customer.dao.entity.profile.ProfileAddress;

public class AddressDto {
    
    private String street1;
    private String street2;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    
    public AddressDto() {}
    
    public static AddressDto fromEntity(ProfileAddress address) {
        AddressDto dto = new AddressDto();
        dto.setStreet1(address.getStreet1());
        dto.setStreet2(address.getStreet2());
        dto.setCity(address.getCity());
        dto.setState(address.getState());
        dto.setZipCode(address.getZipCode());
        dto.setCountry(address.getCountry());
        return dto;
    }
    
    // Getters and Setters
    public String getStreet1() { return street1; }
    public void setStreet1(String street1) { this.street1 = street1; }
    
    public String getStreet2() { return street2; }
    public void setStreet2(String street2) { this.street2 = street2; }
    
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    
    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }
    
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
}
