import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './LoginPage.css';

function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const response = await axios.post('http://localhost:8080/api/login', {
        email,
        password
      }, { withCredentials: true });


      const data = response.data;
      const token = data.token;
      const role = data.role || 'USER';
      const userId = data.userId;
      const userName = data.adSoyad;

      if (token && userId) {

        if (role === 'ADMIN') {
          localStorage.removeItem('userAuthToken');
          localStorage.setItem('adminAuthToken', token);
          localStorage.setItem('adminUserId', String(userId));
          localStorage.setItem('userName', userName);
          localStorage.setItem('role', 'ADMIN');

          navigate('/admin-panel');
        } else {
          localStorage.removeItem('adminAuthToken');

          localStorage.setItem('userAuthToken', token);
          localStorage.setItem('userId', String(userId));
          localStorage.setItem('userName', userName);
          localStorage.setItem('email', email);
          localStorage.setItem('role', 'USER');

          navigate('/dashboard');
        }

      } else {
        setError("Giriş başarılı ancak eksik bilgi döndü.");
      }

    } catch (err) {
      setError(err.response?.data?.message || 'Giriş yapılamadı. Bilgilerinizi kontrol edin.');
    }
  };

  return (
    <div className="login-page-wrapper">
      <div className="login-container">
        <h2>Tekrar Hoş Geldiniz</h2>
        <p className="sub-text">Devam etmek için giriş yapın.</p>

        <form onSubmit={handleLogin} className="login-form">

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

          {error && <div className="alert error">{error}</div>}

          <button type="submit" className="btn-primary">Giriş Yap</button>
        </form>

        <div className="auth-actions">
          <p>
            Hesabın yok mu?
            <span onClick={() => navigate('/register')} className="link-text"> Hemen Kayıt Ol</span>
          </p>
        </div>

        <div style={{ marginTop: '20px', textAlign: 'center', borderTop: '1px solid #eee', paddingTop: '15px' }}>
          <button
            onClick={() => navigate('/admin-login')}
            style={{
              background: 'none',
              border: 'none',
              color: '#666',
              fontSize: '0.9rem',
              cursor: 'pointer',
              textDecoration: 'underline'
            }}
          >
            Yönetici Girişi
          </button>
        </div>

      </div>
    </div>
  );
}

export default LoginPage;