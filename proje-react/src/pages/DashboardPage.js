import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './DashboardPage.css';

const SEANS_MAP = {
  'SEANS9': '09:00 - 11:00',
  'SEANS11': '11:00 - 13:00',
  'SEANS13': '13:00 - 15:00',
  'SEANS15': '15:00 - 17:00',
  'SEANS17': '17:00 - 19:00'
};

function DashboardPage() {
  const navigate = useNavigate();
  const [userName, setUserName] = useState('');
  const [reservations, setReservations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [cezali, setCezali] = useState(false);
  const [cezaBitisTarihi, setCezaBitisTarihi] = useState(null);

  const API_URL = 'http://localhost:8080/api';
  const authAxios = axios.create({ baseURL: API_URL });

  authAxios.interceptors.request.use(config => {
    const token = localStorage.getItem('userAuthToken');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    config.withCredentials = true;
    return config;
  });

  const handleKitapIptalEt = async (id) => {
    if (!window.confirm('Bu kitap isteğini iptal etmek istiyor musunuz?')) return;
    try {
      await authAxios.put(`/borrows/cancel/${id}`, {});
      alert('Kitap isteği iptal edildi.');
      window.location.reload();
    } catch (err) {
      alert('İptal işlemi başarısız.');
    }
  };

  const handleMasaIptalEt = async (id) => {
    if (!window.confirm('Bu masa rezervasyonunu iptal etmek istiyor musunuz?')) return;
    try {
      await authAxios.delete(`/reservations/delete/${id}`);
      window.location.reload();
    } catch (err) {
      alert('İptal işlemi başarısız.');
    }
  };

  const handleDavetOnayla = async (id) => {
    try {
      await authAxios.put(`/reservations/approve/${id}`, {});
      alert("Davet kabul edildi! 🎉");
      window.location.reload();
    } catch (err) {
      alert("İşlem başarısız.");
    }
  };

  const handleDavetReddet = async (id) => {
    if (!window.confirm("Daveti reddetmek istediğinize emin misiniz?")) return;
    try {
      await authAxios.put(`/reservations/reject/${id}`, {});
      alert("Davet reddedildi.");
      window.location.reload();
    } catch (err) {
      alert("İşlem başarısız.");
    }
  };

  useEffect(() => {
    const fetchUserAndReservations = async () => {
      const currentUserId = localStorage.getItem('userId');
      const currentUserName = localStorage.getItem('userName');
      const authToken = localStorage.getItem('userAuthToken');

      if (!authToken || !currentUserId) {
        navigate('/login');
        return;
      }

      setUserName(currentUserName || 'Kullanıcı');
      const userId = currentUserId;

      try {
        const [cezaResult, masaResult, kitapResult] = await Promise.allSettled([
          authAxios.get(`/ceza/durum/${userId}`),
          authAxios.get(`/reservations/user/${userId}`),
          authAxios.get(`/borrows/user/${userId}`)
        ]);

        if (cezaResult.status === 'fulfilled' && cezaResult.value.data?.cezaBitisTarihi) {
          const cBitis = cezaResult.value.data.cezaBitisTarihi;
          if (new Date(cBitis + 'T23:59:59Z') > new Date()) {
            setCezali(true);
            setCezaBitisTarihi(cBitis);
          }
        }

        let masaReservations = [];
        let kitapReservations = [];
        const bugun = new Date();

        if (masaResult.status === 'fulfilled' && Array.isArray(masaResult.value.data)) {
          masaReservations = masaResult.value.data.map(r => {
            let status = 'normal';
            let uyarı = null;
            let isInvite = false;

            if (r.durum === 'ONAY_BEKLIYOR') {
              status = 'invite';
              uyarı = 'Davet Bekliyor 📩';
              isInvite = true;
            }

            return {
              id: `masa-${r.rezervasyonId}`,
              rawId: r.rezervasyonId,
              type: 'Masa',
              detail: `${r.calismaOdasi?.odaAdi || 'Oda'} - Sandalye ${r.sandalyeNo}`,
              date: r.tarih || 'Tarih Bilinmiyor',
              time: SEANS_MAP[r.seans] || r.seans,
              status,
              uyarı,
              isInvite
            };
          });
        }

        if (kitapResult.status === 'fulfilled' && Array.isArray(kitapResult.value.data)) {
          const aktifKitaplar = kitapResult.value.data.filter(r =>
            r.durum === 'BEKLEMEDE' || r.durum === 'KULLANICIDA'
          );

          kitapReservations = aktifKitaplar.map(r => {
            const bitis = new Date(r.bitisTarihi);
            const farkGun = Math.ceil((bitis - bugun) / (1000 * 60 * 60 * 24));

            let status = 'normal';
            let uyarı = null;
            let isPending = false;

            if (r.durum === 'BEKLEMEDE') {
              status = 'pending';
              uyarı = 'Onay Bekliyor ⏳';
              isPending = true;
            } else if (r.durum === 'KULLANICIDA') {
              if (bitis < bugun) { status = 'expired'; uyarı = 'Süre Doldu!'; }
              else if (farkGun <= 2) { status = 'warning'; uyarı = `Son ${farkGun} Gün`; }
            }

            return {
              id: `kitap-${r.oduncId}`,
              rawId: r.oduncId,
              type: 'Kitap',
              detail: `${r.kitap?.kitapAdi} - ${r.kitap?.yazar}`,
              date: `Teslim: ${bitis.toLocaleDateString('tr-TR')}`,
              status,
              uyarı,
              isPending
            };
          });
        }

        setReservations([...masaReservations, ...kitapReservations]);

      } catch (err) {
      } finally {
        setLoading(false);
      }
    };

    fetchUserAndReservations();
  }, [navigate]);

  const handleLogout = () => {
    localStorage.clear();
    navigate('/login');
  };

  if (loading) return <div className="loading-screen">Yükleniyor...</div>;

  return (
    <div className="dashboard-wrapper">
      <div className="dashboard-container">
        <header className="dashboard-header">
          <div className="header-text">
            <h1>Merhaba, {userName} 👋</h1>
            <p>Bugün ne yapmak istersin?</p>
          </div>
          <div className="header-actions">
            <button className="btn-profile" onClick={() => navigate('/profile')}>👤 Profilim</button>
            <button className="btn-logout" onClick={handleLogout}>Çıkış Yap</button>
          </div>
        </header>

        {cezali && (
          <div className="alert-banner error">
            <h3>⚠️ Hesabınızda Kısıtlama Var</h3>
            <p>Ceza Bitiş: {new Date(cezaBitisTarihi).toLocaleDateString('tr-TR')}</p>
          </div>
        )}

        <section className="action-section">
          <h2>Hızlı İşlemler</h2>
          <div className="action-grid">
            <div className={`action-card ${cezali ? 'disabled' : ''}`} onClick={() => !cezali && navigate('/kitaplar')}>
              <div className="icon">📚</div>
              <div className="info"><h3>Kitap Ödünç Al</h3></div>
            </div>
            <div className={`action-card ${cezali ? 'disabled' : ''}`} onClick={() => !cezali && navigate('/masalar')}>
              <div className="icon">🪑</div>
              <div className="info"><h3>Masa Rezerve Et</h3></div>
            </div>
          </div>
        </section>

        <section className="history-section">
          <h2>Aktif İşlemlerim ({reservations.length})</h2>
          {reservations.length > 0 ? (
            <div className="reservation-grid">
              {reservations.map(r => (
                <div key={r.id} className={`res-card ${r.status}`}>
                  <div className="res-card-header">
                    <span className="res-type">{r.type === 'Masa' ? '🪑 Masa' : '📖 Kitap'}</span>
                    {r.uyarı && <span className={`res-badge ${r.status === 'invite' ? 'invite-badge' : 'warning'}`}>{r.uyarı}</span>}
                  </div>

                  <div className="res-card-body">
                    <h4>{r.detail}</h4>
                    <div className="date-time-row">
                      <p className="res-date">📅 {r.date}</p>
                      {r.time && <span className="session-badge">⏰ {r.time}</span>}
                    </div>
                  </div>

                  <div className="res-card-footer">
                    {r.type === 'Masa' && r.isInvite && (
                      <div className="invite-actions">
                        <button className="btn-reject" onClick={(e) => {
                          e.stopPropagation();
                          handleDavetReddet(r.rawId);
                        }}>Reddet</button>

                        <button className="btn-accept" onClick={(e) => {
                          e.stopPropagation();
                          handleDavetOnayla(r.rawId);
                        }}>Kabul Et</button>
                      </div>
                    )}

                    {r.type === 'Masa' && !r.isInvite && r.status === 'normal' && (
                      <button className="btn-cancel" onClick={(e) => {
                        e.stopPropagation();
                        handleMasaIptalEt(r.rawId);
                      }}>İptal Et</button>
                    )}

                    {r.type === 'Kitap' && r.isPending && (
                      <button className="btn-cancel" onClick={(e) => {
                        e.stopPropagation();
                        handleKitapIptalEt(r.rawId);
                      }}>İptal Et</button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty-state"><p>📭 Henüz aktif bir işleminiz bulunmuyor.</p></div>
          )}
        </section>
      </div>
    </div>
  );
}

export default DashboardPage;