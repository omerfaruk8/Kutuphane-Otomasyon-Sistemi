package com.example.SpringProje.KutuphaneProje.Entities;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class KullaniciCeza {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    private Kullanici kullanici;

    private LocalDate cezaBitisTarihi;

    private int ihlalSayisi;

    private LocalDate enSonCezaVerilenTarih;


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Kullanici getKullanici() {
        return kullanici;
    }

    public void setKullanici(Kullanici kullanici) {
        this.kullanici = kullanici;
    }

    public LocalDate getCezaBitisTarihi() {
        return cezaBitisTarihi;
    }

    public void setCezaBitisTarihi(LocalDate cezaBitisTarihi) {
        this.cezaBitisTarihi = cezaBitisTarihi;
    }

    public int getIhlalSayisi() {
        return ihlalSayisi;
    }

    public void setIhlalSayisi(int ihlalSayisi) {
        this.ihlalSayisi = ihlalSayisi;
    }

    public LocalDate getEnSonCezaVerilenTarih() {
        return enSonCezaVerilenTarih;
    }

    public void setEnSonCezaVerilenTarih(LocalDate enSonCezaVerilenTarih) {
        this.enSonCezaVerilenTarih = enSonCezaVerilenTarih;
    }
}
