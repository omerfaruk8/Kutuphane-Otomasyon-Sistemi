package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.Kitap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IKitapRepository extends JpaRepository<Kitap,Integer> {

    List<Kitap> findByKategori(String kategori);
    List<Kitap> findByKitapAdiContaining(String keyword);
    List<Kitap> findByMusaitAdetGreaterThan(int adet);


}
