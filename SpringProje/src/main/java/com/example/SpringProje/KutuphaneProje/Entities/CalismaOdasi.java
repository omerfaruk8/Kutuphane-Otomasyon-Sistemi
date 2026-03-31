package com.example.SpringProje.KutuphaneProje.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "calisma_odalari")
public class CalismaOdasi {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "odaid")
    private int odaId;
    @Column(name = "oda_adi")
    private String odaAdi;
    @Column(name = "oda_tipi")
    private String odaTipi;
    @Column(name = "sandalye_sayisi")
    private int sandalyeSayisi;

    public CalismaOdasi(int odaId, String odaAdi, String odaTipi, int sandalyeSayisi) {
        this.odaId = odaId;
        this.odaAdi = odaAdi;
        this.odaTipi = odaTipi;
        this.sandalyeSayisi = sandalyeSayisi;
    }

    public CalismaOdasi(){}

    public int getOdaId() {
        return odaId;
    }

    public void setOdaId(int odaId) {
        this.odaId = odaId;
    }

    public String getOdaAdi() {
        return odaAdi;
    }

    public void setOdaAdi(String odaAdi) {
        this.odaAdi = odaAdi;
    }

    public String getOdaTipi() {
        return odaTipi;
    }

    public void setOdaTipi(String odaTipi) {
        this.odaTipi = odaTipi;
    }

    public int getSandalyeSayisi() {
        return sandalyeSayisi;
    }

    public void setSandalyeSayisi(int sandalyeSayisi) {
        this.sandalyeSayisi = sandalyeSayisi;
    }
}
