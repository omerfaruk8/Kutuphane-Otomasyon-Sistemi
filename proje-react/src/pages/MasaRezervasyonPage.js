import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './MasaRezervasyonPage.css';

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

const seanslar = [
  { label: "09:00 - 11:00", value: "SEANS9", endHour: 11 },
  { label: "11:00 - 13:00", value: "SEANS11", endHour: 13 },
  { label: "13:00 - 15:00", value: "SEANS13", endHour: 15 },
  { label: "15:00 - 17:00", value: "SEANS15", endHour: 17 },
  { label: "17:00 - 19:00", value: "SEANS17", endHour: 19 }
];

const isSeansDisabled = (seansValue, selectedDate) => {
  const today = new Date();
  const selectedDay = selectedDate.toISOString().split('T')[0];
  const todayDay = today.toISOString().split('T')[0];

  if (selectedDay !== todayDay) return false;

  const seans = seanslar.find(s => s.value === seansValue);
  if (!seans) return true;

  const seansEndTime = new Date(today.getFullYear(), today.getMonth(), today.getDate(), seans.endHour, 0, 0);
  const currentTimePlusBuffer = new Date(today.getTime() + 15 * 60000);

  return seansEndTime <= currentTimePlusBuffer;
};

function MasaRezervasyonPage() {
  const navigate = useNavigate();
  const [odalar, setOdalar] = useState([]);
  const [seciliOda, setSeciliOda] = useState(null);
  const [selectedSeans, setSelectedSeans] = useState("");
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [doluSandalyeler, setDoluSandalyeler] = useState([]);

  const [currentUserEmail, setCurrentUserEmail] = useState("");

  const [grupModu, setGrupModu] = useState(false);
  const [grupKisiSayisi, setGrupKisiSayisi] = useState(1);
  const [grupEmailList, setGrupEmailList] = useState([]);
  const [selectedSandalyeler, setSelectedSandalyeler] = useState([]);

  useEffect(() => {
    const storedEmail = localStorage.getItem('email') || localStorage.getItem('userEmail');
    if (storedEmail) {
      setCurrentUserEmail(storedEmail);
    } else {
      const userId = localStorage.getItem('userId');
      if (userId) {
        authAxios.get(`/kullanicilar/${userId}`).then(res => {
          if (res.data.email) {
            setCurrentUserEmail(res.data.email);
            localStorage.setItem('userEmail', res.data.email);
          }
        })
      }
    }

    authAxios.get('/odalar')
      .then(res => {
        setOdalar(res.data);
        if (res.data.length > 0) setSeciliOda(res.data[0]);
      })
      .catch(err => {
        if (err.response?.status === 401 || err.response?.status === 403) {
          alert("Oturumunuz sona erdi.");
          navigate('/login');
        }
      });
  }, [navigate]);

  useEffect(() => {
    if (seciliOda && selectedSeans && selectedDate) {
      checkDolulukDurumu(seciliOda.odaId, selectedSeans, selectedDate);
    } else {
      setDoluSandalyeler([]);
      setSelectedSandalyeler([]);
    }
  }, [seciliOda, selectedSeans, selectedDate]);

  const checkDolulukDurumu = async (odaId, seans, tarihObj) => {
    try {
      const tarihStr = tarihObj.toISOString().split('T')[0];
      const res = await authAxios.get(`/reservations/room/${odaId}`);

      const doluListesi = res.data
        .filter(r =>
          r.seans === seans &&
          r.tarih === tarihStr &&
          (r.durum === 'AKTIF' || r.durum === 'ONAY_BEKLIYOR')
        )
        .map(r => String(r.sandalyeNo));

      setDoluSandalyeler(doluListesi);
    } catch (err) {
    }
  };

  const getMaxDate = () => {
    const max = new Date();
    max.setDate(max.getDate() + 7);
    return max.toISOString().split('T')[0];
  };

  const handleSandalyeClick = (sandalyeNo) => {
    const strNo = String(sandalyeNo);
    if (!selectedSeans) {
      alert("Lütfen önce bir seans seçiniz.");
      return;
    }
    if (doluSandalyeler.includes(strNo)) return;

    if (grupModu) {
      if (selectedSandalyeler.includes(sandalyeNo)) {
        setSelectedSandalyeler(selectedSandalyeler.filter(no => no !== sandalyeNo));
      } else if (selectedSandalyeler.length < grupKisiSayisi) {
        setSelectedSandalyeler([...selectedSandalyeler, sandalyeNo]);
      } else {
        alert(`En fazla ${grupKisiSayisi} sandalye seçebilirsiniz.`);
      }
    } else {
      if (selectedSandalyeler.includes(sandalyeNo)) {
        setSelectedSandalyeler([]);
      } else {
        setSelectedSandalyeler([sandalyeNo]);
      }
    }
  };

  const handleReservationSubmit = async () => {
    const userId = localStorage.getItem('userId');
    const loginUserEmail = currentUserEmail;
    const tarihStr = selectedDate.toISOString().split('T')[0];

    if (!userId || !seciliOda || !selectedSeans || selectedSandalyeler.length === 0) {
      alert("Lütfen tüm seçimleri eksiksiz yapınız.");
      return;
    }

    if (isSeansDisabled(selectedSeans, selectedDate)) {
      alert("Seçtiğiniz seansın süresi dolmuştur.");
      return;
    }

    if (grupModu) {
      if (selectedSandalyeler.length !== grupKisiSayisi) {
        alert(`Lütfen ${grupKisiSayisi} adet sandalye seçiniz.`);
        return;
      }
      if (grupEmailList.length !== grupKisiSayisi - 1 || grupEmailList.some(email => !email.trim())) {
        alert("Tüm grup üyelerinin e-posta adreslerini giriniz.");
        return;
      }
      if (!loginUserEmail) {
        alert("E-posta bilginiz bulunamadı. Lütfen tekrar giriş yapın.");
        return;
      }

      try {
        let rezervasyonlar = [];

        rezervasyonlar.push({
          kullanici: { kullaniciId: parseInt(userId) },
          calismaOdasi: { odaId: seciliOda.odaId },
          sandalyeNo: selectedSandalyeler[0],
          seans: selectedSeans,
          tarih: tarihStr
        });

        for (let i = 0; i < grupEmailList.length; i++) {
          const email = grupEmailList[i].trim();
          const userResp = await authAxios.get(`/kullanicilar/email/${encodeURIComponent(email)}`);

          rezervasyonlar.push({
            kullanici: { kullaniciId: userResp.data.kullaniciId },
            calismaOdasi: { odaId: seciliOda.odaId },
            sandalyeNo: selectedSandalyeler[i + 1],
            seans: selectedSeans,
            tarih: tarihStr
          });
        }

        await authAxios.post('/reservations/addGrup', {
          girisYapanEmail: loginUserEmail,
          rezervasyonlar: rezervasyonlar
        });

        alert("Grup rezervasyonu başarılı! Arkadaşlarınıza bildirim gitti. 🎉");
        window.location.reload();

      } catch (err) {
        const msg = err.response?.data || err.message;
        alert("Hata: " + (typeof msg === 'object' ? JSON.stringify(msg) : msg));
      }

    } else {
      const rezervasyon = {
        kullanici: { kullaniciId: parseInt(userId) },
        calismaOdasi: { odaId: seciliOda.odaId },
        sandalyeNo: selectedSandalyeler[0],
        seans: selectedSeans,
        tarih: tarihStr
      };

      try {
        await authAxios.post('/reservations/add', rezervasyon);
        alert("Rezervasyon başarılı! 🎉");
        window.location.reload();
      } catch (err) {
        alert("Hata: " + (err.response?.data || err.message));
      }
    }
  };

  return (
    <div className="reservation-page-wrapper">
      <div className="reservation-container">

        <div className="page-header">
          <button className="btn-back" onClick={() => navigate('/dashboard')}>← Geri</button>
          <h2>Masa Rezervasyonu</h2>
          <p>Çalışmak istediğiniz alanı ve saati seçin.</p>
        </div>

        <div className="filter-bar">
          <div className="filter-item">
            <label>📅 Tarih</label>
            <input
              type="date"
              value={selectedDate.toISOString().split('T')[0]}
              onChange={(e) => setSelectedDate(new Date(e.target.value))}
              min={new Date().toISOString().split('T')[0]}
              max={getMaxDate()}
            />
          </div>

          <div className="filter-item">
            <label>🏢 Çalışma Odası</label>
            <select value={seciliOda?.odaId || ''} onChange={(e) => {
              const oda = odalar.find(o => o.odaId === parseInt(e.target.value));
              setSeciliOda(oda);
            }}>
              {odalar.map(oda => (
                <option key={oda.odaId} value={oda.odaId}>
                  {oda.odaAdi} ({oda.odaTipi})
                </option>
              ))}
            </select>
          </div>

          <div className="filter-item">
            <label>⏰ Seans</label>
            <select value={selectedSeans} onChange={(e) => setSelectedSeans(e.target.value)}>
              <option value="">Seçiniz...</option>
              {seanslar.map(seans => (
                <option
                  key={seans.value}
                  value={seans.value}
                  disabled={isSeansDisabled(seans.value, selectedDate)}
                >
                  {seans.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="group-toggle-section">
          <label className="switch-label">
            <input
              type="checkbox"
              checked={grupModu}
              onChange={(e) => {
                setGrupModu(e.target.checked);
                setGrupKisiSayisi(1);
                setSelectedSandalyeler([]);
                setGrupEmailList([]);
              }}
            />
            <span className="toggle-text">👥 Arkadaşlarımla Çalışacağım (Grup Modu)</span>
          </label>

          {grupModu && (
            <div className="group-controls">
              <span>Kişi Sayısı:</span>
              <input
                type="number"
                min="2"
                max="6"
                value={grupKisiSayisi}
                onChange={(e) => {
                  const val = parseInt(e.target.value);
                  setGrupKisiSayisi(val);
                  setGrupEmailList(Array(val - 1).fill(""));
                  setSelectedSandalyeler([]);
                }}
              />
            </div>
          )}
        </div>

        <div className="legend">
          <div className="legend-item"><span className="dot empty"></span> Boş</div>
          <div className="legend-item"><span className="dot selected"></span> Seçili</div>
          <div className="legend-item"><span className="dot full"></span> Dolu</div>
        </div>

        <div className="room-layout">
          <div className="tables-grid">
            {[...Array(5)].map((_, masaIndex) => (
              <div key={masaIndex} className="table-unit">
                <div className="chairs-row top">
                  {[...Array(3)].map((_, i) => {
                    const sandalyeNo = masaIndex * 6 + i + 1;
                    const strNo = String(sandalyeNo);
                    const isFull = doluSandalyeler.includes(strNo);
                    const isSelected = selectedSandalyeler.includes(sandalyeNo);

                    return (
                      <div
                        key={sandalyeNo}
                        className={`chair ${isFull ? 'full' : ''} ${isSelected ? 'selected' : ''}`}
                        onClick={() => !isFull && handleSandalyeClick(sandalyeNo)}
                        title={`Sandalye ${sandalyeNo}`}
                      >
                        {sandalyeNo}
                      </div>
                    );
                  })}
                </div>
                <div className="desk-body">
                  <span>Masa {masaIndex + 1}</span>
                </div>
                <div className="chairs-row bottom">
                  {[...Array(3)].map((_, i) => {
                    const sandalyeNo = masaIndex * 6 + i + 4;
                    const strNo = String(sandalyeNo);
                    const isFull = doluSandalyeler.includes(strNo);
                    const isSelected = selectedSandalyeler.includes(sandalyeNo);

                    return (
                      <div
                        key={sandalyeNo}
                        className={`chair ${isFull ? 'full' : ''} ${isSelected ? 'selected' : ''}`}
                        onClick={() => !isFull && handleSandalyeClick(sandalyeNo)}
                        title={`Sandalye ${sandalyeNo}`}
                      >
                        {sandalyeNo}
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </div>

        {grupModu && selectedSandalyeler.length === grupKisiSayisi && (
          <div className="email-inputs-card">
            <h4>📧 Grup Üyeleri</h4>
            <p>Lütfen arkadaşlarınızın kayıtlı e-posta adreslerini girin.</p>
            <div className="inputs-grid">
              {grupEmailList.map((email, index) => (
                <div key={index} className="input-row">
                  <span className="badge">{index + 2}. Üye</span>
                  <input
                    type="email"
                    placeholder="ornek@email.com"
                    value={email}
                    onChange={(e) => {
                      const newList = [...grupEmailList];
                      newList[index] = e.target.value;
                      setGrupEmailList(newList);
                    }}
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="action-footer">
          <div className="summary">
            {selectedSandalyeler.length > 0
              ? `Seçilen Yerler: ${selectedSandalyeler.join(', ')}`
              : 'Henüz yer seçilmedi'}
          </div>
          <button
            className="btn-confirm"
            onClick={handleReservationSubmit}
            disabled={selectedSandalyeler.length === 0}
          >
            Rezervasyonu Tamamla ✅
          </button>
        </div>

      </div>
    </div>
  );
}

export default MasaRezervasyonPage;