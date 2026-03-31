package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.IKitapRepository;
import com.example.SpringProje.KutuphaneProje.Entities.Kitap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class KitapManager implements IKitapService {

    private final IKitapRepository kitapRepository;

    @Autowired
    public KitapManager(IKitapRepository kitapRepository) {
        this.kitapRepository = kitapRepository;
    }

    @Override
    public List<Kitap> getAll() {
        return this.kitapRepository.findAll();
    }

    @Override
    public Kitap getById(int id) {
        return this.kitapRepository.findById(id).orElse(null);
    }

    @Override
    @Transactional
    public void add(Kitap kitap) {
        kitapRepository.save(kitap);
    }

    @Override
    @Transactional
    public void update(Kitap kitap) {
        kitapRepository.save(kitap);
    }

    @Override
    @Transactional
    public void delete(int id) {
        if (!kitapRepository.existsById(id)) {
            throw new RuntimeException("Belirtilen ID ile eşleşen kitap bulunamadı: " + id);
        }
        kitapRepository.deleteById(id);
    }

    @Override
    public List<Kitap> getByKategori(String kategori) {
        return kitapRepository.findByKategori(kategori);
    }

    @Override
    public List<Kitap> searchByName(String keyword) {
        return kitapRepository.findByKitapAdiContaining(keyword);
    }

    @Override
    public List<Kitap> getAvailableBooks() {
        return kitapRepository.findByMusaitAdetGreaterThan(0);
    }
}