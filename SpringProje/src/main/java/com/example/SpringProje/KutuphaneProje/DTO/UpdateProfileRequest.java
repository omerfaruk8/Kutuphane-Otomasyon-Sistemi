package com.example.SpringProje.KutuphaneProje.DTO;

/**
 * Mevcut kullanıcının profil bilgilerini güncellemek için
 * kullanılan veri transfer nesnesidir. Şifre alanı boş bırakıldığında
 * sistem mevcut şifreyi korumaya devam eder.
 */
public class UpdateProfileRequest {

    private String adSoyad;
    private String password;

    public UpdateProfileRequest() {
    }

    public UpdateProfileRequest(String adSoyad, String password) {
        this.adSoyad = adSoyad;
        this.password = password;
    }

    public String getAdSoyad() {
        return adSoyad;
    }

    public void setAdSoyad(String adSoyad) {
        this.adSoyad = adSoyad;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}