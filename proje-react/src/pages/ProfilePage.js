import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './ProfilePage.css';

function ProfilePage() {
    const navigate = useNavigate();
    const [adSoyad, setAdSoyad] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState({ type: '', text: '' });

    const API_URL = 'http://localhost:8080/api';
    const userId = localStorage.getItem('userId');
    const token = localStorage.getItem('userAuthToken');

    const authAxios = axios.create({ baseURL: API_URL });
    authAxios.interceptors.request.use(config => {
        if (token) config.headers.Authorization = `Bearer ${token}`;
        return config;
    });

    useEffect(() => {
        const fetchUser = async () => {
            try {
                const response = await authAxios.get(`/kullanicilar/${userId}`);
                setAdSoyad(response.data.adSoyad);
            } catch (error) {
            }
        };
        fetchUser();
    }, [userId]);

    const handleUpdate = async (e) => {
        e.preventDefault();
        setMessage({ type: '', text: '' });

        if (password && password.length < 6) {
            setMessage({ type: 'error', text: 'Yeni şifre en az 6 karakter olmalıdır.' });
            return;
        }
        if (password !== confirmPassword) {
            setMessage({ type: 'error', text: 'Şifreler uyuşmuyor!' });
            return;
        }

        setLoading(true);

        const updateRequest = {
            adSoyad: adSoyad,
            password: password || null
        };

        try {
            await authAxios.put(`/kullanicilar/profile/${userId}`, updateRequest);

            localStorage.setItem('userName', adSoyad);

            setMessage({ type: 'success', text: 'Profil başarıyla güncellendi!' });
            setPassword('');
            setConfirmPassword('');

        } catch (error) {
            setMessage({ type: 'error', text: 'Güncelleme sırasında bir hata oluştu.' });
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="profile-wrapper">
            <div className="profile-container">
                <div className="profile-header">
                    <button className="btn-back" onClick={() => navigate('/dashboard')}>
                        ← Geri Dön
                    </button>
                    <h2>Profil Düzenle</h2>
                </div>

                {message.text && (
                    <div className={`alert-message ${message.type}`}>
                        {message.text}
                    </div>
                )}

                <form onSubmit={handleUpdate} className="profile-form">
                    <div className="form-group">
                        <label>Ad Soyad</label>
                        <input
                            type="text"
                            value={adSoyad}
                            onChange={(e) => setAdSoyad(e.target.value)}
                            required
                        />
                    </div>

                    <div className="form-divider">
                        <span>Şifre Değiştir (İsteğe Bağlı)</span>
                    </div>

                    <div className="form-group">
                        <label>Yeni Şifre</label>
                        <input
                            type="password"
                            placeholder="Değiştirmek istemiyorsanız boş bırakın"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                        />
                    </div>

                    <div className="form-group">
                        <label>Yeni Şifre (Tekrar)</label>
                        <input
                            type="password"
                            placeholder="Şifreyi onaylayın"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                        />
                    </div>

                    <button type="submit" className="btn-save" disabled={loading}>
                        {loading ? 'Güncelleniyor...' : 'Değişiklikleri Kaydet'}
                    </button>
                </form>
            </div>
        </div>
    );
}

export default ProfilePage;