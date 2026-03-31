package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.Admin;

import java.util.List;
import java.util.Optional;

/**
 * Sistem yöneticilerinin (Admin) yönetim süreçlerini tanımlayan servis arayüzü.
 */
public interface IAdminService {

    List<Admin> getAll();
    Admin getById(int id);
    void add(Admin admin);
    void update(Admin admin);
    void delete(int id);

    Optional<Admin> getByEmail(String email);
    boolean emailExists(String email);


}
