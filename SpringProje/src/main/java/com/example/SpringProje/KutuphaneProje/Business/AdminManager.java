package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IAdminRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Admin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class AdminManager implements IAdminService {

    private final IAdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AdminManager(IAdminRepository adminRepository, PasswordEncoder passwordEncoder) {
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public List<Admin> getAll() {
        return adminRepository.findAll();
    }

    @Override
    public Admin getById(int id) {
        return adminRepository.findById(id).orElse(null);
    }

    @Override
    @Transactional
    public void add(Admin admin) {
        admin.setPassword(passwordEncoder.encode(admin.getPassword()));
        adminRepository.save(admin);
    }

    @Override
    @Transactional
    public void update(Admin admin) {
        adminRepository.save(admin);
    }

    @Override
    @Transactional
    public void delete(int id) {
        adminRepository.deleteById(id);
    }

    @Override
    public Optional<Admin> getByEmail(String email) {
        return adminRepository.findByEmail(email);
    }

    @Override
    public boolean emailExists(String email) {
        return adminRepository.existsByEmail(email);
    }
}