package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.MasaRezervasyon;
import com.example.SpringProje.KutuphaneProje.Enums.MasaSeans;
import com.example.SpringProje.KutuphaneProje.DTO.GrupRezervasyonRequest;

import java.time.LocalDate;
import java.util.List;

/**
 * Kütüphane bünyesindeki masa ve çalışma odası rezervasyonlarının,
 * grup işlemlerinin, check-in süreçlerinin ve otomatik kontrol
 * mekanizmalarının yönetildiği servis arayüzü.
 */
public interface IMasaRezervasyonService {

    List<MasaRezervasyon> getAll();

    MasaRezervasyon getById(int id);

    void add(MasaRezervasyon masaRezervasyon);

    void update(MasaRezervasyon masaRezervasyon);

    void delete(int id);

    List<MasaRezervasyon> getByRoomId(int odaId);

    boolean isChairReserved(int odaId, int sandalyeNo, MasaSeans seans, LocalDate tarih);

    List<MasaRezervasyon> getActiveReservations();

    void cancelReservation(int rezervasyonId);

    List<MasaRezervasyon> getByKullaniciId(int kullaniciId);

    void grupRezervasyonuYap(String girisYapanEmail, List<GrupRezervasyonRequest.RezervasyonItem> rezervasyonlar);

    void pasiflestirGecmisRezervasyonlar();

    void reddetRezervasyon(int id);

    void onaylaRezervasyon(int id);

    void kullaniciGirisYapti(int kullaniciId);

    void cezaKontrolu();
}