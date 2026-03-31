package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.DataAccess.ICalismaOdasiRepository;
import com.example.SpringProje.KutuphaneProje.Entities.CalismaOdasi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CalismaOdasiManager implements ICalismaOdasiService {

    private final ICalismaOdasiRepository calismaOdasiRepository;

    @Autowired
    public CalismaOdasiManager(ICalismaOdasiRepository calismaOdasiRepository) {
        this.calismaOdasiRepository = calismaOdasiRepository;
    }

    @Override
    public List<CalismaOdasi> getAll() {
        return calismaOdasiRepository.findAll();
    }

    @Override
    public CalismaOdasi getById(int id) {
        return calismaOdasiRepository.findById(id).orElse(null);
    }

    @Override
    @Transactional
    public void add(CalismaOdasi calismaOdasi) {
        calismaOdasiRepository.save(calismaOdasi);
    }

    @Override
    @Transactional
    public void update(CalismaOdasi calismaOdasi) {
        calismaOdasiRepository.save(calismaOdasi);
    }

    @Override
    @Transactional
    public void delete(int id) {
        calismaOdasiRepository.deleteById(id);
    }

    @Override
    public List<CalismaOdasi> getByOdaTipi(String odaTipi) {
        return calismaOdasiRepository.findByOdaTipi(odaTipi);
    }
}