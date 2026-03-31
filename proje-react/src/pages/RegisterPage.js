import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import axios from 'axios';
import './RegisterPage.css';

function RegisterPage() {
  const [adSoyad, setAdSoyad] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mesaj, setMesaj] = useState('');
  const [hata, setHata] = useState('');

  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    if (params.get('status') === 'confirmed') {
      setMesaj("Kayıt başarıyla tamamlandı. Giriş yapabilirsiniz.");
    }
  }, [location]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMesaj('');
    setHata('');

    try {
      const response = await axios.post('http://localhost:8080/api/register', {
        adSoyad,
        email,
        password,
      }, { withCredentials: true });

      const successMessage = response.data && response.data.message
        ? response.data.message
        : 'Kayıt başarılı! Lütfen giriş yapınız.';

      setMesaj(successMessage);

      if (response.data && response.data.token) {
        localStorage.setItem('authToken', response.data.token);
      }

      setAdSoyad('');
      setEmail('');
      setPassword('');


    } catch (err) {
      let errorMessage = "Kayıt sırasında bir hata oluştu.";

      if (err.response) {
        const data = err.response.data;

        if (typeof data === 'object' && data !== null) {
          errorMessage = Object.values(data).join("\n");
        }
        else if (typeof data === 'string') {
          errorMessage = data;
        }
      }

      setHata(errorMessage);
    }
  };

  return (
    <div className="register-page-wrapper">
      <div className="register-container">
        <h2>Hesap Oluştur</h2>
        <p className="sub-text">Aramıza katılmak için bilgilerinizi girin.</p>

        <form onSubmit={handleSubmit}>
          <div className="input-group">
            <input
              type="text"
              id="adSoyad"
              placeholder=" "
              value={adSoyad}
              onChange={(e) => setAdSoyad(e.target.value)}
              required
            />
            <label htmlFor="adSoyad">Ad Soyad</label>
          </div>

          <div className="input-group">
            <input
              type="email"
              id="email"
              placeholder=" "
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <label htmlFor="email">E-posta Adresi</label>
          </div>

          <div className="input-group">
            <input
              type="password"
              id="password"
              placeholder=" "
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <label htmlFor="password">Şifre</label>
          </div>

          <button type="submit">Kayıt Ol</button>
        </form>

        {mesaj && <div className="alert basarili">{mesaj}</div>}

        {hata && (
          <div className="alert hata" style={{ whiteSpace: 'pre-line' }}>
            {hata}
          </div>
        )}

        <div className="auth-actions">
          <p>
            Zaten bir hesabın var mı?
            <span onClick={() => navigate('/login')} className="link-text"> Giriş Yap</span>
          </p>
        </div>

      </div>
    </div>
  );
}

export default RegisterPage;