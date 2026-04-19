import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/topping_controller.dart';
import '../controllers/kasir_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pembayaran_page.dart';
import 'history_page.dart';
import 'profile_page.dart'; 

class KasirPage extends StatelessWidget {
  final ToppingController toppingC = Get.put(ToppingController());
  final KasirController kasirCtrl = Get.put(KasirController());
  final TextEditingController searchC = TextEditingController();

  KasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() {
          String judul = "Kasir";
          if (kasirCtrl.tabIndex.value == 1) {
            judul = "Riwayat Transaksi";
          } else if (kasirCtrl.tabIndex.value == 2) {
            judul = "Profil";
          }
          
          return Text(
            judul,
            style: GoogleFonts.poppins(
                color: const Color(0xFFC62828), 
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 1),
          );
        }),
        backgroundColor: Colors.white, 
        surfaceTintColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300], // Warna garis abu-abu halus
            height: 1.0, // Ketebalan garis
          ),
        ),
      ),

      body: Obx(() {
        if (kasirCtrl.tabIndex.value == 0) {
          return _buildKasirBody();
        } else if (kasirCtrl.tabIndex.value == 1) {
          return HistoryPage();
        } else {
          return const ProfilePage(); 
        }
      }),

      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                // PENGATURAN GARIS TIPIS DI ATAS BOTTOM NAV
                top: BorderSide(color: Colors.grey.shade300, width: 2.0), 
              ),
            ),
            child: BottomNavigationBar(
              elevation: 0, // Wajib 0 agar garisnya terlihat bersih tanpa bayangan
              backgroundColor: Colors.white, 
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: "RIWAYAT"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "PROFIL"),
              ],
            ),
          )),
    );
  }

  Widget _buildKasirBody() {
    return Stack(
      children: [
        Column(
          children: [
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
                        hintText: "Cari topping",
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
                  const SizedBox(height: 5),
                ],
              ),
            ),
            
            // --- GARIS PEMBATAS ANTARA FILTER DAN LIST TOPPING ---
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            // -----------------------------------------------------

            Expanded(
              child: Obx(() {
                if (toppingC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // MENGGUNAKAN LISTVIEW.SEPARATED AGAR ADA GARIS TIAP ITEM
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: toppingC.filteredTopping.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 20, 
                    thickness: 1, 
                  ),
                  itemBuilder: (context, index) {
                    final topping = toppingC.filteredTopping[index];
                    return _buildProductItem(topping);
                  },
                );
              }),
            ),
          ],
        ),
        Obx(() => kasirCtrl.cart.isNotEmpty
            ? Positioned(
                bottom: 20, left: 16, right: 16, child: _buildStickyButton())
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildProductItem(dynamic topping) {
    // Container tidak lagi diberikan gaya putih & border (Card dihapus)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                // --- BARU: Menggunakan logika takTerbatas dari database ---
                Text(topping.takTerbatas 
                      ? "Stok: Tak Terbatas" 
                      : (topping.stok > 0 ? "Stok: ${topping.stok}" : "Stok Habis"),
                    style: TextStyle(
                        color: topping.takTerbatas ? Colors.green : (topping.stok > 0 ? Colors.grey : Colors.red),
                        fontSize: 12)),
                Text("Rp ${topping.harga}",
                    style: GoogleFonts.poppins(
                        color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Obx(() {
            int qty = kasirCtrl.cart[topping.id] ?? 0;
            return qty == 0
                ? ElevatedButton(
                    // --- BARU: Pengecekan takTerbatas (bukan -1) ---
                    onPressed: (topping.stok > 0 || topping.takTerbatas)
                        ? () => kasirCtrl.tambahKeKeranjang(topping.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white),
                    child: Text("Tambah", style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ))
                : Row(
                    children: [
                      IconButton(
                          onPressed: () =>
                              kasirCtrl.kurangiDariKeranjang(topping.id),
                          icon: const Icon(Icons.remove_circle_outline)),
                      Text("$qty",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          // --- BARU: Pengecekan takTerbatas ---
                          onPressed: (topping.stok > 0 || topping.takTerbatas)
                              ? () => kasirCtrl.tambahKeKeranjang(topping.id)
                              : null,
                          icon: Icon(Icons.add_circle,
                              color: (topping.stok > 0 || topping.takTerbatas)
                                  ? const Color(0xFFC62828)
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
          backgroundColor: const Color(0xFFC62828),
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

  void _showCheckoutSheet() {
    Get.to(() => PembayaranPage());
  }
}