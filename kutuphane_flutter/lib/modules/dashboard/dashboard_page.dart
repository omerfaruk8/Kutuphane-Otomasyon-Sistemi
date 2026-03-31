import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kutuphane_flutter/core/api_client.dart';
import 'package:kutuphane_flutter/modules/login/login_page.dart';
import 'package:kutuphane_flutter/modules/profile/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_view.dart';
import 'qr_scanner_page.dart';

// Kullanıcı ana ekranı; aktif rezervasyonlar, ödünç alınan kitaplar ve ceza durumunun merkezi olarak yönetildiği denetleyici (Controller) sınıfıdır.
class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Map<String, dynamic> currentUser;

  List<dynamic> aktifRezervasyonlar = [];
  List<dynamic> aktifOduncler = [];

  bool cezali = false;
  String? cezaBitisTarihi;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = Map.from(widget.user);
    _initData();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    await _loadAktifIslemler();
    await _cezaDurumunuKontrolEt();
    setState(() => isLoading = false);
  }

  void _navigateToProfile() async {
    final updatedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(user: currentUser)),
    );

    if (updatedName != null &&
        updatedName is String &&
        updatedName.isNotEmpty) {
      setState(() {
        currentUser['adSoyad'] = updatedName;
      });
    }
  }

  Future<void> _loadAktifIslemler() async {
    final dynamic kullaniciIdRaw =
        currentUser['kullaniciId'] ??
        currentUser['kullaniciid'] ??
        currentUser['id'];

    if (kullaniciIdRaw == null) {
      if (mounted) _navigateToLogin();
      return;
    }
    final kullaniciId = kullaniciIdRaw.toString();

    try {
      final responses = await Future.wait([
        apiClient.get('/reservations/user/$kullaniciId'),
        apiClient.get('/borrows/user/$kullaniciId'),
      ]);

      List<dynamic> rawRezervasyonlar = _parseResponseList(responses[0].data);
      List<dynamic> islenmisRezervasyonlar = rawRezervasyonlar.map((r) {
        final item = Map<String, dynamic>.from(r);
        // Durum kontrolü: ONAY_BEKLIYOR ise davettir
        item['isInvite'] = item['durum'] == 'ONAY_BEKLIYOR';
        item['checkIn'] = item['checkIn'] ?? false;
        return item;
      }).toList();

      List<dynamic> rawOduncler = _parseResponseList(responses[1].data);
      List<dynamic> islenmisOduncler = rawOduncler
          .where((o) {
            final d = o['durum']?.toString().toUpperCase();
            return d == 'KULLANICIDA' || d == 'BEKLEMEDE';
          })
          .map((o) {
            final item = Map<String, dynamic>.from(o);
            final bitisStr = item['bitisTarihi'];
            final durum = item['durum']?.toString().toUpperCase() ?? "";

            bool isPending = durum == 'BEKLEMEDE';
            bool isExpired = false;
            bool isWarning = false;
            int kalanGun = 0;

            if (durum == 'KULLANICIDA' && bitisStr != null) {
              final bitis = DateTime.parse(bitisStr);
              final simdi = DateTime.now();
              final bugun = DateTime(simdi.year, simdi.month, simdi.day);

              kalanGun = bitis.difference(bugun).inDays;

              if (bitis.isBefore(bugun)) {
                isExpired = true;
              } else if (kalanGun <= 2) {
                isWarning = true;
              }
            }

            item['isPending'] = isPending;
            item['isExpired'] = isExpired;
            item['isWarning'] = isWarning;
            item['kalanGun'] = kalanGun;

            return item;
          })
          .toList();
      setState(() {
        aktifRezervasyonlar = islenmisRezervasyonlar;
        aktifOduncler = islenmisOduncler;
      });
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        if (mounted) _navigateToLogin();
      }
    } catch (e) {}
  }

  List<dynamic> _parseResponseList(dynamic data) {
    if (data is List) return List.from(data);
    if (data is Map) {
      if (data['data'] is List) return List.from(data['data']);
      if (data['content'] is List) return List.from(data['content']);
      return [data];
    }
    return [];
  }

  Future<void> _cezaDurumunuKontrolEt() async {
    final kullaniciId = currentUser['kullaniciId'] ?? currentUser['id'];
    if (kullaniciId == null) return;

    try {
      final response = await apiClient.get('/ceza/durum/$kullaniciId');
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          cezali = data['cezali'] ?? false;
          cezaBitisTarihi = data['cezaBitisTarihi']?.toString();
        });
      }
    } catch (_) {}
  }

  Future<void> onRefresh() async {
    await _initData();
  }

  void _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAuthToken');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _masaIptalEt(dynamic rezervasyonId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masa İptali'),
        content: const Text(
          'Bu masa rezervasyonunu iptal etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'İptal Et',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await apiClient.delete('/reservations/delete/$rezervasyonId');
        await _loadAktifIslemler();
        if (mounted) _showSuccessSnackbar('Masa rezervasyonu iptal edildi');
      } catch (e) {
        if (mounted) _showErrorSnackbar("İptal başarısız oldu.");
      }
    }
  }

  Future<void> _davetOnayla(int rezervasyonId) async {
    try {
      await apiClient.put('/reservations/approve/$rezervasyonId', {});
      await _loadAktifIslemler();
      if (mounted) _showSuccessSnackbar('Davet kabul edildi! 🎉');
    } catch (e) {
      if (mounted) _showErrorSnackbar("İşlem başarısız.");
    }
  }

  Future<void> _davetReddet(int rezervasyonId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daveti Reddet'),
        content: const Text('Bu daveti reddetmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Reddet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await apiClient.put('/reservations/reject/$rezervasyonId', {});
        await _loadAktifIslemler();
        if (mounted) _showSuccessSnackbar('Davet reddedildi.');
      } catch (e) {
        if (mounted) _showErrorSnackbar("İşlem başarısız.");
      }
    }
  }

  //  QR kod tarama sürecini yönetir ve fiziksel masa katılımını backend üzerinden onaylar.
  Future<void> _handleQRCheckIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result == true) {
      final userId = currentUser['kullaniciId'] ?? currentUser['id'];
      try {
        await apiClient.post("/reservations/check-in/$userId");
        if (mounted) {
          _showSuccessSnackbar("Hoşgeldiniz! Girişiniz onaylandı. 📚");
          _loadAktifIslemler();
        }
      } on DioException catch (e) {
        String msg = "Giriş başarısız.";
        if (e.response?.data != null) msg = e.response!.data.toString();
        if (mounted) _showErrorSnackbar(msg);
      }
    }
  }

  Future<void> _kitapIptalEt(int id) async {
    final bool? onayla = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kitap İsteği İptali'),
        content: const Text(
          'Bu ödünç alma isteğini iptal etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (onayla != true) return;

    try {
      await apiClient.put('/borrows/cancel/$id', {});
      await _loadAktifIslemler();
      if (mounted) _showSuccessSnackbar('Kitap isteği iptal edildi');
    } on DioException catch (e) {
      String err = "İptal edilemedi.";
      if (e.response != null && e.response!.data != null) {
        err = e.response!.data.toString();
      }
      if (mounted) _showErrorSnackbar(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardView(
      user: currentUser,
      aktifRezervasyonlar: aktifRezervasyonlar,
      aktifOduncler: aktifOduncler,
      cezali: cezali,
      cezaBitisTarihi: cezaBitisTarihi,
      isLoading: isLoading,
      onRefresh: onRefresh,
      onRezervasyonIptal: _masaIptalEt,
      onDavetOnayla: _davetOnayla,
      onDavetReddet: _davetReddet,
      onCheckIn: _handleQRCheckIn,
      onKitapIptal: _kitapIptalEt,
      onProfileClick: _navigateToProfile,
    );
  }
}
