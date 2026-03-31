import 'package:flutter/material.dart';
import 'admin_panel_page.dart';

class AdminPanelView extends StatelessWidget {
  final AdminPanelPageState state;

  const AdminPanelView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetim Paneli"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: state.cikisYap,
            tooltip: "Çıkış Yap",
          ),
        ],
        bottom: TabBar(
          controller: state.tabController,
          indicatorColor: Colors.amber,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Kitaplar"),
            Tab(icon: Icon(Icons.notifications_active), text: "Talepler"),
            Tab(icon: Icon(Icons.menu_book), text: "Kullanıcıdaki Kitaplar"),
            Tab(icon: Icon(Icons.table_restaurant), text: "Masa Rez."),
            Tab(icon: Icon(Icons.gavel), text: "Ceza"),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFF1b1b2f),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: state.tabController,
                children: [
                  _buildKitapTab(context),
                  _buildTalepTab(context),
                  _buildAktifOduncTab(context),
                  _buildMasaTab(context),
                  _buildCezaTab(context),
                ],
              ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: state.tabController,
        builder: (context, child) {
          return state.tabController.index == 0
              ? FloatingActionButton(
                  backgroundColor: Colors.amber,
                  onPressed: () => _kitapDialogGoster(context),
                  child: const Icon(Icons.add, color: Colors.black),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  // Kütüphane envanterinin yönetildiği arayüz bileşeni.
  Widget _buildKitapTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.verileriGetir,
      color: Colors.amber,
      backgroundColor: const Color(0xFF2e2e42),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 100,
        ),
        itemCount: state.tumKitaplar.length,
        itemBuilder: (context, index) {
          final k = state.tumKitaplar[index];
          return Card(
            color: const Color(0xFF2e2e42),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(
                k['kitapAdi'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${k['yazar']} \nStok: ${k['stokSayisi']} | Müsait: ${k['musaitAdet']}",
                style: const TextStyle(color: Colors.white70),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _kitapDialogGoster(context, kitap: k),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _dialogSilOnay(
                      context,
                      () => state.kitapSil(k['kitapId']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Kullanıcılardan gelen ödünç alma taleplerinin onay/red süreçlerini yönetir.
  Widget _buildTalepTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.verileriGetir,
      child: state.kitapTalepleri.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    "Bekleyen talep yok ✅",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: state.kitapTalepleri.length,
              itemBuilder: (context, index) {
                final t = state.kitapTalepleri[index];
                return Card(
                  color: const Color(0xFF2e2e42),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      t['kitap']['kitapAdi'],
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "İsteyen: ${t['kullanici']['adSoyad']}\nBaşlangıç: ${t['baslangicTarihi']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          tooltip: "Onayla",
                          onPressed: () => state.islemYap(
                            '/borrows/approve/${t['oduncId']}',
                            "Kitap Teslim Edildi",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: "Reddet",
                          onPressed: () => state.islemYap(
                            '/borrows/reject/${t['oduncId']}',
                            "Talep Reddedildi",
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Mevcut ödünç verilmiş kitapların takibi ve iade süreçlerini içerir.
  Widget _buildAktifOduncTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.verileriGetir,
      child: state.aktifKitaplar.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    "Kullanıcıda kitap yok ✅",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: state.aktifKitaplar.length,
              itemBuilder: (context, index) {
                final k = state.aktifKitaplar[index];
                return Card(
                  color: const Color(0xFF2e2e42),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      k['kitap']['kitapAdi'],
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Kullanıcı: ${k['kullanici']['adSoyad']}\nBitiş Tarihi: ${k['bitisTarihi']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_return, size: 16),
                      label: const Text("İade Al"),
                      onPressed: () => _dialogSilOnay(
                        context,
                        () => state.kitapIadeAl(k['oduncId']),
                        baslik: "Kitap İade",
                        icerik: "Kitabı teslim alma işlemi onaylansın mı?",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Çalışma odası ve masa rezervasyonlarının anlık durum takibi ve yönetimini sağlar.
  Widget _buildMasaTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.verileriGetir,
      child: state.masaRezervasyonlari.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    "Aktif rezervasyon yok",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: state.masaRezervasyonlari.length,
              itemBuilder: (context, index) {
                final r = state.masaRezervasyonlari[index];
                return Card(
                  color: const Color(0xFF2e2e42),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_seat,
                      color: Colors.amber,
                      size: 30,
                    ),
                    title: Text(
                      "${r['calismaOdasi']['odaAdi']} - Masa ${r['sandalyeNo']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${r['kullanici']['adSoyad']}\n${r['seans']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: "İptal Et",
                      onPressed: () => _dialogSilOnay(
                        context,
                        () => state.masaIptal(r['rezervasyonId']),
                        baslik: "Rezervasyon İptali",
                        icerik: "Bu rezervasyonu iptal etmek istiyor musunuz?",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Kullanıcı kısıtlama durumlarının sorgulandığı ve yönetildiği modüldür.
  Widget _buildCezaTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: state.cezaIdController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => state.cezaSorgula(),
            decoration: InputDecoration(
              labelText: "Kullanıcı ID Girin",
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.amber),
                onPressed: state.cezaSorgula,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          if (state.cezaSonuc != null)
            Card(
              color: state.cezaSonuc!['cezali']
                  ? Colors.red.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      state.cezaSonuc!['adSoyad'] ?? 'İsimsiz',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      state.cezaSonuc!['email'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 30),

                    Icon(
                      state.cezaSonuc!['cezali']
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 60,
                      color: state.cezaSonuc!['cezali']
                          ? Colors.red
                          : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.cezaSonuc!['cezali'] ? "CEZALI" : "TEMİZ",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    if (state.cezaSonuc!['cezali']) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Bitiş: ${state.cezaSonuc!['cezaBitisTarihi']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: const Text("Cezayı Kaldır"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _dialogSilOnay(
                            context,
                            state.cezaKaldir,
                            baslik: "Ceza Kaldırma",
                            icerik:
                                "Bu kullanıcının cezasını kaldırmak istediğinize emin misiniz?",
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Arayüz içerisinde kullanılan dinamik diyaloglar ve yardımcı widget yapıları.
  void _kitapDialogGoster(BuildContext context, {Map<String, dynamic>? kitap}) {
    final isEditing = kitap != null;
    final adCtrl = TextEditingController(text: kitap?['kitapAdi']);
    final yazarCtrl = TextEditingController(text: kitap?['yazar']);
    final katCtrl = TextEditingController(text: kitap?['kategori']);
    final stokCtrl = TextEditingController(
      text: kitap?['stokSayisi']?.toString() ?? '1',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Kitabı Düzenle" : "Yeni Kitap Ekle"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adCtrl,
                decoration: const InputDecoration(labelText: "Kitap Adı"),
              ),
              TextField(
                controller: yazarCtrl,
                decoration: const InputDecoration(labelText: "Yazar"),
              ),
              TextField(
                controller: katCtrl,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              TextField(
                controller: stokCtrl,
                decoration: const InputDecoration(labelText: "Stok Sayısı"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final data = {
                if (isEditing) "kitapId": kitap['kitapId'],
                "kitapAdi": adCtrl.text,
                "yazar": yazarCtrl.text,
                "kategori": katCtrl.text,
                "stokSayisi": int.tryParse(stokCtrl.text) ?? 0,
                "musaitAdet": int.tryParse(stokCtrl.text) ?? 0,
              };
              state.kitapKaydet(data, isEditing);
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _dialogSilOnay(
    BuildContext context,
    VoidCallback onConfirm, {
    String baslik = "Silinsin mi?",
    String icerik = "Bu işlem geri alınamaz.",
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(baslik),
        content: Text(icerik),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text(
              "Onayla",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
