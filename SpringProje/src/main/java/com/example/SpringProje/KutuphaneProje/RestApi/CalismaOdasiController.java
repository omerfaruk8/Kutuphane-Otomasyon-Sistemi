package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.ICalismaOdasiService;
import com.example.SpringProje.KutuphaneProje.Entities.CalismaOdasi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/odalar")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class CalismaOdasiController {

    private final ICalismaOdasiService calismaOdasiService;

    @Autowired
    public CalismaOdasiController(ICalismaOdasiService calismaOdasiService) {
        this.calismaOdasiService = calismaOdasiService;
    }

    @GetMapping
    public List<CalismaOdasi> getAll() {
        return calismaOdasiService.getAll();
    }

    @GetMapping("/{id}")
    public CalismaOdasi getById(@PathVariable int id) {
        return calismaOdasiService.getById(id);
    }

    @PostMapping("/add")
    public void add(@RequestBody CalismaOdasi calismaOdasi) {
        calismaOdasiService.add(calismaOdasi);
    }

    @PostMapping("/update")
    public void update(@RequestBody CalismaOdasi calismaOdasi) {
        calismaOdasiService.update(calismaOdasi);
    }

    @DeleteMapping("/delete/{id}")
    public void delete(@PathVariable int id) {
        calismaOdasiService.delete(id);
    }

    @GetMapping("/type/{type}")
    public List<CalismaOdasi> getByRoomType(@PathVariable String type) {
        return calismaOdasiService.getByOdaTipi(type);
    }
}
