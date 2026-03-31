package com.example.SpringProje.KutuphaneProje.DTO;

import java.time.LocalDate;
import java.util.List;

/**
 * Toplu masa rezervasyonu taleplerinde, istemciden gelen verileri
 * hiyerarşik bir yapıda karşılayan veri transfer nesnesidir.
 */
public class GrupRezervasyonRequest {

    private String girisYapanEmail;
    private List<RezervasyonItem> rezervasyonlar;

    public String getGirisYapanEmail() {
        return girisYapanEmail;
    }

    public void setGirisYapanEmail(String girisYapanEmail) {
        this.girisYapanEmail = girisYapanEmail;
    }

    public List<RezervasyonItem> getRezervasyonlar() {
        return rezervasyonlar;
    }

    public void setRezervasyonlar(List<RezervasyonItem> rezervasyonlar) {
        this.rezervasyonlar = rezervasyonlar;
    }

    /**
     * Her bir bireysel rezervasyon kalemini temsil eden iç sınıf.
     */
    public static class RezervasyonItem {
        public KullaniciIdTasiyici kullanici;
        public OdaIdTasiyici calismaOdasi;
        public int sandalyeNo;
        public String seans;
        public LocalDate tarih;
    }

    public static class KullaniciIdTasiyici {
        public int kullaniciId;
    }

    public static class OdaIdTasiyici {
        public int odaId;
    }
}