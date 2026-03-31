package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface IKullaniciRepository extends JpaRepository<Kullanici,Integer> {

    Optional<Kullanici> findByEmail(String email);

    boolean existsByEmail(String email);
    List<Kullanici> findByAdSoyadContaining(String keyword);
}
