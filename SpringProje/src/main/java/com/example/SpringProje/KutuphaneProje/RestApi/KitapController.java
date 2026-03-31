package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IKitapService;
import com.example.SpringProje.KutuphaneProje.Entities.Kitap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
@RestController
@RequestMapping("/api/kitaplar")
public class KitapController {

    private final IKitapService kitapService;

    @Autowired
    public KitapController(IKitapService kitapService) {
        this.kitapService = kitapService;
    }

    @GetMapping
    public List<Kitap> getAll() {
        return kitapService.getAll();
    }

    @GetMapping("/{id}")
    public Kitap getById(@PathVariable int id) {
        return kitapService.getById(id);
    }

    @PostMapping("/add")
    public void add(@RequestBody Kitap kitap) {
        kitapService.add(kitap);
    }

    @PostMapping("/update")
    public void update(@RequestBody Kitap kitap) {
        kitapService.update(kitap);
    }

    @DeleteMapping("/delete/{id}")
    public void delete(@PathVariable int id) {
        kitapService.delete(id);
    }

    @GetMapping("/kategori/{kategori}")
    public List<Kitap> getByCategory(@PathVariable String kategori) {
        return kitapService.getByKategori(kategori);
    }

    @GetMapping("/search")
    public List<Kitap> searchByName(@RequestParam String keyword) {
        return kitapService.searchByName(keyword);
    }

    @GetMapping("/available")
    public List<Kitap> getAvailableBooks() {
        return kitapService.getAvailableBooks();
    }
}

