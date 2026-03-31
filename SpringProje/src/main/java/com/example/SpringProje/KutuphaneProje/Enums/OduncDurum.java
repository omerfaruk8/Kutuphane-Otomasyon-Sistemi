package com.example.SpringProje.KutuphaneProje.Enums;

/**
 * Bir kitabın ödünç verilme sürecindeki farklı aşamaları
 * (bekleme, aktif kullanım, iade vb.) temsil eden durumlar.
 */
public enum OduncDurum {
    BEKLEMEDE,
    KULLANICIDA,
    TESLIM_ALINDI,
    REDDEDILDI,
    IPTAL_EDILDI
}