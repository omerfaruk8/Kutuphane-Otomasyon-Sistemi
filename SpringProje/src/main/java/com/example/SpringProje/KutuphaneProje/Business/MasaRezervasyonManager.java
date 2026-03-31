package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IMasaRezervasyonRepository;
import com.example.SpringProje.KutuphaneProje.Entities.CalismaOdasi;
import com.example.SpringProje.KutuphaneProje.Entities.MasaRezervasyon;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.Enums.MasaSeans;
import com.example.SpringProje.KutuphaneProje.Enums.RezervasyonDurum;
import com.example.SpringProje.KutuphaneProje.DTO.GrupRezervasyonRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.scheduling.annotation.Scheduled;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MasaRezervasyonManager implements IMasaRezervasyonService {

    private final IMasaRezervasyonRepository masaRezervasyonRepository;
    private final IKullaniciService kullaniciService;
    private final ICalismaOdasiService calismaOdasiService;
    private final IKullaniciCezaService cezaService;

    @Autowired
    public MasaRezervasyonManager(IMasaRezervasyonRepository masaRezervasyonRepository,
                                  IKullaniciService kullaniciService,
                                  ICalismaOdasiService calismaOdasiService,
                                  IKullaniciCezaService cezaService) {
        this.masaRezervasyonRepository = masaRezervasyonRepository;
        this.kullaniciService = kullaniciService;
        this.calismaOdasiService = calismaOdasiService;
        this.cezaService = cezaService;
    }

    @Override
    @Transactional
    public void grupRezervasyonuYap(String girisYapanEmail, List<GrupRezervasyonRequest.RezervasyonItem> rezervasyonDTOList) {
        if (rezervasyonDTOList == null || rezervasyonDTOList.isEmpty()) {
            throw new IllegalArgumentException("Rezervasyon listesi boş olamaz.");
        }

        for (GrupRezervasyonRequest.RezervasyonItem item : rezervasyonDTOList) {
            Kullanici kullanici = kullaniciService.getById(item.kullanici.kullaniciId);
            CalismaOdasi oda = calismaOdasiService.getById(item.calismaOdasi.odaId);

            if (kullanici == null || oda == null) {
                throw new RuntimeException("Kullanıcı veya oda bilgisi doğrulanamadı.");
            }

            if (cezaService.cezaliMi(kullanici)) {
                throw new RuntimeException("Kullanıcı (" + kullanici.getEmail() + ") cezalı olduğu için rezervasyon yapamaz.");
            }

            MasaSeans currentEnumSeans = parseSeans(item.seans);
            validateSeansZamani(item.tarih, currentEnumSeans);

            if (getByKullaniciId(item.kullanici.kullaniciId).size() >= 2) {
                throw new RuntimeException("Kullanıcı (" + kullanici.getEmail() + ") için eş zamanlı rezervasyon limiti dolu.");
            }

            checkUserTimeConflict(item.kullanici.kullaniciId, item.tarih, currentEnumSeans);
            checkSeatConflict(oda.getOdaId(), item.sandalyeNo, item.tarih, currentEnumSeans);

            MasaRezervasyon r = new MasaRezervasyon();
            r.setKullanici(kullanici);
            r.setCalismaOdasi(oda);
            r.setTarih(item.tarih);
            r.setSandalyeNo(item.sandalyeNo);
            r.setSeans(currentEnumSeans);

            r.setDurum(kullanici.getEmail().equalsIgnoreCase(girisYapanEmail) ? RezervasyonDurum.AKTIF : RezervasyonDurum.ONAY_BEKLIYOR);
            masaRezervasyonRepository.save(r);
        }
    }

    @Override
    @Transactional
    public void onaylaRezervasyon(int id) {
        MasaRezervasyon r = masaRezervasyonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Onaylanacak rezervasyon kaydı bulunamadı."));

        if (r.getDurum() != RezervasyonDurum.ONAY_BEKLIYOR) {
            throw new RuntimeException("Rezervasyon mevcut durumu nedeniyle onaylanamaz.");
        }

        List<MasaRezervasyon> mevcutlar = getByKullaniciId(r.getKullanici().getKullaniciId());
        mevcutlar.removeIf(kayit -> kayit.getRezervasyonId() == id);

        if (mevcutlar.size() >= 2) {
            throw new RuntimeException("Rezervasyon limitiniz (2) dolduğu için bu daveti onaylayamazsınız.");
        }

        r.setDurum(RezervasyonDurum.AKTIF);
        masaRezervasyonRepository.save(r);
    }

    @Override
    @Transactional
    public void reddetRezervasyon(int id) {
        MasaRezervasyon r = masaRezervasyonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reddedilecek rezervasyon kaydı bulunamadı."));

        if (r.getDurum() != RezervasyonDurum.ONAY_BEKLIYOR) {
            throw new RuntimeException("Sadece beklemede olan rezervasyonlar reddedilebilir.");
        }

        r.setDurum(RezervasyonDurum.IPTAL);
        masaRezervasyonRepository.save(r);
    }

    @Override
    @Transactional
    public void add(MasaRezervasyon r) {
        GrupRezervasyonRequest.RezervasyonItem item = new GrupRezervasyonRequest.RezervasyonItem();
        item.kullanici = new GrupRezervasyonRequest.KullaniciIdTasiyici();
        item.kullanici.kullaniciId = r.getKullanici().getKullaniciId();
        item.calismaOdasi = new GrupRezervasyonRequest.OdaIdTasiyici();
        item.calismaOdasi.odaId = r.getCalismaOdasi().getOdaId();
        item.sandalyeNo = r.getSandalyeNo();
        item.tarih = r.getTarih();
        item.seans = r.getSeans().name();

        List<GrupRezervasyonRequest.RezervasyonItem> list = new ArrayList<>();
        list.add(item);
        grupRezervasyonuYap(kullaniciService.getById(item.kullanici.kullaniciId).getEmail(), list);
    }

    @Override
    @Transactional
    public void cancelReservation(int id) {
        MasaRezervasyon r = masaRezervasyonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("İptal edilecek rezervasyon kaydı bulunamadı."));
        r.setDurum(RezervasyonDurum.IPTAL);
        masaRezervasyonRepository.save(r);
    }

    @Override
    public List<MasaRezervasyon> getByKullaniciId(int kullaniciId) {
        return masaRezervasyonRepository.findByKullanici_KullaniciId(kullaniciId).stream()
                .filter(r -> r.getDurum() == RezervasyonDurum.AKTIF || r.getDurum() == RezervasyonDurum.ONAY_BEKLIYOR)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    @Scheduled(cron = "0 0 11,13,15,17,19 * * *")
    public void pasiflestirGecmisRezervasyonlar() {
        LocalDate bugun = LocalDate.now();
        LocalTime simdi = LocalTime.now();
        List<MasaRezervasyon> copKutusu = new ArrayList<>();

        copKutusu.addAll(masaRezervasyonRepository.findByTarihBeforeAndDurum(bugun, RezervasyonDurum.AKTIF));
        copKutusu.addAll(masaRezervasyonRepository.findByTarihBeforeAndDurum(bugun, RezervasyonDurum.ONAY_BEKLIYOR));

        List<MasaRezervasyon> bugunku = masaRezervasyonRepository.findByTarihAndDurum(bugun, RezervasyonDurum.AKTIF);
        bugunku.addAll(masaRezervasyonRepository.findByTarihAndDurum(bugun, RezervasyonDurum.ONAY_BEKLIYOR));

        for (MasaRezervasyon r : bugunku) {
            if (simdi.getHour() >= getSeansBitisSaati(r.getSeans())) copKutusu.add(r);
        }

        for (MasaRezervasyon r : copKutusu) r.setDurum(RezervasyonDurum.IPTAL);
        masaRezervasyonRepository.saveAll(copKutusu);
    }

    @Override
    @Transactional
    public void kullaniciGirisYapti(int kullaniciId) {
        LocalDate bugun = LocalDate.now();
        LocalTime suAn = LocalTime.now();

        List<MasaRezervasyon> aktifRezervasyonlar = masaRezervasyonRepository.findByKullanici_KullaniciId(kullaniciId)
                .stream()
                .filter(r -> r.getDurum() == RezervasyonDurum.AKTIF && r.getTarih().isEqual(bugun))
                .collect(Collectors.toList());

        MasaRezervasyon rezervasyon = aktifRezervasyonlar.stream()
                .filter(r -> {
                    int bitisSaati = getSeansBitisSaati(r.getSeans());
                    return suAn.getHour() >= (bitisSaati - 2) && suAn.getHour() < bitisSaati;
                })
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Şu an giriş yapabileceğiniz aktif bir seans bulunmamaktadır."));

        if (rezervasyon.isCheckIn()) {
            throw new RuntimeException("Giriş işlemi zaten yapılmış.");
        }

        rezervasyon.setCheckIn(true);
        masaRezervasyonRepository.save(rezervasyon);
    }

    @Override
    @Transactional
    @Scheduled(cron = "0 31 9,11,13,15,17 * * *")
    public void cezaKontrolu() {
        LocalDate bugun = LocalDate.now();
        LocalTime suAn = LocalTime.now();

        List<MasaRezervasyon> bugunkuRezervasyonlar = masaRezervasyonRepository.findByTarihAndDurum(bugun, RezervasyonDurum.AKTIF);

        for (MasaRezervasyon r : bugunkuRezervasyonlar) {
            int seansBitisSaati = getSeansBitisSaati(r.getSeans());

            if (suAn.getHour() >= seansBitisSaati || (suAn.getHour() == seansBitisSaati - 2 && suAn.getMinute() >= 31)) {
                if (!r.isCheckIn()) {
                    r.setDurum(RezervasyonDurum.IPTAL);
                    masaRezervasyonRepository.save(r);
                    cezaService.cezaEkle(r.getKullanici(), 2);
                }
            }
        }
    }

    private void checkUserTimeConflict(int userId, LocalDate tarih, MasaSeans seans) {
        List<MasaRezervasyon> kayitlar = masaRezervasyonRepository.findByKullanici_KullaniciIdAndTarihAndSeans(userId, tarih, seans);
        boolean dolu = kayitlar.stream().anyMatch(r -> r.getDurum() == RezervasyonDurum.AKTIF || r.getDurum() == RezervasyonDurum.ONAY_BEKLIYOR);
        if (dolu) throw new RuntimeException("Belirtilen zaman diliminde kullanıcının başka bir rezervasyonu bulunmaktadır.");
    }

    private void checkSeatConflict(int odaId, int no, LocalDate tarih, MasaSeans seans) {
        RezervasyonDurum[] durumlar = {RezervasyonDurum.AKTIF, RezervasyonDurum.ONAY_BEKLIYOR};
        for (RezervasyonDurum d : durumlar) {
            if (masaRezervasyonRepository.findByCalismaOdasi_OdaIdAndSandalyeNoAndTarihAndSeansAndDurum(odaId, no, tarih, seans, d).isPresent()) {
                throw new RuntimeException("Seçilen masa (" + no + ") belirtilen saatte doludur.");
            }
        }
    }

    private MasaSeans parseSeans(String seansStr) {
        if (seansStr == null) throw new RuntimeException("Seans bilgisi boş olamaz.");
        String raw = seansStr.trim().toUpperCase();
        if (raw.contains("09") || raw.equals("SEANS9")) return MasaSeans.SEANS9;
        if (raw.contains("11") || raw.equals("SEANS11")) return MasaSeans.SEANS11;
        if (raw.contains("13") || raw.equals("SEANS13")) return MasaSeans.SEANS13;
        if (raw.contains("15") || raw.equals("SEANS15")) return MasaSeans.SEANS15;
        if (raw.contains("17") || raw.equals("SEANS17")) return MasaSeans.SEANS17;
        throw new RuntimeException("Geçersiz seans formatı: " + seansStr);
    }

    private int getSeansBitisSaati(MasaSeans seans) {
        switch (seans) {
            case SEANS9: return 11; case SEANS11: return 13; case SEANS13: return 15; case SEANS15: return 17; case SEANS17: return 19; default: return 24;
        }
    }

    private void validateSeansZamani(LocalDate t, MasaSeans s) {
        if (t.isBefore(LocalDate.now())) throw new RuntimeException("Geçmiş bir tarihe rezervasyon yapılamaz.");
        if (t.isEqual(LocalDate.now())) {
            LocalTime now = LocalTime.now();
            LocalTime end = LocalTime.of(getSeansBitisSaati(s), 0);
            if (now.isAfter(end)) throw new RuntimeException("Seçilen seansın süresi dolmuştur.");
            if (now.isAfter(end.minusMinutes(15))) throw new RuntimeException("Seans bitimine 15 dakikadan az süre kaldığında rezervasyon yapılamaz.");
        }
    }

    @Override public void update(MasaRezervasyon r) { masaRezervasyonRepository.save(r); }
    @Override public void delete(int id) { cancelReservation(id); }
    @Override public List<MasaRezervasyon> getActiveReservations() { return masaRezervasyonRepository.findByDurum(RezervasyonDurum.AKTIF); }
    @Override public List<MasaRezervasyon> getAll() { return masaRezervasyonRepository.findAll(); }
    @Override public MasaRezervasyon getById(int id) { return masaRezervasyonRepository.findById(id).orElse(null); }
    @Override public List<MasaRezervasyon> getByRoomId(int odaId) {
        return masaRezervasyonRepository.findByCalismaOdasi_OdaId(odaId).stream()
                .filter(r -> r.getDurum() == RezervasyonDurum.AKTIF || r.getDurum() == RezervasyonDurum.ONAY_BEKLIYOR)
                .collect(Collectors.toList());
    }
    @Override public boolean isChairReserved(int odaId, int no, MasaSeans seans, LocalDate tarih) {
        try { checkSeatConflict(odaId, no, tarih, seans); return false; } catch (RuntimeException e) { return true; }
    }
}