package com.example.SpringProje.KutuphaneProje.DataAccess;

import com.example.SpringProje.KutuphaneProje.Entities.CalismaOdasi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ICalismaOdasiRepository extends JpaRepository<CalismaOdasi,Integer> {

    List<CalismaOdasi> findByOdaTipi(String odaTipi);// sesli / sessiz

}
