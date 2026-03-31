import 'package:flutter/material.dart';
import '../kitap_list/kitap_list_page.dart';
import '../rezervasyon/masa_rezervasyon_page.dart';
import '../login/login_page.dart';

class DashboardView extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<dynamic> aktifRezervasyonlar;
  final List<dynamic> aktifOduncler;
  final bool cezali;
  final String? cezaBitisTarihi;
  final bool isLoading;

  final Future<void> Function() onRefresh;
  final Future<void> Function(dynamic) onRezervasyonIptal;
  final Future<void> Function(int) onDavetOnayla;
  final Future<void> Function(int) onDavetReddet;
  final VoidCallback onCheckIn;
  final Function(int) onKitapIptal;
  final VoidCallback onProfileClick;

  const DashboardView({
    super.key,
    required this.user,
    required this.aktifRezervasyonlar,
    required this.aktifOduncler,
    required this.cezali,
    required this.cezaBitisTarihi,
    required this.isLoading,
    required this.onRefresh,
    required this.onRezervasyonIptal,
    required this.onDavetOnayla,
    required this.onDavetReddet,
    required this.onCheckIn,
    required this.onKitapIptal,
    required this.onProfileClick,
  });

  static const Map<String, String> seansMap = {
    'SEANS9': '09:00 - 11:00',
    'SEANS11': '11:00 - 13:00',
    'SEANS13': '13:00 - 15:00',
    'SEANS15': '15:00 - 17:00',
    'SEANS17': '17:00 - 19:00',
  };

  String _formatSeans(String? rawSeans) {
    if (rawSeans == null) return '';
    return seansMap[rawSeans] ?? rawSeans;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [const Color(0xFF667eea), const Color(0xFF764ba2)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: const Color(0xFF764ba2),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 25),

                  if (cezali) _buildCezaBanner(),
                  if (cezali) const SizedBox(height: 20),

                  const Text(
                    "Hızlı İşlemler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          title: "Kitap\nÖdünç Al",
                          icon: Icons.menu_book_rounded,
                          color1: const Color(0xFF4facfe),
                          color2: const Color(0xFF00f2fe),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KitapListPage(user: user),
                            ),
                          ),
                          isDisabled: cezali,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          title: "Masa\nRezerve Et",
                          icon: Icons.table_restaurant_rounded,
                          color1: const Color(0xFFfa709a),
                          color2: const Color(0xFFfee140),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MasaRezervasyonPage(user: user),
                            ),
                          ),
                          isDisabled: cezali,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Aktif İşlemlerim",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildActivityList(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (aktifRezervasyonlar.isEmpty && aktifOduncler.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: const [
            Icon(Icons.history_edu, color: Colors.white54, size: 50),
            SizedBox(height: 10),
            Text(
              "Henüz aktif bir işleminiz yok.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...aktifRezervasyonlar.map((r) {
          final bool isInvite = r["isInvite"] ?? false;
          final bool isCheckedIn = r["checkIn"] ?? false;

          return _buildInfoCard(
            type: "Masa Rezervasyonu",
            title: r["calismaOdasi"]["odaAdi"] ?? "Oda",
            dateInfo: r["tarih"] ?? "",
            timeInfo: _formatSeans(r["seans"]),
            icon: isInvite
                ? Icons.mail_outline_rounded
                : Icons.chair_alt_rounded,
            iconColor: Colors.orangeAccent,
            isInvite: isInvite,
            isCheckedIn: isCheckedIn,
            isPending: false,
            isExpired: false,
            isWarning: false,
            kalanGun: 0,
            onCheckIn: (!isInvite && !isCheckedIn) ? onCheckIn : null,
            onDelete: isInvite
                ? null
                : () => onRezervasyonIptal(r["rezervasyonId"]),
            itemId: r["rezervasyonId"],
          );
        }),

        ...aktifOduncler.map((o) {
          final bool isPending = o["isPending"] ?? false;

          return _buildInfoCard(
            type: "Kitap Ödünç",
            title: o["kitap"]["kitapAdi"] ?? "Kitap",
            dateInfo: "Son Teslim: ${o["bitisTarihi"]}",
            timeInfo: "",
            icon: Icons.menu_book_rounded,
            iconColor: Colors.blueAccent,
            isPending: isPending,
            isExpired: o["isExpired"] ?? false,
            isWarning: o["isWarning"] ?? false,
            kalanGun: o["kalanGun"] ?? 0,
            isInvite: false,
            isCheckedIn: false,
            onCheckIn: null,
            onDelete: isPending ? () => onKitapIptal(o["oduncId"]) : null,
          );
        }),
      ],
    );
  }

  // Rezervasyon ve ödünç bilgilerini; gecikme, onay veya davet durumlarına göre dinamik olarak görselleştiren merkezi kart bileşeni.
  Widget _buildInfoCard({
    required String type,
    required String title,
    required String dateInfo,
    required String timeInfo,
    required IconData icon,
    required Color iconColor,
    required bool isInvite,
    required bool isCheckedIn,
    required bool isPending,
    required bool isExpired,
    required bool isWarning,
    required int kalanGun,
    VoidCallback? onDelete,
    VoidCallback? onCheckIn,
    int? itemId,
  }) {
    Color cardColor = Colors.white;
    Color accentColor = iconColor;
    String statusLabel = "";

    // İş Kuralları: İşlemin statüsüne göre görsel tema ve etiket yapılandırmasını belirler.
    if (isExpired) {
      cardColor = const Color(0xFFFEF2F2);
      accentColor = Colors.red;
      statusLabel = "Süre Doldu! ⚠️";
    } else if (isWarning) {
      cardColor = const Color(0xFFFFFBEB);
      accentColor = Colors.orange;
      statusLabel = "Son $kalanGun Gün ⏳";
    } else if (isPending) {
      cardColor = const Color(0xFFF0F9FF);
      accentColor = Colors.cyan.shade700;
      statusLabel = "Onay Bekliyor ⏳";
    } else if (isInvite) {
      cardColor = const Color(0xFFF3E8FF);
      accentColor = Colors.deepPurple;
      statusLabel = "Davet 📩";
    } else if (isCheckedIn) {
      statusLabel = "Giriş Yapıldı ✅";
      accentColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: (isExpired || isWarning || isPending || isInvite)
            ? Border.all(color: accentColor.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (statusLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (!isInvite &&
                            !isPending &&
                            !isExpired &&
                            !isWarning)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Aktif",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          dateInfo,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        if (timeInfo.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeInfo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (onCheckIn != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.purple,
                    ),
                    onPressed: onCheckIn,
                    tooltip: "Giriş Yap (QR)",
                  ),
                ),

              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                  tooltip: "İptal Et",
                ),
            ],
          ),

          if (isInvite && itemId != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => onDavetReddet(itemId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Reddet"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => onDavetOnayla(itemId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Kabul Et"),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Kullanıcı karşılama bilgilerini ve oturum yönetim aksiyonlarını içeren başlık bileşeni.
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Merhaba, 👋",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              user['adSoyad'] ?? 'Kullanıcı',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white),
                tooltip: "Profilim",
                onPressed: onProfileClick,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCezaBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hesabınız Kısıtlandı!",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ceza bitiş tarihi: $cezaBitisTarihi",
                  style: TextStyle(color: Colors.red[800], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2],
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDisabled
                    ? Colors.transparent
                    : color1.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
