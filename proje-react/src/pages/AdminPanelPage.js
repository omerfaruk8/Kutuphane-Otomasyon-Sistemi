import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './AdminPanelPage.css';

const API_URL = 'http://localhost:8080/api';

const authAxios = axios.create({
  baseURL: API_URL,
});

authAxios.interceptors.request.use(config => {
  const token = localStorage.getItem('adminAuthToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  config.withCredentials = true;
  return config;
});

function AdminPanelPage() {
  const navigate = useNavigate();

  const [kitapTalepleri, setKitapTalepleri] = useState([]);
  const [aktifKitaplar, setAktifKitaplar] = useState([]);
  const [masaRezervasyonlari, setMasaRezervasyonlari] = useState([]);
  const [tumKitaplar, setTumKitaplar] = useState([]);

  const [showBookModal, setShowBookModal] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [bookForm, setBookForm] = useState({
    kitapId: null,
    kitapAdi: '',
    yazar: '',
    kategori: '',
    stokSayisi: 1,
    musaitAdet: 1
  });

  const [cezaSorguId, setCezaSorguId] = useState('');
  const [cezaSonuc, setCezaSonuc] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem('adminAuthToken');
    const role = localStorage.getItem('role');

    if (!token || role !== 'ADMIN') {
      navigate('/admin-login');
      return;
    }

    fetchAllData();
    document.body.classList.add('admin-body');
    return () => {
      document.body.classList.remove('admin-body');
    };
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('adminAuthToken');
    localStorage.removeItem('adminUserId');
    localStorage.removeItem('userName');
    localStorage.removeItem('role');
    navigate('/admin-login');
  };

  const fetchAllData = async () => {
    await Promise.allSettled([
      fetchKitapTalepleri(),
      fetchAktifKitaplar(),
      fetchMasaRezervasyonlari(),
      fetchTumKitaplar()
    ]);
  };


  const fetchKitapTalepleri = async () => {
    try { const res = await authAxios.get('/borrows/pending'); setKitapTalepleri(res.data); } catch (e) { }
  };
  const fetchAktifKitaplar = async () => {
    try { const res = await authAxios.get('/borrows/active-borrows'); setAktifKitaplar(res.data); } catch (e) { }
  };
  const fetchMasaRezervasyonlari = async () => {
    try { const res = await authAxios.get('/reservations/active'); setMasaRezervasyonlari(res.data); } catch (e) { }
  };
  const fetchTumKitaplar = async () => {
    try { const res = await authAxios.get('/kitaplar'); setTumKitaplar(res.data); } catch (e) { }
  };

  const handleKitapOnayla = async (id) => { if (window.confirm('Onaylıyor musunuz?')) { await authAxios.post(`/borrows/approve/${id}`, {}); fetchAllData(); } };
  const handleKitapReddet = async (id) => { if (window.confirm('Reddediyor musunuz?')) { await authAxios.post(`/borrows/reject/${id}`, {}); fetchAllData(); } };
  const handleKitapIadeAl = async (id) => { if (window.confirm('İade alıyor musunuz?')) { await authAxios.post(`/borrows/return/${id}`, {}); fetchAllData(); } };
  const handleMasaIptal = async (id) => { if (window.confirm('İptal ediyor musunuz?')) { await authAxios.delete(`/reservations/delete/${id}`); fetchMasaRezervasyonlari(); } };


  const openAddBookModal = () => {
    setBookForm({ kitapId: null, kitapAdi: '', yazar: '', kategori: '', stokSayisi: 1, musaitAdet: 1 });
    setIsEditing(false);
    setShowBookModal(true);
  };

  const openEditBookModal = (kitap) => {
    setBookForm({ ...kitap });
    setIsEditing(true);
    setShowBookModal(true);
  };

  const handleBookSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditing) {
        await authAxios.post('/kitaplar/update', bookForm);
        alert("Kitap güncellendi!");
      } else {
        const yeniKitap = { ...bookForm, musaitAdet: bookForm.stokSayisi };
        await authAxios.post('/kitaplar/add', yeniKitap);
        alert("Kitap eklendi!");
      }
      setShowBookModal(false);
      fetchTumKitaplar();
    } catch (error) {
      alert("İşlem sırasında hata oluştu: " + error.message);
    }
  };

  const handleDeleteBook = async (id) => {
    if (!window.confirm("Bu kitabı silmek istediğinize emin misiniz?")) return;
    try {
      await authAxios.delete(`/kitaplar/delete/${id}`);
      alert("Kitap silindi.");
      fetchTumKitaplar();
    } catch (error) {
      alert("Silinemedi (Kitap kullanımda olabilir).");
    }
  };


  const handleCezaSorgula = async () => {
    if (!cezaSorguId) return;
    try {
      const res = await authAxios.get(`/ceza/durum/${cezaSorguId}`);
      setCezaSonuc({ ...res.data, kullaniciId: cezaSorguId });
    } catch (error) {
      alert("Kullanıcı bulunamadı veya hata oluştu.");
      setCezaSonuc(null);
    }
  };

  const handleCezaKaldir = async () => {
    if (!cezaSonuc || !cezaSonuc.cezali) return;
    if (!window.confirm("Bu kullanıcının cezasını kaldırmak istediğinize emin misiniz?")) return;

    try {
      await authAxios.post(`/ceza/kaldir/${cezaSonuc.kullaniciId}`);
      alert("Ceza kaldırıldı!");
      handleCezaSorgula();
    } catch (error) {
      alert("Ceza kaldırılamadı: " + error.message);
    }
  };

  return (
    <div className="admin-dashboard">
      <div className="admin-header-row">
        <h2>📚 Yönetim Paneli</h2>
        <button onClick={handleLogout} className="btn-logout">Çıkış Yap</button>
      </div>

      <div className="admin-grid">

        <div className="admin-col">

          <section className="admin-card">
            <h3>⚖️ Ceza Yönetimi</h3>
            <div className="search-row">
              <input
                type="number"
                placeholder="Kullanıcı ID Girin"
                value={cezaSorguId}
                onChange={(e) => setCezaSorguId(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') handleCezaSorgula();
                }}
              />
              <button onClick={handleCezaSorgula}>Sorgula</button>
            </div>

            {cezaSonuc && (
              <div className="ceza-result">

                <div className="user-info">
                  <h4>{cezaSonuc.adSoyad || 'İsimsiz Kullanıcı'}</h4>
                  <span className="user-mail">{cezaSonuc.email || 'E-posta yok'}</span>
                </div>
                <hr className="ceza-divider" />

                <p><strong>Durum:</strong> {cezaSonuc.cezali ? <span className="red-badge">CEZALI</span> : <span className="green-badge">TEMİZ</span>}</p>
                {cezaSonuc.cezali && (
                  <>
                    <p style={{ marginTop: '5px' }}><strong>Bitiş:</strong> {cezaSonuc.cezaBitisTarihi}</p>
                    <button className="btn-ceza-kaldir" onClick={handleCezaKaldir}>Cezayı Kaldır</button>
                  </>
                )}
              </div>
            )}
          </section>

          <section className="admin-card">
            <div className="card-header">
              <h3>📖 Kitap Envanteri</h3>
              <button className="btn-add" onClick={openAddBookModal}>+ Yeni Kitap</button>
            </div>
            <div className="table-scroll">
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Ad</th>
                    <th>Stok</th>
                    <th>İşlem</th>
                  </tr>
                </thead>
                <tbody>
                  {tumKitaplar.map(k => (
                    <tr key={k.kitapId}>
                      <td>{k.kitapId}</td>
                      <td>{k.kitapAdi}</td>
                      <td>{k.stokSayisi}</td>
                      <td>
                        <button className="btn-small edit" onClick={() => openEditBookModal(k)}>✏️</button>
                        <button className="btn-small delete" onClick={() => handleDeleteBook(k.kitapId)}>🗑️</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        </div>

        <div className="admin-col">
          <section className="admin-card">
            <h3>🔔 Bekleyen Kitap Talepleri</h3>
            {kitapTalepleri.length === 0 ? <p className="empty-msg">Bekleyen talep yok.</p> : (
              <table>
                <thead>
                  <tr>
                    <th>Kişi</th>
                    <th>Kitap</th>
                    <th>İşlem</th>
                  </tr>
                </thead>
                <tbody>
                  {kitapTalepleri.map(k => (
                    <tr key={k.oduncId}>
                      <td>{k.kullanici?.adSoyad}</td>
                      <td>{k.kitap?.kitapAdi}</td>
                      <td>
                        <button className="btn-small confirm" onClick={() => handleKitapOnayla(k.oduncId)}>✓</button>
                        <button className="btn-small cancel" onClick={() => handleKitapReddet(k.oduncId)}>✗</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </section>

          <section className="admin-card">
            <h3>📖 Kullanıcıdaki Kitaplar</h3>
            <table>
              <thead>
                <tr>
                  <th>Kişi</th>
                  <th>Kitap</th>
                  <th>Tarih</th>
                  <th>İşlem</th>
                </tr>
              </thead>
              <tbody>
                {aktifKitaplar.map(k => (
                  <tr key={k.oduncId}>
                    <td>{k.kullanici?.adSoyad}</td>
                    <td>{k.kitap?.kitapAdi}</td>
                    <td>{k.bitisTarihi}</td>
                    <td>
                      <button className="btn-small return" onClick={() => handleKitapIadeAl(k.oduncId)}>İade Al</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>

          <section className="admin-card">
            <h3>🪑 Masa Durumu</h3>
            <table>
              <thead>
                <tr>
                  <th>Kişi</th>
                  <th>Oda/Sandalye</th>
                  <th>Saat</th>
                  <th>İşlem</th>
                </tr>
              </thead>
              <tbody>
                {masaRezervasyonlari.map(r => (
                  <tr key={r.rezervasyonId}>
                    <td>{r.kullanici?.adSoyad}</td>
                    <td>{r.calismaOdasi?.odaAdi} / {r.sandalyeNo}</td>
                    <td>{r.seans}</td>
                    <td>
                      <button className="btn-small cancel" onClick={() => handleMasaIptal(r.rezervasyonId)}>İptal</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        </div>
      </div>

      {showBookModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3>{isEditing ? 'Kitabı Düzenle' : 'Yeni Kitap Ekle'}</h3>
            <form onSubmit={handleBookSubmit}>
              <div className="form-group">
                <label>Kitap Adı</label>
                <input required type="text" value={bookForm.kitapAdi} onChange={e => setBookForm({ ...bookForm, kitapAdi: e.target.value })} />
              </div>
              <div className="form-group">
                <label>Yazar</label>
                <input required type="text" value={bookForm.yazar} onChange={e => setBookForm({ ...bookForm, yazar: e.target.value })} />
              </div>
              <div className="form-group">
                <label>Kategori</label>
                <input required type="text" value={bookForm.kategori} onChange={e => setBookForm({ ...bookForm, kategori: e.target.value })} />
              </div>
              <div className="form-group">
                <label>Stok Sayısı</label>
                <input required type="number" min="1" value={bookForm.stokSayisi} onChange={e => setBookForm({ ...bookForm, stokSayisi: parseInt(e.target.value) })} />
              </div>
              <div className="modal-actions">
                <button type="button" className="btn-cancel" onClick={() => setShowBookModal(false)}>İptal</button>
                <button type="submit" className="btn-confirm">Kaydet</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}

export default AdminPanelPage;