package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IKitapOduncRepository;
import com.example.SpringProje.KutuphaneProje.DataAccess.IKullaniciCezaRepository;
import com.example.SpringProje.KutuphaneProje.Entities.KitapOdunc;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.Entities.KullaniciCeza;
import com.example.SpringProje.KutuphaneProje.Enums.OduncDurum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
public class KullaniciCezaManager implements IKullaniciCezaService {

    private final IKullaniciCezaRepository kullaniciCezaRepository;
    private final IKitapOduncRepository kitapOduncRepository;

    @Autowired
    public KullaniciCezaManager(IKullaniciCezaRepository kullaniciCezaRepository,
                                IKitapOduncRepository kitapOduncRepository) {
        this.kullaniciCezaRepository = kullaniciCezaRepository;
        this.kitapOduncRepository = kitapOduncRepository;
    }

    @Override
    @Transactional
    public void cezaEkle(Kullanici kullanici, int puan) {
        KullaniciCeza ceza = kullaniciCezaRepository.findByKullanici(kullanici)
                .orElseGet(() -> {
                    KullaniciCeza yeniCeza = new KullaniciCeza();
                    yeniCeza.setKullanici(kullanici);
                    yeniCeza.setIhlalSayisi(0);
                    yeniCeza.setCezaBitisTarihi(LocalDate.now().minusDays(1));
                    return yeniCeza;
                });

        LocalDate now = LocalDate.now();
        ceza.setIhlalSayisi(ceza.getIhlalSayisi() + puan);

        LocalDate gecerliTarih = ceza.getCezaBitisTarihi().isAfter(now)
                ? ceza.getCezaBitisTarihi()
                : now;

        ceza.setCezaBitisTarihi(gecerliTarih.plusDays(puan));
        ceza.setEnSonCezaVerilenTarih(now);

        kullaniciCezaRepository.save(ceza);
    }

    @Override
    public boolean cezaliMi(Kullanici kullanici) {
        Optional<KullaniciCeza> opt = kullaniciCezaRepository.findByKullanici(kullanici);
        return opt.map(ceza -> ceza.getCezaBitisTarihi().isAfter(LocalDate.now())).orElse(false);
    }

    @Override
    public int getKullaniciCezaPuani(Kullanici kullanici) {
        return kullaniciCezaRepository.findByKullanici(kullanici)
                .map(KullaniciCeza::getIhlalSayisi)
                .orElse(0);
    }

    @Override
    public LocalDate getCezaBitisTarihi(Kullanici kullanici) {
        return kullaniciCezaRepository.findByKullanici(kullanici)
                .map(KullaniciCeza::getCezaBitisTarihi)
                .orElse(null);
    }

    /**
     * Her gün saat 19:10'da çalışarak teslim tarihi geçen kitaplar için
     * kullanıcılara otomatik gecikme cezası tanımlar.
     */
    @Override
    @Scheduled(cron = "0 10 19 * * *")
    @Transactional
    public void gecTeslimCezasiKontrol() {
        LocalDate bugun = LocalDate.now();

        List<KitapOdunc> gecTeslimler = kitapOduncRepository
                .findByBitisTarihiBeforeAndDurum(bugun, OduncDurum.KULLANICIDA);

        for (KitapOdunc odunc : gecTeslimler) {
            long gecenGun = ChronoUnit.DAYS.between(odunc.getBitisTarihi(), bugun);
            if (gecenGun >= 0) {
                cezaEkle(odunc.getKullanici(), (int) (gecenGun + 1));
            }
        }
    }

    @Override
    @Transactional
    public void cezaKaldir(int kullaniciId) {
        Kullanici k = new Kullanici();
        k.setKullaniciId(kullaniciId);

        Optional<KullaniciCeza> cezaOpt = kullaniciCezaRepository.findByKullanici(k);

        if (cezaOpt.isPresent()) {
            KullaniciCeza ceza = cezaOpt.get();
            ceza.setIhlalSayisi(0);
            ceza.setCezaBitisTarihi(LocalDate.now().minusDays(1));
            kullaniciCezaRepository.save(ceza);
        } else {
            throw new RuntimeException("Belirtilen kullanıcıya ait aktif bir ceza kaydı bulunamadı.");
        }
    }
}