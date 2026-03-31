package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IKitapOduncService;
import com.example.SpringProje.KutuphaneProje.Business.IKitapService;
import com.example.SpringProje.KutuphaneProje.Entities.KitapOdunc;
import com.example.SpringProje.KutuphaneProje.Enums.OduncDurum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Kitap ödünç alma talepleri, onay süreçleri ve iade işlemlerini
 * yöneten REST kontrolcüsü.
 */
@RestController
@RequestMapping("/api/borrows")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class KitapOduncController {

    private final IKitapOduncService kitapOduncService;
    private final IKitapService kitapService;

    @Autowired
    public KitapOduncController(IKitapOduncService kitapOduncService, IKitapService kitapService) {
        this.kitapOduncService = kitapOduncService;
        this.kitapService = kitapService;
    }

    @PostMapping("/add")
    public ResponseEntity<String> addBorrow(@RequestBody KitapOdunc kitapOdunc) {
        kitapOduncService.add(kitapOdunc);
        return ResponseEntity.ok("Kitap ödünç alma isteği başarıyla kaydedildi.");
    }

    @GetMapping("/user/{kullaniciId}")
    public List<KitapOdunc> getByUserId(@PathVariable int kullaniciId) {
        return kitapOduncService.getByKullaniciId(kullaniciId);
    }

    @GetMapping("/active/{kitapId}")
    public boolean hasActiveBorrow(@PathVariable int kitapId,
                                   @RequestParam("after") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tarih) {
        return kitapOduncService.hasActiveBorrow(kitapId, tarih);
    }

    @GetMapping("/pending")
    public List<KitapOdunc> getPendingBorrows() {
        return kitapOduncService.getPendingBorrows();
    }

    @PostMapping("/approve/{oduncId}")
    public ResponseEntity<String> approveBorrow(@PathVariable int oduncId) {
        kitapOduncService.setKullaniciyaVerildi(oduncId);
        return ResponseEntity.ok("Kitap ödünç işlemi onaylandı.");
    }

    @PostMapping("/return/{oduncId}")
    public ResponseEntity<String> returnBook(@PathVariable int oduncId) {
        KitapOdunc odunc = kitapOduncService.getById(oduncId);
        if (odunc != null && odunc.getDurum() == OduncDurum.KULLANICIDA) {
            kitapOduncService.returnBook(oduncId);
            return ResponseEntity.ok("Kitap iade işlemi tamamlandı.");
        }
        return ResponseEntity.badRequest().body("İade edilmeye uygun ödünç kaydı bulunamadı.");
    }

    @GetMapping("/active-borrows")
    public List<KitapOdunc> getActiveBorrows() {
        return kitapOduncService.getActiveBorrows();
    }

    @PostMapping("/reject/{oduncId}")
    public ResponseEntity<String> rejectBorrow(@PathVariable int oduncId) {
        KitapOdunc odunc = kitapOduncService.getById(oduncId);
        if (odunc != null && odunc.getDurum() == OduncDurum.BEKLEMEDE) {
            kitapOduncService.rejectBorrow(oduncId);
            return ResponseEntity.ok("Kitap ödünç isteği reddedildi.");
        }
        return ResponseEntity.badRequest().body("Geçersiz veya halihazırda işlenmiş ödünç isteği.");
    }

    @PutMapping("/cancel/{id}")
    public ResponseEntity<String> cancelBorrow(@PathVariable int id) {
        kitapOduncService.iptalEt(id);
        return ResponseEntity.ok("Ödünç isteği başarıyla iptal edildi.");
    }
}