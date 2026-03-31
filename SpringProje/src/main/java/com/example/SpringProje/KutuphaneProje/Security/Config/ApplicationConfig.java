package com.example.SpringProje.KutuphaneProje.Security.Config;

import com.example.SpringProje.KutuphaneProje.Security.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.crypto.password.DelegatingPasswordEncoder;
import java.util.HashMap;
import java.util.Map;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

/**
 * Uygulamanın kimlik doğrulama stratejisini, şifreleme yöntemlerini
 * ve kullanıcı detay servislerini yapılandıran ana güvenlik sınıfıdır.
 */
@Configuration
public class ApplicationConfig {

    private final CustomUserDetailsService userDetailsService;

    public ApplicationConfig(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    /**
     * Veritabanı tabanlı kimlik doğrulama işlemini gerçekleştiren sağlayıcıdır.
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * Kimlik doğrulama süreçlerini merkezi olarak yöneten AuthenticationManager bean'i.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * DelegatingPasswordEncoder kullanarak hem BCrypt hem de SHA-256
     * tabanlı şifrelemeleri destekleyen yapılandırma.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        String defaultEncoding = "bcrypt";
        Map<String, PasswordEncoder> encoders = new HashMap<>();

        encoders.put(defaultEncoding, new BCryptPasswordEncoder());

        // Legacy (SHA-256) şifreleme desteği
        encoders.put("sha256", new PasswordEncoder() {
            @Override
            public String encode(CharSequence rawPassword) {
                return calculateSha256(rawPassword.toString());
            }

            @Override
            public boolean matches(CharSequence rawPassword, String encodedPassword) {
                return calculateSha256(rawPassword.toString()).equals(encodedPassword);
            }

            private String calculateSha256(String raw) {
                try {
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hash = md.digest(raw.getBytes(StandardCharsets.UTF_8));
                    StringBuilder hexString = new StringBuilder();
                    for (byte b : hash) {
                        String hex = Integer.toHexString(0xff & b);
                        if (hex.length() == 1) hexString.append('0');
                        hexString.append(hex);
                    }
                    return hexString.toString();
                } catch (Exception e) {
                    return null;
                }
            }
        });

        DelegatingPasswordEncoder encoder = new DelegatingPasswordEncoder(defaultEncoding, encoders);
        encoder.setDefaultPasswordEncoderForMatches(new BCryptPasswordEncoder());

        return encoder;
    }
}