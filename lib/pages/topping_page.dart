import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/topping_controller.dart';
import '../pages/login_page.dart';
import 'edit_topping_page.dart';
import 'add_topping_page.dart';
import 'staff_page.dart';
import 'report_page.dart';

class ToppingPage extends StatelessWidget {
  ToppingPage({super.key});

  final toppingC = Get.put(ToppingController());
  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      appBar: AppBar(
        title: Text(
          "NYEBLUCK",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFFC62828), // Navbar atas merah
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: toppingC.currentIndex.value,
            children: [
              _buildToppingBody(context),
              ReportPage(),
              StaffPage(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            selectedItemColor: const Color(0xFFC62828),
            unselectedItemColor: Colors.grey,
            currentIndex: toppingC.currentIndex.value,
            onTap: (index) => toppingC.currentIndex.value = index,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2), label: "TOPPING"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded), label: "LAPORAN"),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: "STAFF"),
            ],
          )),
    );
  }

  Widget _buildToppingBody(BuildContext context) {
    return Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Obx(() => Row(
                      children: ["Semua", "Kering", "Frozen", "Minuman"].map((kat) {
                        bool isSelected = toppingC.selectedCategory.value == kat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(kat, style: GoogleFonts.poppins(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (_) =>
                                toppingC.filterData(searchC.text, kat),
                            selectedColor: const Color(0xFFC62828),
                            backgroundColor: const Color(0xFFEBEBEB),
                            labelStyle: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.black87,
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
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddToppingPage()),
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
            label: Text("Tambah Topping",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (toppingC.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFC62828)));
            }
            if (toppingC.filteredTopping.isEmpty) {
              return const Center(child: Text("Topping tidak ditemukan"));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: toppingC.filteredTopping.length,
              itemBuilder: (context, index) {
                final item = toppingC.filteredTopping[index];
                bool isHabis = (item.stok == 0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: isHabis
                        ? Border.all(color: Colors.orange.shade300, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.imageUrl != null
                            ? Image.network(item.imageUrl!,
                                width: 60, height: 60, fit: BoxFit.cover)
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 30)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.namaTopping,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Rp ${item.harga}",
                                  style: const TextStyle(
                                      color: Color(0xFFC62828),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.circle,
                                      size: 3, color: Colors.grey),
                                ),
                                // Logika Teks Stok Unlimited di Inventory
                                Text(
                                  item.stok == -1 ? "Stok: Unlimited" : "Stok: ${isHabis ? 'Habis' : item.stok}",
                                  style: TextStyle(
                                      color: item.stok == -1 ? Colors.green : (isHabis ? Colors.red : Colors.grey[600]),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(Icons.edit, 
                              () => Get.to(() => const EditToppingPage(), arguments: item)),
                          const SizedBox(width: 6),
                          _buildActionButton(Icons.delete, 
                              () => _konfirmasiHapus(context, item.id!, item.namaTopping, item.imageUrl), 
                              isDelete: true),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap,
      {bool isDelete = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1F1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  void _konfirmasiHapus(
      BuildContext context, String id, String nama, String? url) {
    Get.defaultDialog(
      title: "Hapus",
      titleStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      middleText: "Hapus $nama?",
      textConfirm: "Ya",
      textCancel: "Tidak",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFC62828),
      onConfirm: () {
        Get.back();
        toppingC.hapusTopping(id, nama, url);
      },
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
      onConfirm: () => Get.offAll(const LoginPage()),
    );
  }
}