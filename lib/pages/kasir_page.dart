import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/topping_controller.dart';
import '../controllers/kasir_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'pembayaran_page.dart';
import 'history_page.dart';

class KasirPage extends StatelessWidget {
  // Menggunakan satu inisialisasi saja agar tidak boros memori
  final ToppingController toppingC = Get.put(ToppingController());
  final KasirController kasirCtrl = Get.put(KasirController());
  final TextEditingController searchC = TextEditingController();

  KasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          "NYEBLUCK",
          style: GoogleFonts.poppins(
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.w900,
              letterSpacing: 1),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC62828),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFC62828),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
            selectedItemColor: const Color(0xFFC62828),
            unselectedItemColor: Colors.grey,
            currentIndex: kasirCtrl.tabIndex.value,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
            onTap: (index) => kasirCtrl.changeTab(index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long), label: "KASIR"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: "RIWAYAT"),
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
            // Area Search dan Filter
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                    child: TextField(
                      controller: searchC,
                      onChanged: (v) =>
                          toppingC.filterData(v, toppingC.selectedCategory.value),
                      decoration: InputDecoration(
                        hintText: "Cari topping...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFEBEBEB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Obx(() => Row(
                          children:
                              ["Semua", "Kering", "Frozen", "Minuman"].map((kat) {
                            bool isSelected =
                                toppingC.selectedCategory.value == kat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(kat,
                                    style: GoogleFonts.poppins(fontSize: 12)),
                                selected: isSelected,
                                onSelected: (_) =>
                                    toppingC.filterData(searchC.text, kat),
                                selectedColor: const Color(0xFFC62828),
                                backgroundColor: const Color(0xFFEBEBEB),
                                labelStyle: GoogleFonts.poppins(
                                  color:
                                      isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: BorderSide.none,
                                showCheckmark: false,
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                ],
              ),
            ),
            // List Produk
            Expanded(
              child: Obx(() {
                if (toppingC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: toppingC.filteredTopping.length,
                  itemBuilder: (context, index) {
                    final topping = toppingC.filteredTopping[index];
                    return _buildProductItem(topping);
                  },
                );
              }),
            ),
          ],
        ),
        // Sticky Button (Keranjang)
        Obx(() => kasirCtrl.cart.isNotEmpty
            ? Positioned(
                bottom: 20, left: 16, right: 16, child: _buildStickyButton())
            : const SizedBox.shrink()),
      ],
    );
  }

  // --- KONTEN HALAMAN RIWAYAT ---
  Widget _buildHistoryBody() {
    return HistoryPage();
  }

  Widget _buildProductItem(dynamic topping) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              topping.imageUrl ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[100],
                  width: 70,
                  height: 70,
                  child: const Icon(Icons.fastfood)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topping.namaTopping,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(topping.stok > 0 ? "Stok: ${topping.stok}" : "Stok Habis",
                    style: TextStyle(
                        color: topping.stok > 0 ? Colors.grey : Colors.red,
                        fontSize: 12)),
                Text("Rp ${topping.harga}",
                    style: const TextStyle(
                        color: Color(0xFFB71C1C), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Obx(() {
            int qty = kasirCtrl.cart[topping.id] ?? 0;
            return qty == 0
                ? ElevatedButton(
                    onPressed: topping.stok > 0
                        ? () => kasirCtrl.tambahKeKeranjang(topping.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white),
                    child: const Text("Tambah"),
                  )
                : Row(
                    children: [
                      IconButton(
                          onPressed: () =>
                              kasirCtrl.kurangiDariKeranjang(topping.id),
                          icon: const Icon(Icons.remove_circle_outline)),
                      Text("$qty",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: topping.stok > 0
                              ? () => kasirCtrl.tambahKeKeranjang(topping.id)
                              : null,
                          icon: Icon(Icons.add_circle,
                              color: topping.stok > 0
                                  ? const Color(0xFFB71C1C)
                                  : Colors.grey)),
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
          backgroundColor: const Color(0xFFB71C1C),
          padding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text("${kasirCtrl.totalItems} Items",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))),
          const Text("Lanjutkan",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Keluar",
      middleText: "Yakin ingin keluar?",
      textCancel: "Batal",
      textConfirm: "Ya",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFC62828),
      onConfirm: () => Get.offAll(() => const LoginPage()),
    );
  }

  void _showCheckoutSheet() {
    Get.to(() => PembayaranPage());
  }
}