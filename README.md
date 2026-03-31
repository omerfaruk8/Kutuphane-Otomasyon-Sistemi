Kurulum ve Çalıştırma Rehberi
Projeyi kendi bilgisayarınızda ayağa kaldırmak için aşağıdaki adımları sırasıyla uygulamanız gerekmektedir.

1. Veritabanı Ayarları
Projeyi çalıştırmadan önce kendi SQL sunucunuzda boş bir veritabanı oluşturun. Ardından backend projesi içindeki src/main/resources/application.properties dosyasını açıp veritabanı bağlantı bilgilerinizi kendinize göre düzenleyin:

spring.datasource.url=.../yourdbname (Oluşturduğunuz boş veritabanının adını yazın)

spring.datasource.username=yourusername (SQL kullanıcı adınız)

spring.datasource.password=yourpassword (SQL şifreniz)

2. Backend (Spring Boot) Kurulumu
Veritabanı bilgilerinizi girdikten sonra backend projesini IDE üzerinden çalıştırın.

Örnek Veriler: Projeyi ilk çalıştırdığınızda tabloların ve örnek verilerin (kitaplar, odalar, admin hesapları) otomatik olarak eklenmesi için application.properties dosyasında spring.sql.init.mode=always ayarı açık bırakılmıştır.

Önemli: Projeyi bir kez çalıştırıp veritabanının dolduğunu gördükten sonra, sonraki çalıştırmalarda aynı verilerin tekrar eklenip hata vermemesi için bu ayarı spring.sql.init.mode=never olarak değiştirmeyi unutmayın.

3. Web (React) Kurulumu
Terminali veya komut satırını açıp React projesinin bulunduğu klasöre gidin:

Gerekli paketleri indirmek için npm install komutunu çalıştırın.

Web arayüzünü başlatmak için npm start komutunu çalıştırın.

4. Mobil Uygulama Kurulumu
Seçenek A: Hazır APK ile Hızlı Kurulum (Tavsiye Edilen)
Kodlarla veya kurulumlarla uğraşmadan kütüphane uygulamasını doğrudan telefonunuzda denemek için:

Proje dizininde (kutuphane_flutter\build\app\outputs\flutter-apk) yer alan app-release.apk dosyasını Android telefonunuza indirin ve kurun.

Bilgisayarınızın (backend'i çalıştıran cihazın) ve telefonunuzun aynı Wi-Fi ağına bağlı olduğundan emin olun.

Uygulamayı açtığınızda sunucu ayarları (IP) kısmına (sağ üstteki ayarlar ikonu) bilgisayarınızın yerel IP adresini (örn: 192.168.1.X) girerek kendi sunucunuza saniyeler içinde bağlanın.

Seçenek B: Flutter Geliştirici Ortamı ile Kurulum
Projeyi kaynak kodundan derlemek isterseniz:

Terminali mobil projenin bulunduğu klasörde açın.

flutter pub get komutu ile bağımlılıkları yükleyin.

Cihazınızı bağlayıp flutter run komutu ile projeyi başlatın.
5. Sisteme Giriş (Admin Bilgileri)
Proje ilk çalıştığında data.sql dosyası üzerinden sisteme 2 adet yönetici (admin) hesabı otomatik olarak tanımlanır. Yönetim paneline giriş yapmak için bu bilgileri kullanabilirsiniz:

Admin 1: admin1@admin.com

Admin 2: admin2@admin.com

Şifre: 123 (İki hesabın şifresi de 123'tür. Veritabanında güvenlik amacıyla hash'lenmiş olarak tutulmaktadır.)