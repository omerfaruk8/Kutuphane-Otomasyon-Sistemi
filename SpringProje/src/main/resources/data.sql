    INSERT INTO admin (ad_soyad, e_posta, password) VALUES
    ('admin1', 'admin1@admin.com', '{sha256}a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3'),
    ('admin2', 'admin2@admin.com', '$2a$10$DYIA9d/zAK/2Q1W6vDCCp.rv8FdZ5Xwrwncy8ai9ZU/K1LV6v5Tqm');
    /*iki adminin şifresi de 123. */

    INSERT INTO kitaplar (kategori, kitap_adi, musait_adet, stok_sayisi, yazar) VALUES
    ('Roman', 'Suç ve Ceza', 13, 13, 'Fyodor Dostoyevski'),
    ('Roman', 'Sefiller', 14, 14, 'Victor Hugo'),
    ('Roman', 'Monte Kristo Kontu', 10, 10, 'Alexandre Dumas'),
    ('Roman', 'Don Kişot', 12, 12, 'Miguel de Cervantes'),
    ('Macera', 'Robinson Crusoe', 7, 7, 'Daniel Defoe'),
    ('Roman', 'Karamazov Kardeşler', 9, 9, 'Fyodor Dostoyevski'),
    ('Distopya', '1984', 15, 15, 'George Orwell'),
    ('Alegori', 'Hayvan Çiftliği', 11, 11, 'George Orwell'),
    ('Macera', 'Beyaz Diş', 5, 5, 'Jack London'),
    ('Roman', 'Aşk ve Gurur', 6, 6, 'Jane Austen'),
    ('Hikaye', 'İnsan Neyle Yaşar?', 20, 20, 'Lev Tolstoy'),
    ('Psikoloji', 'Bilinçaltının Gücü', 7, 7, 'Joseph Murphy'),
    ('Roman', 'Yabancı', 12, 12, 'Albert Camus'),
    ('Roman', 'Beyaz Gemi', 8, 8, 'Cengiz Aytmatov'),
    ('d', 'deneme', 0, 1, 'ddd'),
    ('Macera', 'Attack on Titan', 15, 15, 'Hajime Isayama');

    INSERT INTO calisma_odalari (oda_adi, oda_tipi, sandalye_sayisi) VALUES
    ('A01', 'Sesli', 30),
    ('B01', 'Sessiz', 30),
    ('A02', 'Sesli', 30)