package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;

import java.time.LocalDate;

/**
 * Kullanıcı ihlalleri, ceza puanı hesaplamaları ve gecikmiş teslimatların
 * otomatik kontrol süreçlerini tanımlayan servis arayüzü.
 */
public interface IKullaniciCezaService {

    void cezaEkle(Kullanici kullanici, int puan);

    boolean cezaliMi(Kullanici kullanici);

    int getKullaniciCezaPuani(Kullanici kullanici);

    LocalDate getCezaBitisTarihi(Kullanici kullanici);
    void cezaKaldir(int kullaniciId);
    void gecTeslimCezasiKontrol();
}
