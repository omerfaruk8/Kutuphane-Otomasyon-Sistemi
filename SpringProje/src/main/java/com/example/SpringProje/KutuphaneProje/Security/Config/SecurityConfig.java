package com.example.SpringProje.KutuphaneProje.Security.Config;

import com.example.SpringProje.KutuphaneProje.Security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Uygulamanın HTTP güvenlik yapılandırmalarını, yetkilendirme kurallarını
 * ve JWT filtre entegrasyonunu yöneten konfigürasyon sınıfıdır.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter, AuthenticationProvider authenticationProvider) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.authenticationProvider = authenticationProvider;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> {})
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/login/**",
                                "/api/register/**",
                                "/api/admin-login/**",
                                "/api/admins/add",
                                "/error",
                                "/api/kitaplar",
                                "/api/kitaplar/**",
                                "/api/odalar",
                                "/api/odalar/**"
                        ).permitAll()
                        .requestMatchers(
                                "/api/admins/**",
                                "/api/odalar/add",
                                "/api/odalar/delete/**",
                                "/api/borrows/approve/**",
                                "/api/borrows/reject/**",
                                "/api/borrows/return/**",
                                "/api/borrows/pending/**",
                                "/api/borrows/active-borrows/**",
                                "/api/reservations/active"
                        ).hasAuthority("ROLE_ADMIN")
                        .anyRequest().authenticated()
                )
                .sessionManagement(sess -> sess
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authenticationProvider(authenticationProvider)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}