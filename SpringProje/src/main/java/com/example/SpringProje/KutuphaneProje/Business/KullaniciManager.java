package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IKullaniciRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.DTO.UpdateProfileRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class KullaniciManager implements IKullaniciService {

    private final IKullaniciRepository kullaniciRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public KullaniciManager(IKullaniciRepository kullaniciRepository, PasswordEncoder passwordEncoder) {
        this.kullaniciRepository = kullaniciRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public List<Kullanici> getAll() {
        return this.kullaniciRepository.findAll();
    }

    @Override
    public Kullanici getById(int id) {
        return kullaniciRepository.findById(id).orElse(null);
    }

    @Override
    @Transactional
    public void add(Kullanici kullanici) {
        kullanici.setPassword(passwordEncoder.encode(kullanici.getPassword()));
        kullaniciRepository.save(kullanici);
    }

    @Override
    @Transactional
    public void update(Kullanici kullanici) {
        kullaniciRepository.save(kullanici);
    }

    @Override
    @Transactional
    public void delete(int id) {
        kullaniciRepository.deleteById(id);
    }

    @Override
    public Optional<Kullanici> getByEmail(String email) {
        return kullaniciRepository.findByEmail(email);
    }

    @Override
    public boolean emailExists(String email) {
        return kullaniciRepository.existsByEmail(email);
    }

    @Override
    public List<Kullanici> searchByName(String keyword) {
        return kullaniciRepository.findByAdSoyadContaining(keyword);
    }

    @Override
    @Transactional
    public void updateProfile(int id, UpdateProfileRequest request) {
        Kullanici user = kullaniciRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Güncellenecek kullanıcı kaydı bulunamadı."));

        if (request.getAdSoyad() != null && !request.getAdSoyad().isEmpty()) {
            user.setAdSoyad(request.getAdSoyad());
        }

        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            if (request.getPassword().length() < 6) {
                throw new RuntimeException("Yeni şifre güvenlik gereği en az 6 karakterden oluşmalıdır.");
            }
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        kullaniciRepository.save(user);
    }
}