package com.example.SpringProje.KutuphaneProje.DTO;

/**
 * Kimlik doğrulama işlemi sonrası dönülen, kullanıcı detaylarını
 * ve yetki bilgilerini içeren alternatif veri transfer nesnesi.
 */
public class AuthResponse {

    private String token;
    private int kullaniciId;
    private String adSoyad;
    private String email;
    private String role;

    public AuthResponse() {
    }

    public AuthResponse(String token, int kullaniciId, String adSoyad, String email, String role) {
        this.token = token;
        this.kullaniciId = kullaniciId;
        this.adSoyad = adSoyad;
        this.email = email;
        this.role = role;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public int getKullaniciId() { return kullaniciId; }
    public void setKullaniciId(int kullaniciId) { this.kullaniciId = kullaniciId; }

    public String getAdSoyad() { return adSoyad; }
    public void setAdSoyad(String adSoyad) { this.adSoyad = adSoyad; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}