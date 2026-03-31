package com.example.SpringProje.KutuphaneProje.Business.Auth;

import com.example.SpringProje.KutuphaneProje.Security.JwtService;
import com.example.SpringProje.KutuphaneProje.DataAccess.IKullaniciRepository;
import com.example.SpringProje.KutuphaneProje.DataAccess.IAdminRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.Entities.Admin;
import com.example.SpringProje.KutuphaneProje.DTO.RegisterRequest;
import com.example.SpringProje.KutuphaneProje.DTO.AuthenticationResponse;
import com.example.SpringProje.KutuphaneProje.DTO.LoginRequest;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;

/**
 * Kullanıcı ve yönetici kimlik doğrulama işlemlerini yöneten servis.
 * Kayıt olma, giriş yapma ve JWT üretimi süreçlerini kapsar.
 */
@Service
public class AuthenticationService {

    private final IKullaniciRepository repository;
    private final IAdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthenticationService(IKullaniciRepository repository, IAdminRepository adminRepository,
                                 PasswordEncoder passwordEncoder, JwtService jwtService,
                                 AuthenticationManager authenticationManager) {
        this.repository = repository;
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    public AuthenticationResponse register(RegisterRequest request) {
        Optional<Kullanici> existingUser = repository.findByEmail(request.getEmail());
        if (existingUser.isPresent()) {
            throw new RuntimeException("Bu e-posta adresi ile kayıtlı bir kullanıcı zaten mevcut.");
        }

        var user = new Kullanici();
        user.setAdSoyad(request.getAdSoyad());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        repository.save(user);

        var jwtToken = jwtService.generateToken(new HashMap<>(), user);
        return new AuthenticationResponse(jwtToken, user.getKullaniciId(), user.getAdSoyad(), "USER");
    }

    public AuthenticationResponse authenticate(LoginRequest request) {
        // Önce Kullanıcı tablosunda arama yapılıyor
        Optional<Kullanici> userOpt = repository.findByEmail(request.getEmail());
        if (userOpt.isPresent()) {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            var user = userOpt.get();
            var jwtToken = jwtService.generateToken(new HashMap<>(), user);
            return new AuthenticationResponse(jwtToken, user.getKullaniciId(), user.getAdSoyad(), "USER");
        }

        // Kullanıcı bulunamadıysa Yönetici tablosu kontrol ediliyor
        Optional<Admin> adminOpt = adminRepository.findByEmail(request.getEmail());
        if (adminOpt.isPresent()) {
            var admin = adminOpt.get();

            if (!passwordEncoder.matches(request.getPassword(), admin.getPassword())) {
                throw new RuntimeException("Geçersiz kimlik bilgileri.");
            }

            HashMap<String, Object> claims = new HashMap<>();
            claims.put("role", "ADMIN");

            var jwtToken = jwtService.generateToken(claims, admin);
            return new AuthenticationResponse(jwtToken, admin.getAdminId(), admin.getAdSoyad(), "ADMIN");
        }

        throw new RuntimeException("Geçersiz e-posta adresi veya şifre.");
    }
}