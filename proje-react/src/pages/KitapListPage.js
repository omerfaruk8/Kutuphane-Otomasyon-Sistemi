import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Modal from 'react-modal';
import DatePicker from 'react-datepicker';
import { useNavigate } from 'react-router-dom';
import 'react-datepicker/dist/react-datepicker.css';
import './KitapListPage.css';

Modal.setAppElement('#root');

const API_URL = 'http://localhost:8080/api';

const authAxios = axios.create({
  baseURL: API_URL,
});

authAxios.interceptors.request.use(config => {
  const token = localStorage.getItem('userAuthToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  config.withCredentials = true;
  return config;
});

function KitapListPage() {
  const navigate = useNavigate();
  const [kitaplar, setKitaplar] = useState([]);
  const [searchKeyword, setSearchKeyword] = useState('');
  const [modalIsOpen, setModalIsOpen] = useState(false);
  const [selectedKitap, setSelectedKitap] = useState(null);

  const [startDate, setStartDate] = useState(new Date());
  const [endDate, setEndDate] = useState(new Date());

  useEffect(() => {
    fetchBooks();
  }, []);

  const fetchBooks = async () => {
    try {
      const response = await authAxios.get('/kitaplar');
      setKitaplar(response.data);
    } catch (error) {
      if (error.response?.status === 401 || error.response?.status === 403) {
        alert("Oturum süreniz doldu veya yetkiniz yok. Lütfen tekrar giriş yapın.");
        navigate('/login');
      }
    }
  };

  const openModal = (kitap) => {
    setSelectedKitap(kitap);
    setStartDate(new Date());
    const defaultEnd = new Date();
    defaultEnd.setDate(defaultEnd.getDate() + 7);
    setEndDate(defaultEnd);

    setModalIsOpen(true);
  };

  const closeModal = () => {
    setModalIsOpen(false);
    setSelectedKitap(null);
  };

  const handleBorrowSubmit = async () => {
    const userId = localStorage.getItem('userId');
    if (!userId) {
      alert("Kullanıcı bilgisi alınamadı. Lütfen tekrar giriş yapın.");
      navigate('/login');
      return;
    }

    try {
      const borrowData = {
        kitap: { kitapId: selectedKitap.kitapId },
        kullanici: { kullaniciId: parseInt(userId) },
        baslangicTarihi: startDate.toISOString().split('T')[0],
        bitisTarihi: endDate.toISOString().split('T')[0],
      };

      await authAxios.post('/borrows/add', borrowData);

      alert("İşlem Başarılı! Kitabı ödünç alma isteğiniz gönderildi.");
      fetchBooks();
      closeModal();
    } catch (error) {
      alert("Bir hata oluştu, muhtemelen stok yetersiz veya zaten aktif bir ödüncünüz var.");
    }
  };

  const filteredBooks = kitaplar.filter(k => {
    const term = searchKeyword.toLowerCase();
    return (
      (k.kitapAdi && k.kitapAdi.toLowerCase().includes(term)) ||
      (k.yazar && k.yazar.toLowerCase().includes(term)) ||
      (k.kategori && k.kategori.toLowerCase().includes(term))
    );
  });

  return (
    <div className="kitap-page-wrapper">
      <div className="kitap-container">

        <div className="kitap-header">
          <button className="btn-back" onClick={() => navigate('/dashboard')}>
            ← Panelo Dön
          </button>
          <h2>Kütüphane Arşivi</h2>
          <p>Okumak istediğiniz kitabı arayın ve hemen ödünç alın.</p>

          <div className="search-box">
            <span className="search-icon">🔍</span>
            <input
              type="text"
              placeholder="Kitap adı, yazar veya kategori ara..."
              value={searchKeyword}
              onChange={(e) => setSearchKeyword(e.target.value)}
            />
          </div>
        </div>

        <div className="books-grid">
          {filteredBooks.length > 0 ? (
            filteredBooks.map(kitap => (
              <div key={kitap.kitapId} className="book-card">

                <div className={`book-cover ${kitap.musaitAdet === 0 ? 'out-of-stock' : ''}`}>
                  <span className="book-icon">📖</span>
                  {kitap.musaitAdet === 0 && <span className="stock-badge">Tükendi</span>}
                </div>

                <div className="book-info">
                  <h3 title={kitap.kitapAdi}>{kitap.kitapAdi}</h3>
                  <p className="author">✍️ {kitap.yazar}</p>
                  <p className="category">📂 {kitap.kategori}</p>

                  <div className="stock-info">
                    <span>Stok: {kitap.stokSayisi}</span>
                    <span className={kitap.musaitAdet > 0 ? 'available' : 'unavailable'}>
                      Müsait: {kitap.musaitAdet}
                    </span>
                  </div>

                  <button
                    className="btn-borrow"
                    onClick={() => openModal(kitap)}
                    disabled={kitap.musaitAdet === 0}
                  >
                    {kitap.musaitAdet > 0 ? 'Ödünç Al' : 'Stokta Yok'}
                  </button>
                </div>
              </div>
            ))
          ) : (
            <div className="no-result">
              <p>Aradığınız kriterlere uygun kitap bulunamadı. 😔</p>
            </div>
          )}
        </div>

      </div>

      <Modal
        isOpen={modalIsOpen}
        onRequestClose={closeModal}
        contentLabel="Tarih Seçimi"
        className="custom-modal"
        overlayClassName="custom-overlay"
      >
        <div className="modal-header">
          <h3>📅 Tarih Belirle</h3>
          <p><strong>{selectedKitap?.kitapAdi}</strong> kitabını ne kadar süreyle almak istiyorsunuz?</p>
        </div>

        <div className="modal-body">
          <div className="date-group">
            <label>Başlangıç Tarihi</label>
            <DatePicker
              selected={startDate}
              onChange={(date) => {
                setStartDate(date);
                if (endDate < date) setEndDate(date);
              }}
              dateFormat="dd/MM/yyyy"
              minDate={new Date()}
              maxDate={new Date(new Date().setDate(new Date().getDate() + 7))}
              className="custom-datepicker"
            />
          </div>

          <div className="date-group">
            <label>Teslim Tarihi</label>
            <DatePicker
              selected={endDate}
              onChange={(date) => setEndDate(date)}
              dateFormat="dd/MM/yyyy"
              minDate={startDate}
              maxDate={new Date(new Date(startDate).setDate(startDate.getDate() + 21))}
              className="custom-datepicker"
            />
          </div>
        </div>

        <div className="modal-footer">
          <button className="btn-cancel" onClick={closeModal}>Vazgeç</button>
          <button className="btn-confirm" onClick={handleBorrowSubmit}>Onayla ve Bitir</button>
        </div>
      </Modal>
    </div>
  );
}

export default KitapListPage;