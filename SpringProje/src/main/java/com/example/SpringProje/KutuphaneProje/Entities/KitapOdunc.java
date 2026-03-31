package com.example.SpringProje.KutuphaneProje.Entities;

import com.example.SpringProje.KutuphaneProje.Enums.OduncDurum;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "kitap_odunc")
public class KitapOdunc {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "oduncid")
    private int oduncId;

    @ManyToOne
    @JoinColumn(name = "kullanici_id")
    private Kullanici kullanici;
    @ManyToOne
    @JoinColumn(name = "kitap_id")
    private Kitap kitap;

    @Column(name = "baslangic_tarihi")
    private LocalDate baslangicTarihi;
    @Column(name = "bitis_tarihi")
    private LocalDate bitisTarihi;

    @Enumerated(EnumType.STRING)
    @Column(name = "durum")
    private OduncDurum durum;


    public KitapOdunc(int oduncId, Kullanici kullanici, Kitap kitap, LocalDate baslangicTarihi, LocalDate bitisTarihi, OduncDurum durum) {
        this.oduncId = oduncId;
        this.kullanici = kullanici;
        this.kitap = kitap;
        this.baslangicTarihi = baslangicTarihi;
        this.bitisTarihi = bitisTarihi;
        this.durum = durum;
    }

    public KitapOdunc(){}

    public int getOduncId() {
        return oduncId;
    }

    public void setOduncId(int oduncId) {
        this.oduncId = oduncId;
    }

    public Kullanici getKullanici() {
        return kullanici;
    }

    public void setKullanici(Kullanici kullanici) {
        this.kullanici = kullanici;
    }

    public Kitap getKitap() {
        return kitap;
    }

    public void setKitap(Kitap kitap) {
        this.kitap = kitap;
    }

    public LocalDate getBaslangicTarihi() {
        return baslangicTarihi;
    }

    public void setBaslangicTarihi(LocalDate baslangicTarihi) {
        this.baslangicTarihi = baslangicTarihi;
    }

    public LocalDate getBitisTarihi() {
        return bitisTarihi;
    }

    public void setBitisTarihi(LocalDate bitisTarihi) {
        this.bitisTarihi = bitisTarihi;
    }

    public OduncDurum getDurum() {
        return durum;
    }

    public void setDurum(OduncDurum durum) { // Metot tipi değişti
        this.durum = durum;
    }
}
