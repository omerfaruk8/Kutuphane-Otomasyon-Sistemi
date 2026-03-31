import 'package:flutter/material.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kutuphane_flutter/modules/login/login_page.dart';
import 'admin_panel_view.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  AdminPanelPageState createState() => AdminPanelPageState();
}

class AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // STATE DEĞİŞKENLERİ
  bool isLoading = false;

  List<dynamic> kitapTalepleri = [];
  List<dynamic> aktifKitaplar = [];
  List<dynamic> masaRezervasyonlari = [];
  List<dynamic> tumKitaplar = [];

  TextEditingController cezaIdController = TextEditingController();
  Map<String, dynamic>? cezaSonuc;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    verileriGetir();
  }

  @override
  void dispose() {
    tabController.dispose();
    cezaIdController.dispose();
    super.dispose();
  }

  // API İŞLEMLERİ

  Future<void> verileriGetir() async {
    if (tumKitaplar.isEmpty) setState(() => isLoading = true);

    try {
      final responses = await Future.wait([
        apiClient.get('/borrows/pending'),
        apiClient.get('/borrows/active-borrows'),
        apiClient.get('/reservations/active'),
        apiClient.get('/kitaplar'),
      ]);

      if (mounted) {
        setState(() {
          kitapTalepleri = responses[0].data;
          aktifKitaplar = responses[1].data;
          masaRezervasyonlari = responses[2].data;
          tumKitaplar = responses[3].data;
          isLoading = false;
        });
      }
    } catch (e) {
      // Hata durumunda yükleme durumunu kapatır
      if (mounted) {
        setState(() => isLoading = false);
        // Kullanıcıya arayüz üzerinden bilgi vermek istersen mesajGoster'i kullanabilirsin
        mesajGoster("Veriler güncellenirken bir hata oluştu.", isError: true);
      }
    }
  }

  // Mevcut oturumu sonlandırır ve yerel depolamadaki kimlik bilgilerini temizler
  Future<void> cikisYap() async {
    final bool? eminMi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Oturumu kapatmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hayır"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Evet", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (eminMi == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> kitapKaydet(
    Map<String, dynamic> kitapData,
    bool isEditing,
  ) async {
    try {
      final url = isEditing ? '/kitaplar/update' : '/kitaplar/add';
      await apiClient.post(url, data: kitapData);
      verileriGetir();
      mesajGoster(isEditing ? "Kitap güncellendi!" : "Kitap eklendi!");
    } catch (e) {
      mesajGoster("Hata oluştu: $e", isError: true);
    }
  }

  Future<void> kitapSil(int id) async {
    try {
      await apiClient.delete('/kitaplar/delete/$id');
      verileriGetir();
      mesajGoster("Kitap silindi.");
    } catch (e) {
      mesajGoster("Silinemedi. Kitap kullanımda olabilir.", isError: true);
    }
  }

  Future<void> islemYap(String url, String basariMesaji) async {
    try {
      await apiClient.post(url);
      verileriGetir();
      mesajGoster(basariMesaji);
    } catch (e) {
      mesajGoster("İşlem başarısız.", isError: true);
    }
  }

  Future<void> kitapIadeAl(int oduncId) async {
    try {
      await apiClient.post('/borrows/return/$oduncId');
      verileriGetir();
      mesajGoster("Kitap başarıyla iade alındı.");
    } catch (e) {
      mesajGoster("İade işlemi başarısız.", isError: true);
    }
  }

  Future<void> masaIptal(int id) async {
    try {
      await apiClient.delete('/reservations/delete/$id');
      verileriGetir();
      mesajGoster("Rezervasyon iptal edildi.");
    } catch (e) {
      mesajGoster("İptal edilemedi.", isError: true);
    }
  }

  Future<void> cezaSorgula() async {
    if (cezaIdController.text.isEmpty) return;
    try {
      final res = await apiClient.get('/ceza/durum/${cezaIdController.text}');
      setState(() {
        cezaSonuc = res.data;
        cezaSonuc!['kullaniciId'] = int.parse(cezaIdController.text);
      });
    } catch (e) {
      mesajGoster("Kullanıcı bulunamadı.", isError: true);
      setState(() => cezaSonuc = null);
    }
  }

  Future<void> cezaKaldir() async {
    if (cezaSonuc == null) return;
    try {
      await apiClient.post('/ceza/kaldir/${cezaSonuc!['kullaniciId']}');
      mesajGoster("Ceza kaldırıldı!");
      cezaSorgula();
    } catch (e) {
      mesajGoster("Hata: $e", isError: true);
    }
  }

  void mesajGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPanelView(state: this);
  }
}
