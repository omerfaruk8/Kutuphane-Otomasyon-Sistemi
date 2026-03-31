package com.example.SpringProje.KutuphaneProje.RestApi;

import com.example.SpringProje.KutuphaneProje.Business.IAdminService;
import com.example.SpringProje.KutuphaneProje.Entities.Admin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/admins")
@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
public class AdminController {

    private final IAdminService adminService;

    @Autowired
    public AdminController(IAdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public List<Admin> getAll() {
        return adminService.getAll();
    }

    @GetMapping("/{id}")
    public Admin getById(@PathVariable int id) {
        return adminService.getById(id);
    }

    @PostMapping("/add")
    public void add(@RequestBody Admin admin) {
        adminService.add(admin);
    }

    @PostMapping("/update")
    public void update(@RequestBody Admin admin) {
        adminService.update(admin);
    }

    @DeleteMapping("/delete/{id}")
    public void delete(@PathVariable int id) {
        adminService.delete(id);
    }

    @GetMapping("/email")
    public Optional<Admin> getByEmail(@RequestParam String email) {
        return adminService.getByEmail(email);
    }

    @GetMapping("/exists")
    public boolean emailExists(@RequestParam String email) {
        return adminService.emailExists(email);
    }
}