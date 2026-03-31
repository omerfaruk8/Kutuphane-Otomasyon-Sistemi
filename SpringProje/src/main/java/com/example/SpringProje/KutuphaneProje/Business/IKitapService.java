package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.Kitap;

import java.util.List;

/**
 * Kütüphane envanterindeki kitapların kayıt, arama ve stok yönetim
 * süreçlerini tanımlayan servis arayüzü.
 */
public interface IKitapService {

    List<Kitap> getAll();
    Kitap getById(int id);
    void add(Kitap kitap);
    void update(Kitap kitap);
    void delete(int id);

    List<Kitap> getByKategori(String kategori);
    List<Kitap> searchByName(String keyword);
    List<Kitap> getAvailableBooks();
}
