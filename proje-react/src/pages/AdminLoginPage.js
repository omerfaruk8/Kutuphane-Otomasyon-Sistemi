import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './AdminLoginPage.css';

function AdminLoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const res = await axios.post('http://localhost:8080/api/login', {
        email,
        password
      }, { withCredentials: true });

      const authData = res.data;


      if (authData.token && authData.role === 'ADMIN') {

        localStorage.removeItem('userAuthToken');
        localStorage.removeItem('userId');
        localStorage.removeItem('email');

        localStorage.setItem('adminAuthToken', authData.token);
        localStorage.setItem('adminUserId', String(authData.userId));
        localStorage.setItem('userName', authData.adSoyad);
        localStorage.setItem('role', 'ADMIN');

        navigate('/admin-panel');

      } else if (authData.token && authData.role === 'USER') {
        setError('Bu hesap yönetici yetkisine sahip değil. Lütfen kullanıcı girişini kullanın.');
      } else {
        setError('Giriş başarılı, ancak yetki bilgileri alınamadı.');
      }

    } catch (err) {
      const errorMessage = err.response?.data?.message || 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
      setError(errorMessage);
    }
  };

  return (
    <div className="admin-page-wrapper">
      <div className="admin-login-card">

        <div className="admin-header">
          <h3>YÖNETİM PANELİ</h3>
          <p>Lütfen yetkili bilgilerinizi giriniz</p>
        </div>

        <form onSubmit={handleLogin} className="admin-form">
          <div className="admin-input-group">
            <label>Kurumsal E-posta</label>
            <input
              type="email"
              placeholder="admin@sirket.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="admin-input-group">
            <label>Parola</label>
            <input
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {error && <div className="admin-error-msg">{error}</div>}

          <button type="submit" className="btn-admin-login">
            Panele Giriş Yap
          </button>
        </form>

        <div className="admin-footer">
          <button onClick={() => navigate('/login')} className="btn-back-user">
            ← Kullanıcı Girişine Dön
          </button>
        </div>

      </div>
    </div>
  );
}

export default AdminLoginPage;