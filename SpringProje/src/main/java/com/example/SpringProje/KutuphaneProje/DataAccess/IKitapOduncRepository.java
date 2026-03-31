package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.KitapOdunc;
import com.example.SpringProje.KutuphaneProje.Enums.OduncDurum;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface IKitapOduncRepository extends JpaRepository<KitapOdunc, Integer> {
    List<KitapOdunc> findByKullanici_KullaniciId(int kullaniciId);
    List<KitapOdunc> findByDurum(OduncDurum durum);
    List<KitapOdunc> findByBitisTarihiBeforeAndDurum(LocalDate tarih, OduncDurum durum);
}