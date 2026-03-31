package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IKitapOduncRepository;
import com.example.SpringProje.KutuphaneProje.DataAccess.IKitapRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Kitap;
import com.example.SpringProje.KutuphaneProje.Entities.KitapOdunc;
import com.example.SpringProje.KutuphaneProje.Enums.OduncDurum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class KitapOduncManager implements IKitapOduncService {

    private final IKitapOduncRepository kitapOduncRepository;
    private final IKitapRepository kitapRepository;

    @Autowired
    public KitapOduncManager(IKitapOduncRepository kitapOduncRepository, IKitapRepository kitapRepository) {
        this.kitapOduncRepository = kitapOduncRepository;
        this.kitapRepository = kitapRepository;
    }

    @Override
    public List<KitapOdunc> getAll() {
        return kitapOduncRepository.findAll();
    }

    @Override
    public KitapOdunc getById(int id) {
        return kitapOduncRepository.findById(id).orElse(null);
    }

    @Override
    @Transactional
    public void add(KitapOdunc kitapOdunc) {
        // Kullanıcının aktif ödünç kitap limiti kontrol ediliyor (Maksimum 2 kitap).
        int kullaniciId = kitapOdunc.getKullanici().getKullaniciId();
        List<KitapOdunc> aktifOduncler = getByKullaniciId(kullaniciId);

        if (aktifOduncler.size() >= 2) {
            throw new RuntimeException("Ödünç alma limiti aşıldı. Aynı anda en fazla 2 kitap ödünç alınabilir.");
        }

        int kitapId = kitapOdunc.getKitap().getKitapId();
        Kitap kitap = kitapRepository.findById(kitapId)
                .orElseThrow(() -> new IllegalStateException("Kitap kaydı bulunamadı."));

        if (kitap.getMusaitAdet() <= 0) {
            throw new RuntimeException("Seçilen kitabın mevcut stoku tükenmiştir.");
        }

        kitapOdunc.setKitap(kitap);
        kitapOdunc.setDurum(OduncDurum.BEKLEMEDE);
        kitapOduncRepository.save(kitapOdunc);
    }

    @Override
    @Transactional
    public void update(KitapOdunc kitapOdunc) {
        kitapOduncRepository.save(kitapOdunc);
    }


    @Override
    @Transactional
    public void iptalEt(int id) {
        KitapOdunc odunc = kitapOduncRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ödünç kaydı bulunamadı."));

        if (odunc.getDurum() == OduncDurum.BEKLEMEDE) {
            odunc.setDurum(OduncDurum.IPTAL_EDILDI);
            kitapOduncRepository.save(odunc);
        } else {
            throw new RuntimeException("Sadece 'Beklemede' statüsündeki talepler iptal edilebilir.");
        }
    }

    @Override
    public List<KitapOdunc> getByKullaniciId(int kullaniciId) {
        List<KitapOdunc> tumKayitlar = kitapOduncRepository.findByKullanici_KullaniciId(kullaniciId);

        return tumKayitlar.stream()
                .filter(odunc -> odunc.getDurum() == OduncDurum.KULLANICIDA ||
                        odunc.getDurum() == OduncDurum.BEKLEMEDE)
                .collect(Collectors.toList());
    }

    @Override
    public boolean hasActiveBorrow(int kitapId, LocalDate after) {
        List<KitapOdunc> aktifler = kitapOduncRepository.findByDurum(OduncDurum.KULLANICIDA);
        return aktifler.stream()
                .anyMatch(o -> o.getKitap().getKitapId() == kitapId && o.getBitisTarihi().isAfter(after));
    }

    @Override
    @Transactional
    public void setKullaniciyaVerildi(int oduncId) {
        KitapOdunc odunc = kitapOduncRepository.findById(oduncId).orElse(null);

        if (odunc != null && OduncDurum.BEKLEMEDE.equals(odunc.getDurum())) {
            Kitap kitap = odunc.getKitap();
            if (kitap.getMusaitAdet() <= 0) {
                throw new RuntimeException("Onaylama sırasında stok yetersizliği tespit edildi.");
            }
            kitap.setMusaitAdet(kitap.getMusaitAdet() - 1);
            kitapRepository.save(kitap);

            odunc.setDurum(OduncDurum.KULLANICIDA);
            kitapOduncRepository.save(odunc);
        }
    }

    @Override
    @Transactional
    public void returnBook(int oduncId) {
        KitapOdunc odunc = kitapOduncRepository.findById(oduncId).orElse(null);
        if (odunc != null && OduncDurum.KULLANICIDA.equals(odunc.getDurum())) {
            odunc.setDurum(OduncDurum.TESLIM_ALINDI);

            Kitap kitap = odunc.getKitap();
            kitap.setMusaitAdet(kitap.getMusaitAdet() + 1);
            kitapRepository.save(kitap);

            kitapOduncRepository.save(odunc);
        }
    }

    @Override
    public List<KitapOdunc> getPendingBorrows() {
        return kitapOduncRepository.findByDurum(OduncDurum.BEKLEMEDE);
    }

    @Override
    public List<KitapOdunc> getActiveBorrows() {
        return kitapOduncRepository.findByDurum(OduncDurum.KULLANICIDA);
    }

    @Override
    @Transactional
    public void rejectBorrow(int oduncId) {
        KitapOdunc odunc = kitapOduncRepository.findById(oduncId).orElse(null);

        if (odunc != null && OduncDurum.BEKLEMEDE.equals(odunc.getDurum())) {
            odunc.setDurum(OduncDurum.REDDEDILDI);
            kitapOduncRepository.save(odunc);
        }
    }
}