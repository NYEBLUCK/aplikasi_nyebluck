import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/topping_controller.dart';
import '../pages/login_page.dart';
import 'edit_topping_page.dart';
import 'add_topping_page.dart';
import 'staff_page.dart'; // Pastikan import StaffPage

class ToppingPage extends StatelessWidget {
  ToppingPage({super.key});

  final toppingC = Get.put(ToppingController());
  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      appBar: AppBar(
        title: const Text(
          "NYEBLUCK",
          style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFFEBEBEB),
                child: Icon(Icons.person, color: Color(0xFF4A2C2C)),
              ),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text("Log Out"),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      
      // MENGGUNAKAN OBX DAN INDEXEDSTACK DI BODY
      body: Obx(() => IndexedStack(
            index: toppingC.currentIndex.value,
            children: [
              _buildToppingBody(context), // Tab 0: Topping
              const Center(child: Text("Halaman Reports")), // Tab 1: Reports
              StaffPage(), // Tab 2: Staff
            ],
          )),

      bottomNavigationBar: Obx(() => BottomNavigationBar(
            selectedItemColor: const Color(0xFFC62828),
            unselectedItemColor: Colors.grey,
            currentIndex: toppingC.currentIndex.value,
            onTap: (index) {
              toppingC.currentIndex.value = index; // Pindah tab
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "TOPPING"),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "REPORTS"),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "STAFF"),
            ],
          )),
    );
  }

  // PINDAHKAN LOGIKA BODY TOPPING KE SINI
  Widget _buildToppingBody(BuildContext context) {
    return Column(
      children: [
        // 1. Tombol Tambah Topping

        // 2. Search Bar
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: searchC,
            onChanged: (v) => toppingC.filterData(v, toppingC.selectedCategory.value),
            decoration: InputDecoration(
              hintText: "Cari topping",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
         // 3. Kategori Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Obx(() => Row(
                children: ["Semua", "Kering", "Frozen", "Minuman"].map((kat) {
                  bool isSelected = toppingC.selectedCategory.value == kat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(kat),
                      selected: isSelected,
                      onSelected: (_) => toppingC.filterData(searchC.text, kat),
                      selectedColor: const Color(0xFFC62828),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddToppingPage()),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Tambah Topping",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        // 4. List Topping
        Expanded(
          child: Obx(() {
            if (toppingC.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
            }

            if (toppingC.filteredTopping.isEmpty) {
              return const Center(child: Text("Topping tidak ditemukan"));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: toppingC.filteredTopping.length,
              itemBuilder: (context, index) {
                final item = toppingC.filteredTopping[index];
                bool isHabis = (item.stok == 0);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.imageUrl != null
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 85, height: 85, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(width: 85, height: 85, color: Colors.grey[100], child: const Icon(Icons.image_not_supported)),
                                  )
                                : Container(width: 85, height: 85, color: Colors.grey[100], child: const Icon(Icons.image)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.kategori.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                Text(item.namaTopping, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("HARGA JUAL", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text("Rp ${item.harga}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("STOK TERSEDIA", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text(isHabis ? "Habis" : "${item.stok} pcs", style: TextStyle(fontWeight: FontWeight.bold, color: isHabis ? Colors.red : Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.to(() => const EditToppingPage(), arguments: item),
                            icon: const Icon(Icons.edit_note, color: Colors.grey),
                          ),
                          IconButton(
                            onPressed: () => _konfirmasiHapus(context, item.id!, item.namaTopping, item.imageUrl),
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          ),
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

  void _konfirmasiHapus(BuildContext context, String id, String nama, String? url) {
    Get.defaultDialog(
      title: "Hapus Topping",
      middleText: "Yakin ingin menghapus $nama?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFC62828),
      onConfirm: () {
        toppingC.hapusTopping(id, url);
        Get.back();
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      middleText: "Apakah Anda yakin ingin keluar?",
      textCancel: "Batal",
      textConfirm: "Ya, Keluar",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFC62828),
      onConfirm: () => Get.offAll(LoginPage()),
    );
  }
}