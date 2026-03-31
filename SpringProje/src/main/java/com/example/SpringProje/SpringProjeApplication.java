package com.example.SpringProje;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Kütüphane Otomasyon Sistemi'nin başlangıç noktasıdır.
 * Spring Boot uygulamasını ayağa kaldırır ve zamanlanmış
 * görevlerin (scheduling) çalışmasına izin verir.
 */
@SpringBootApplication
@EnableScheduling
public class SpringProjeApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringProjeApplication.class, args);
	}

}