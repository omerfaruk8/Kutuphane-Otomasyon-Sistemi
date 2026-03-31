package com.example.SpringProje.KutuphaneProje.Business;

import com.example.SpringProje.KutuphaneProje.Entities.KitapOdunc;
import java.time.LocalDate;
import java.util.List;

/**
 * Kitap ödünç alma, iade, iptal ve teslimat süreçlerinin
 * iş kurallarını tanımlayan servis arayüzü.
 */
public interface IKitapOduncService {
    List<KitapOdunc> getAll();
    KitapOdunc getById(int id);
    void add(KitapOdunc kitapOdunc);
    void update(KitapOdunc kitapOdunc);

    void iptalEt(int id);

    List<KitapOdunc> getByKullaniciId(int kullaniciId);
    boolean hasActiveBorrow(int kitapId, LocalDate after);

    List<KitapOdunc> getPendingBorrows();
    void setKullaniciyaVerildi(int oduncId);
    void returnBook(int oduncId);
    List<KitapOdunc> getActiveBorrows();

    void rejectBorrow(int oduncId);
}