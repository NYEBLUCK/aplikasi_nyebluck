import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/topping_controller.dart';
import 'edit_topping_page.dart';
import 'add_topping_page.dart';
import 'staff_page.dart';
import 'report_page.dart';
import 'profile_page.dart'; 

class ToppingPage extends StatelessWidget {
  ToppingPage({super.key});

  final toppingC = Get.put(ToppingController());
  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      
      appBar: AppBar(
        title: Obx(() {
          String judul = "Kelola Topping";
          if (toppingC.currentIndex.value == 1) {
            judul = "Laporan Penjualan";
          } else if (toppingC.currentIndex.value == 2) {
            judul = "Kelola Staff";
          } else if (toppingC.currentIndex.value == 3) {
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
            color: Colors.grey[300], 
            height: 1.0, 
          ),
        ),
      ),

      body: Obx(() => IndexedStack(
            index: toppingC.currentIndex.value,
            children: [
              _buildToppingBody(context),
              ReportPage(),
              StaffPage(),
              const ProfilePage(), 
            ],
          )),

      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 2.0), 
              ),
            ),
            child: BottomNavigationBar(
              elevation: 0, 
              backgroundColor: Colors.white, 
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.group), label: "STAFF"),
                BottomNavigationBarItem( 
                    icon: Icon(Icons.person), label: "PROFIL"),
              ],
            ),
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
        
        Divider(height: 1, thickness: 1, color: Colors.grey[300]),

        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => Get.to(
              () => const AddToppingPage(), 
              fullscreenDialog: true, 
            ),
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
                
                bool isHabis = (!item.takTerbatas && item.stok == 0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: isHabis
                        ? Border.all(color: Colors.orange.shade300, width: 2.0)
                        : Border.all(color: Colors.grey.shade300, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04), 
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                                Text(
                                  item.takTerbatas ? "Stok: Tak Terbatas" : "Stok: ${isHabis ? 'Habis' : item.stok}",
                                  style: TextStyle(
                                      color: item.takTerbatas ? Colors.green : (isHabis ? Colors.red : Colors.grey[600]),
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
                              () => Get.to(
                                () => const EditToppingPage(), 
                                arguments: item,
                                fullscreenDialog: true, 
                              )),
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
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Konfirmasi",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC62828),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Apakah anda yakin ingin menghapus $nama?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFC62828), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Tidak", style: GoogleFonts.poppins(color: const Color(0xFFC62828), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        toppingC.hapusTopping(id, nama, url);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Ya", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }
}