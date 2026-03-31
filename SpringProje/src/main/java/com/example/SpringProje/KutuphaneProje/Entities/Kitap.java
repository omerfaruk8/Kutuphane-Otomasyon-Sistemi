package com.example.SpringProje.KutuphaneProje.Entities;

import jakarta.persistence.*;


@Entity
@Table(name = "kitaplar")
public class Kitap {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "kitap_id")
    private int kitapId;
    @Column(name = "kitap_adi")
    private String kitapAdi;
    @Column(name = "yazar")
    private String yazar;
    @Column(name = "kategori")
    private String kategori;
    @Column(name = "stok_sayisi")
    private int stokSayisi;
    @Column(name = "musait_adet")
    private int musaitAdet;

    public Kitap(int kitapId, String kitapAdi, String yazar, String kategori, int stokSayisi, int musaitAdet) {
        this.kitapId = kitapId;
        this.kitapAdi = kitapAdi;
        this.yazar = yazar;
        this.kategori = kategori;
        this.stokSayisi = stokSayisi;
        this.musaitAdet = musaitAdet;
    }

    public Kitap(){}

    public int getKitapId() {
        return kitapId;
    }

    public void setKitapId(int kitapId) {
        this.kitapId = kitapId;
    }

    public String getKitapAdi() {
        return kitapAdi;
    }

    public void setKitapAdi(String kitapAdi) {
        this.kitapAdi = kitapAdi;
    }

    public String getYazar() {
        return yazar;
    }

    public void setYazar(String yazar) {
        this.yazar = yazar;
    }

    public String getKategori() {
        return kategori;
    }

    public void setKategori(String kategori) {
        this.kategori = kategori;
    }

    public int getStokSayisi() {
        return stokSayisi;
    }

    public void setStokSayisi(int stokSayisi) {
        this.stokSayisi = stokSayisi;
    }

    public int getMusaitAdet() {
        return musaitAdet;
    }

    public void setMusaitAdet(int musaitAdet) {
        this.musaitAdet = musaitAdet;
    }
}
