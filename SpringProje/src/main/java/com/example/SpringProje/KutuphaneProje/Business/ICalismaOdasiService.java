package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.CalismaOdasi;

import java.util.List;

/**
 * Kütüphane bünyesindeki çalışma odalarının ve kapasite bilgilerinin
 * yönetim süreçlerini tanımlayan servis arayüzü.
 */
public interface ICalismaOdasiService {

    List<CalismaOdasi> getAll();
    CalismaOdasi getById(int id);
    void add(CalismaOdasi calismaOdasi);
    void update(CalismaOdasi calismaOdasi);
    void delete(int id);

    List<CalismaOdasi> getByOdaTipi(String odaTipi);

}
