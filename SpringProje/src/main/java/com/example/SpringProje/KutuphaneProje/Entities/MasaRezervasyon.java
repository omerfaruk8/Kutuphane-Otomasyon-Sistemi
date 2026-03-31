package com.example.SpringProje.KutuphaneProje.Entities;

import com.example.SpringProje.KutuphaneProje.Enums.MasaSeans;
import com.example.SpringProje.KutuphaneProje.Enums.RezervasyonDurum;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "masa_rezervasyon")
public class MasaRezervasyon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rezervasyonid")
    private int rezervasyonId;

    @ManyToOne
    @JoinColumn(name = "kullanici_id")
    private Kullanici kullanici;

    @ManyToOne
    @JoinColumn(name = "oda_id")
    private CalismaOdasi calismaOdasi;

    @Column(name = "sandalye_no")
    private int sandalyeNo;

    @Column(name = "tarih")
    private LocalDate tarih;

    @Enumerated(EnumType.STRING)
    @Column(name = "seans")
    private MasaSeans seans;

    @Enumerated(EnumType.STRING)
    @Column(name = "durum")
    private RezervasyonDurum durum;

    @Column(name = "check_in")
    private boolean checkIn = false; // Kullanıcının kütüphaneye gelip gelmediğini belirtir.

    @Transient
    private List<String> grupUyeleri; // Veritabanına kaydedilmeyen, sadece grup rezervasyonu işlemlerinde kullanılan geçici liste.

    public MasaRezervasyon(int rezervasyonId, Kullanici kullanici, CalismaOdasi calismaOdasi, int sandalyeNo, MasaSeans seans, RezervasyonDurum durum, List<String> grupUyeleri) {
        this.rezervasyonId = rezervasyonId;
        this.kullanici = kullanici;
        this.calismaOdasi = calismaOdasi;
        this.sandalyeNo = sandalyeNo;
        this.seans = seans;
        this.durum = durum;
        this.grupUyeleri = grupUyeleri;
    }

    public MasaRezervasyon() {
        this.durum = RezervasyonDurum.AKTIF;
    }


    public int getRezervasyonId() {
        return rezervasyonId;
    }

    public void setRezervasyonId(int rezervasyonId) {
        this.rezervasyonId = rezervasyonId;
    }

    public Kullanici getKullanici() {
        return kullanici;
    }

    public void setKullanici(Kullanici kullanici) {
        this.kullanici = kullanici;
    }

    public CalismaOdasi getCalismaOdasi() {
        return calismaOdasi;
    }

    public void setCalismaOdasi(CalismaOdasi calismaOdasi) {
        this.calismaOdasi = calismaOdasi;
    }

    public int getSandalyeNo() {
        return sandalyeNo;
    }

    public void setSandalyeNo(int sandalyeNo) {
        this.sandalyeNo = sandalyeNo;
    }

    public LocalDate getTarih() {
        return tarih;
    }

    public void setTarih(LocalDate tarih) {
        this.tarih = tarih;
    }

    public MasaSeans getSeans() {
        return seans;
    }
    public void setSeans(MasaSeans seans) {
        this.seans = seans;
    }

    public RezervasyonDurum getDurum() {
        return durum;
    }
    public void setDurum(RezervasyonDurum durum) {
        this.durum = durum;
    }

    public boolean isCheckIn() {
        return checkIn;
    }

    public void setCheckIn(boolean checkIn) {
        this.checkIn = checkIn;
    }

    public List<String> getGrupUyeleri() {
        return grupUyeleri;
    }

    public void setGrupUyeleri(List<String> grupUyeleri) {
        this.grupUyeleri = grupUyeleri;
    }
}