package com.example.SpringProje.KutuphaneProje.Security;

import com.example.SpringProje.KutuphaneProje.DataAccess.IAdminRepository;
import com.example.SpringProje.KutuphaneProje.DataAccess.IKullaniciRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Admin;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Spring Security için özelleştirilmiş kullanıcı detay servisidir.
 * Hem standart kullanıcı (Kullanici) hem de yönetici (Admin) hesaplarını
 * e-posta üzerinden doğrular.
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final IKullaniciRepository kullaniciRepository;
    private final IAdminRepository adminRepository;

    public CustomUserDetailsService(IKullaniciRepository kullaniciRepository, IAdminRepository adminRepository) {
        this.kullaniciRepository = kullaniciRepository;
        this.adminRepository = adminRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Önce kullanıcı veritabanında ara
        Optional<Kullanici> kullanici = kullaniciRepository.findByEmail(username);
        if (kullanici.isPresent()) {
            return kullanici.get();
        }

        // Kullanıcı bulunamazsa yönetici veritabanında ara
        Optional<Admin> admin = adminRepository.findByEmail(username);
        if (admin.isPresent()) {
            return admin.get();
        }

        throw new UsernameNotFoundException("Belirtilen kimlik bilgileriyle eşleşen bir hesap bulunamadı: " + username);
    }
}