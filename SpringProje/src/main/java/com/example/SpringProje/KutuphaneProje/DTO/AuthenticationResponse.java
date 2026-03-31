package com.example.SpringProje.KutuphaneProje.DTO;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Kimlik doğrulama işlemi sonrası istemciye iletilecek
 * yetki ve kullanıcı bilgilerini taşıyan nesne.
 */
public class AuthenticationResponse {

    @JsonProperty("token")
    private String token;

    @JsonProperty("userId")
    private int userId;

    @JsonProperty("adSoyad")
    private String adSoyad;

    @JsonProperty("role")
    private String role;

    public AuthenticationResponse() {
    }

    public AuthenticationResponse(String token, int userId, String adSoyad, String role) {
        this.token = token;
        this.userId = userId;
        this.adSoyad = adSoyad;
        this.role = role;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAdSoyad() { return adSoyad; }
    public void setAdSoyad(String adSoyad) { this.adSoyad = adSoyad; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}