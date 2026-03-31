package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IKullaniciCezaService;
import com.example.SpringProje.KutuphaneProje.Business.IKullaniciService;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 * Kullanıcıların ceza durumlarını sorgulama ve yetkili tarafından
 * ceza kaldırma işlemlerini yöneten REST kontrolcüsü.
 */
@RestController
@RequestMapping("/api/ceza")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class KullaniciCezaController {

    private final IKullaniciCezaService cezaService;
    private final IKullaniciService kullaniciService;

    @Autowired
    public KullaniciCezaController(IKullaniciCezaService cezaService, IKullaniciService kullaniciService) {
        this.cezaService = cezaService;
        this.kullaniciService = kullaniciService;
    }

    @GetMapping("/durum/{kullaniciId}")
    public ResponseEntity<?> getCezaDurumu(@PathVariable int kullaniciId) {
        Kullanici kullanici = kullaniciService.getById(kullaniciId);

        if (kullanici == null) {
            return ResponseEntity.badRequest().body("Sistemde kayıtlı kullanıcı bulunamadı.");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("cezali", cezaService.cezaliMi(kullanici));
        response.put("cezaBitisTarihi", cezaService.getCezaBitisTarihi(kullanici));
        response.put("adSoyad", kullanici.getAdSoyad());
        response.put("email", kullanici.getEmail());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/kaldir/{kullaniciId}")
    public ResponseEntity<?> cezaKaldir(@PathVariable int kullaniciId) {
        cezaService.cezaKaldir(kullaniciId);
        return ResponseEntity.ok("Kullanıcının cezası başarıyla kaldırılmıştır.");
    }
}