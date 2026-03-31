package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.MasaRezervasyon;
import com.example.SpringProje.KutuphaneProje.Enums.MasaSeans;
import com.example.SpringProje.KutuphaneProje.Enums.RezervasyonDurum;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface IMasaRezervasyonRepository extends JpaRepository<MasaRezervasyon, Integer> {

    // Kullanıcının aktif ve geçmiş tüm rezervasyonlarını listeler.
    List<MasaRezervasyon> findByKullanici_KullaniciId(int kullaniciId);

    // Belirli bir oda, sandalye ve saat dilimindeki doluluk durumunu kontrol eder.
    Optional<MasaRezervasyon> findByCalismaOdasi_OdaIdAndSandalyeNoAndTarihAndSeansAndDurum(
            int odaId, int sandalyeNo, LocalDate tarih, MasaSeans seans, RezervasyonDurum durum
    );

    // Bir kullanıcının aynı zaman dilimi içerisinde çakışan başka bir rezervasyonu olup olmadığını sorgular.
    List<MasaRezervasyon> findByKullanici_KullaniciIdAndTarihAndSeans(
            int kullaniciId, LocalDate tarih, MasaSeans seans
    );

    List<MasaRezervasyon> findByDurum(RezervasyonDurum durum);
    List<MasaRezervasyon> findByTarihBeforeAndDurum(LocalDate tarih, RezervasyonDurum durum);
    List<MasaRezervasyon> findByTarihAndDurum(LocalDate tarih, RezervasyonDurum durum);
    List<MasaRezervasyon> findByCalismaOdasi_OdaId(int odaId);
}