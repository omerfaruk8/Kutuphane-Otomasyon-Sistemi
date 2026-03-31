package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.Entities.KullaniciCeza;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface IKullaniciCezaRepository extends JpaRepository<KullaniciCeza, Long> {
    Optional<KullaniciCeza> findByKullanici(Kullanici kullanici);
}
