package com.example.SpringProje.KutuphaneProje.Startup;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import com.example.SpringProje.KutuphaneProje.Business.IMasaRezervasyonService;
import com.example.SpringProje.KutuphaneProje.Business.IKullaniciCezaService;

/**
 * Uygulama başlatıldıktan hemen sonra çalıştırılması gereken
 * veri temizleme ve kontrol görevlerini yöneten bileşendir.
 */
@Component
public class StartupTasks {

    private final IMasaRezervasyonService masaRezervasyonService;
    private final IKullaniciCezaService kullaniciCezaService;

    public StartupTasks(IMasaRezervasyonService masaRezervasyonService,
                        IKullaniciCezaService kullaniciCezaService) {
        this.masaRezervasyonService = masaRezervasyonService;
        this.kullaniciCezaService = kullaniciCezaService;
    }

    /**
     * Uygulama tamamen hazır olduğunda geçmiş rezervasyonların statüsünü günceller
     * ve teslim süresi geçen kitaplar için ceza kontrollerini başlatır.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        masaRezervasyonService.pasiflestirGecmisRezervasyonlar();
        kullaniciCezaService.gecTeslimCezasiKontrol();
    }
}