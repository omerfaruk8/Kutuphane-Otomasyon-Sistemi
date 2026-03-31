package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IMasaRezervasyonService;
import com.example.SpringProje.KutuphaneProje.DTO.GrupRezervasyonRequest;
import com.example.SpringProje.KutuphaneProje.Entities.MasaRezervasyon;
import com.example.SpringProje.KutuphaneProje.Enums.MasaSeans;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Masa ve çalışma odası rezervasyonlarının oluşturulması, grup davetlerinin yönetimi,
 * doluluk kontrolleri ve check-in işlemlerini yürüten REST kontrolcüsü.
 */
@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class MasaRezervasyonController {

    private final IMasaRezervasyonService masaRezervasyonService;

    @Autowired
    public MasaRezervasyonController(IMasaRezervasyonService masaRezervasyonService) {
        this.masaRezervasyonService = masaRezervasyonService;
    }

    @PostMapping("/add")
    public ResponseEntity<String> add(@RequestBody MasaRezervasyon masaRezervasyon) {
        try {
            masaRezervasyonService.add(masaRezervasyon);
            return ResponseEntity.ok("Rezervasyon başarıyla oluşturuldu.");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Hatalı veri formatı: " + e.getMessage());
        }
    }

    @PostMapping("/addGrup")
    public ResponseEntity<String> addGrup(@RequestBody GrupRezervasyonRequest request) {
        try {
            masaRezervasyonService.grupRezervasyonuYap(request.getGirisYapanEmail(), request.getRezervasyonlar());
            return ResponseEntity.ok("Grup rezervasyonu başarıyla oluşturuldu.");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Grup Rezervasyon Hatası: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Kritik Hata: " + e.getMessage());
        }
    }

    @PutMapping("/approve/{id}")
    public ResponseEntity<String> approveReservation(@PathVariable int id) {
        try {
            masaRezervasyonService.onaylaRezervasyon(id);
            return ResponseEntity.ok("Davet kabul edildi, rezervasyon aktifleşti. 🎉");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/reject/{id}")
    public ResponseEntity<String> rejectReservation(@PathVariable int id) {
        try {
            masaRezervasyonService.reddetRezervasyon(id);
            return ResponseEntity.ok("Davet reddedildi.");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/update")
    public void update(@RequestBody MasaRezervasyon masaRezervasyon) {
        masaRezervasyonService.update(masaRezervasyon);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> delete(@PathVariable int id) {
        try {
            masaRezervasyonService.cancelReservation(id);
            return ResponseEntity.ok("Rezervasyon başarıyla iptal edildi.");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public List<MasaRezervasyon> getByUserId(@PathVariable int userId) {
        return masaRezervasyonService.getByKullaniciId(userId);
    }

    @GetMapping("/room/{roomId}")
    public List<MasaRezervasyon> getByRoomId(@PathVariable int roomId) {
        return masaRezervasyonService.getByRoomId(roomId);
    }

    @GetMapping("/doluBySeans")
    public boolean isDoluBySeans(
            @RequestParam int odaId,
            @RequestParam int sandalyeNo,
            @RequestParam String seans,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tarih
    ) {
        MasaSeans masaSeans;
        String s = seans.trim().toUpperCase();

        if (s.contains("09")) masaSeans = MasaSeans.SEANS9;
        else if (s.contains("11")) masaSeans = MasaSeans.SEANS11;
        else if (s.contains("13")) masaSeans = MasaSeans.SEANS13;
        else if (s.contains("15")) masaSeans = MasaSeans.SEANS15;
        else if (s.contains("17")) masaSeans = MasaSeans.SEANS17;
        else {
            try {
                masaSeans = MasaSeans.valueOf(s);
            } catch (Exception e) {
                return false;
            }
        }

        return masaRezervasyonService.isChairReserved(odaId, sandalyeNo, masaSeans, tarih);
    }

    @GetMapping("/active")
    public List<MasaRezervasyon> getActiveReservations() {
        return masaRezervasyonService.getActiveReservations();
    }

    @PostMapping("/check-in/{userId}")
    public ResponseEntity<String> checkIn(@PathVariable int userId) {
        try {
            masaRezervasyonService.kullaniciGirisYapti(userId);
            return ResponseEntity.ok("Hoşgeldiniz! Girişiniz onaylandı. 📚");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/run-penalties")
    public ResponseEntity<String> runPenalties() {
        masaRezervasyonService.cezaKontrolu();
        return ResponseEntity.ok("Ceza kontrolü çalıştırıldı. Gelmeyenlere ceza puanı işlendi.");
    }
}