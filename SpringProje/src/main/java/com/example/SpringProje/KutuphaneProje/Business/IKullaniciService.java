package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.DTO.UpdateProfileRequest;

import java.util.List;
import java.util.Optional;

/**
 * Sistemdeki kullanıcıların kayıt, profil güncelleme ve arama gibi
 * temel hesap yönetim süreçlerini tanımlayan servis arayüzü.
 */
public interface IKullaniciService {

    List<Kullanici> getAll();
    Kullanici getById(int id);
    void add(Kullanici kullanici);
    void update(Kullanici kullanici);
    void delete(int id);

    Optional<Kullanici> getByEmail(String email);

    boolean emailExists(String email);

    List<Kullanici> searchByName(String keyword);

    void updateProfile(int id, UpdateProfileRequest request);

}
