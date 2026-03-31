package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IKullaniciService;
import com.example.SpringProje.KutuphaneProje.Entities.Kullanici;
import com.example.SpringProje.KutuphaneProje.DTO.UpdateProfileRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Kullanıcı hesaplarının yönetimi, arama işlemleri ve profil güncelleme
 * süreçlerini sağlayan REST kontrolcüsü.
 */
@RestController
@RequestMapping("/api/kullanicilar")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class KullaniciController {

    private final IKullaniciService kullaniciService;

    @Autowired
    public KullaniciController(IKullaniciService kullaniciService) {
        this.kullaniciService = kullaniciService;
    }

    @GetMapping
    public List<Kullanici> getAll() {
        return kullaniciService.getAll();
    }

    @GetMapping("/{id}")
    public Kullanici getById(@PathVariable int id) {
        return kullaniciService.getById(id);
    }

    @PostMapping("/add")
    public void add(@RequestBody Kullanici kullanici) {
        kullaniciService.add(kullanici);
    }

    @PostMapping("/update")
    public void update(@RequestBody Kullanici kullanici) {
        kullaniciService.update(kullanici);
    }

    @DeleteMapping("/delete/{id}")
    public void delete(@PathVariable int id) {
        kullaniciService.delete(id);
    }

    @GetMapping("/email/{email}")
    public Optional<Kullanici> getByEmail(@PathVariable String email) {
        return kullaniciService.getByEmail(email);
    }

    @GetMapping("/email-exists/{email}")
    public boolean emailExists(@PathVariable String email) {
        return kullaniciService.emailExists(email);
    }

    @GetMapping("/search")
    public List<Kullanici> searchByName(@RequestParam String keyword) {
        return kullaniciService.searchByName(keyword);
    }

    @PutMapping("/profile/{id}")
    public void updateProfile(@PathVariable int id, @RequestBody UpdateProfileRequest request) {
        kullaniciService.updateProfile(id, request);
    }
}