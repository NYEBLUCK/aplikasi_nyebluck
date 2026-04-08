import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/topping_controller.dart';
import '../controllers/kasir_controller.dart';
import 'login_page.dart';
import 'history_page.dart';

class KasirPage extends StatelessWidget {
  final ToppingController toppingCtrl = Get.put(ToppingController());
  final KasirController kasirCtrl = Get.put(KasirController());

  KasirPage({super.key});

  // --- FUNGSI LOGOUT ---
  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Logout",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Apakah Anda yakin ingin keluar?",
      radius: 15,
      textCancel: "Batal",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFB71C1C),
      onConfirm: () async {
        await kasirCtrl.logout();
        Get.offAll(() => LoginPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Obx(() => Text(
          kasirCtrl.tabIndex.value == 0 ? "NYEBLUCK" : "NYEBLUCK",
          style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFFDEAEA),
              child: Icon(Icons.person, color: Color(0xFFB71C1C), size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY BERGANTI SESUAI TAB ---
      body: Obx(() {
        if (kasirCtrl.tabIndex.value == 0) {
          return _buildKasirBody();
        } else {
          return _buildHistoryBody();
        }
      }),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: kasirCtrl.tabIndex.value,
        onTap: (index) => kasirCtrl.changeTab(index),
        selectedItemColor: const Color(0xFFB71C1C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Kasir"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
        ],
      )),
    );
  }

  // --- KONTEN HALAMAN KASIR ---
  Widget _buildKasirBody() {
    return Stack(
      children: [
        Column(
          children: [
            _buildSearchBar(),
            _buildCategoryList(),
            Expanded(
              child: Obx(() {
                if (toppingCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: toppingCtrl.filteredTopping.length,
                  itemBuilder: (context, index) {
                    final topping = toppingCtrl.filteredTopping[index];
                    return _buildProductItem(topping);
                  },
                );
              }),
            ),
          ],
        ),
        // Sticky Button (Keranjang)
        Obx(() => kasirCtrl.cart.isNotEmpty 
          ? Positioned(bottom: 20, left: 16, right: 16, child: _buildStickyButton())
          : const SizedBox.shrink()),
      ],
    );
  }

  // --- KONTEN HALAMAN RIWAYAT (Placeholder) ---
  Widget _buildHistoryBody() {
    return HistoryPage();
  }

  // --- WIDGET PENDUKUNG KASIR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (v) => toppingCtrl.filterData(v, toppingCtrl.selectedCategory.value),
        decoration: InputDecoration(
          hintText: "Cari topping...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ["Semua", "Kering", "Frozen", "Minuman"];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          return Obx(() {
            bool isSelected = toppingCtrl.selectedCategory.value == categories[i];
            return GestureDetector(
              onTap: () => toppingCtrl.filterData("", categories[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFB71C1C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(categories[i], style: TextStyle(color: isSelected ? Colors.white : Colors.black54)),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductItem(topping) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(topping.imageUrl ?? '', width: 70, height: 70, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], width: 70, height: 70, child: const Icon(Icons.fastfood))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topping.namaTopping, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(topping.stok > 0 ? "Stok: ${topping.stok}" : "Stok Habis", 
                    style: TextStyle(color: topping.stok > 0 ? Colors.grey : Colors.red, fontSize: 12)),
                Text("Rp ${topping.harga}", style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Obx(() {
            int qty = kasirCtrl.cart[topping.id] ?? 0;
            return qty == 0 
              ? ElevatedButton(
                  onPressed: topping.stok > 0 ? () => kasirCtrl.tambahKeKeranjang(topping.id) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
                  child: const Text("Tambah"),
                )
              : Row(
                  children: [
                    IconButton(onPressed: () => kasirCtrl.kurangiDariKeranjang(topping.id), icon: const Icon(Icons.remove_circle_outline)),
                    Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: topping.stok > 0 ? () => kasirCtrl.tambahKeKeranjang(topping.id) : null, 
                      icon: Icon(Icons.add_circle, color: topping.stok > 0 ? const Color(0xFFB71C1C) : Colors.grey)
                    ),
                  ],
                );
          }),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    return ElevatedButton(
      onPressed: () => _showCheckoutSheet(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB71C1C), padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text("${kasirCtrl.totalItems} Items", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Text("Lanjutkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET CHECKOUT ---
  void _showCheckoutSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const SizedBox(height: 20),
              TextField(onChanged: (v) => kasirCtrl.namaPembeli.value = v, decoration: const InputDecoration(labelText: "Nama Pembeli")),
              const SizedBox(height: 20),
              const Text("Level Pedas", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => Slider(
                value: kasirCtrl.levelPedas.value.toDouble(),
                min: 0, max: 3, divisions: 3,
                activeColor: const Color(0xFFB71C1C),
                label: kasirCtrl.levelPedas.value.toString(),
                onChanged: (v) => kasirCtrl.levelPedas.value = v.toInt(),
              )),
              const SizedBox(height: 10),
              const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Menggunakan lowercase untuk value agar aman di DB
              Row(children: [_buildMethodBtn("tunai"), const SizedBox(width: 10), _buildMethodBtn("qris")]),
              const Divider(height: 40),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Bayar:", style: TextStyle(fontSize: 16)),
                  Text("Rp ${kasirCtrl.totalBayar}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                ],
              )),
              const SizedBox(height: 20),
              Obx(() => ElevatedButton(
                onPressed: kasirCtrl.isLoading.value ? null : () => kasirCtrl.prosesPembayaran(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: kasirCtrl.isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("PROSES PEMBAYARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMethodBtn(String method) {
    return Expanded(
      child: Obx(() => OutlinedButton(
        onPressed: () => kasirCtrl.metodePembayaran.value = method,
        style: OutlinedButton.styleFrom(
          backgroundColor: kasirCtrl.metodePembayaran.value == method ? const Color(0xFFB71C1C) : Colors.white,
          side: BorderSide(color: const Color(0xFFB71C1C)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        child: Text(
          method.toUpperCase(), // Tampilan tetap UPPERCASE biar keren
          style: TextStyle(color: kasirCtrl.metodePembayaran.value == method ? Colors.white : const Color(0xFFB71C1C)),
        ),
      )),
    );
  }
}