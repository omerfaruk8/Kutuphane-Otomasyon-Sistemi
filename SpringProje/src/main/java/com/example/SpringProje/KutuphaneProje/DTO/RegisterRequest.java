package com.example.SpringProje.KutuphaneProje.DTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Yeni kullanıcı kaydı için gerekli olan bilgileri ve
 * giriş validasyon kurallarını barındıran veri transfer nesnesi.
 */
public class RegisterRequest {

    @NotBlank(message = "Ad Soyad alanı boş geçilemez.")
    private String adSoyad;

    @NotBlank(message = "E-posta alanı boş geçilemez.")
    @Pattern(
            regexp = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$",
            message = "Lütfen geçerli bir e-posta adresi giriniz. (Türkçe karakter içermemelidir)"
    )
    private String email;

    @NotBlank(message = "Şifre alanı boş geçilemez.")
    @Size(min = 6, message = "Şifre güvenliğiniz için en az 6 karakter olmalıdır.")
    private String password;

    public RegisterRequest() {}

    public RegisterRequest(String adSoyad, String email, String password) {
        this.adSoyad = adSoyad;
        this.email = email;
        this.password = password;
    }

    public String getAdSoyad() { return adSoyad; }
    public void setAdSoyad(String adSoyad) { this.adSoyad = adSoyad; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}