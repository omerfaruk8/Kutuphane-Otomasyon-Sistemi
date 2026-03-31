package com.example.SpringProje.KutuphaneProje.Entities;

import jakarta.persistence.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "kullanici")
public class Kullanici implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "kullaniciid")
    private int kullaniciId;

    @Column(name = "ad_soyad")
    private String adSoyad;

    @Column(name = "email")
    private String email;

    @Column(name = "password")
    private String password;

    public Kullanici(int kullaniciId, String adSoyad, String email, String password) {
        this.kullaniciId = kullaniciId;
        this.adSoyad = adSoyad;
        this.email = email;
        this.password = password;
    }

    public Kullanici() {
    }


    public int getKullaniciId() {
        return kullaniciId;
    }

    public void setKullaniciId(int kullaniciId) {
        this.kullaniciId = kullaniciId;
    }

    public String getAdSoyad() {
        return adSoyad;
    }

    public void setAdSoyad(String adSoyad) {
        this.adSoyad = adSoyad;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Uygulama içindeki yetkilendirme için standart kullanıcı rolü tanımlanıyor.
        return List.of(new SimpleGrantedAuthority("ROLE_USER"));
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        // Giriş işlemlerinde benzersiz anahtar olarak e-posta adresi kullanılıyor.
        return this.email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // Hesap süresi dolmadı
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // Hesap kilitli değil
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // Şifre süresi dolmadı
    }

    @Override
    public boolean isEnabled() {
        return true; // Hesap aktif
    }
}