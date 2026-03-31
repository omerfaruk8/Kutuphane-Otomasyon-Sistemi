package com.example.SpringProje.KutuphaneProje.Enums;

/**
 * Masa rezervasyonlarının güncel durumunu belirtir.
 * AKTIF: Onaylanmış rezervasyonlar.
 * IPTAL: Reddedilen, süresi dolan veya iptal edilen kayıtlar.
 * ONAY_BEKLIYOR: Grup davetlerinde onay bekleyen geçici durum.
 */
public enum RezervasyonDurum {
    AKTIF,
    IPTAL,
    ONAY_BEKLIYOR
}