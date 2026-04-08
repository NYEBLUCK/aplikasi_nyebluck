import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_controller.dart';
import '../models/staff_model.dart';
import 'add_staff_page.dart';

class StaffPage extends StatelessWidget {
  StaffPage({super.key});

  // Memanggil controller yang sudah di-put sebelumnya atau baru
  final staffC = Get.put(StaffController());
  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchC,
              onChanged: (v) => staffC.filterStaff(v),
              decoration: InputDecoration(
                hintText: "Cari nama atau email pekerja...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Tombol Tambah Pekerja
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const AddStaffPage()),
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: const Text(
                "Tambah Pekerja",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. List Staff dengan RefreshIndicator
          Expanded(
            child: Obx(() {
              if (staffC.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
              }
              
              if (staffC.filteredStaff.isEmpty) {
                return const Center(
                  child: Text("Tidak ada data staff", style: TextStyle(color: Colors.grey)),
                );
              }

              return RefreshIndicator(
                onRefresh: () => staffC.ambilDataStaff(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: staffC.filteredStaff.length,
                  itemBuilder: (context, index) {
                    final staff = staffC.filteredStaff[index];
                    return _buildStaffCard(context, staff);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffModel staff) {
    // Tentukan warna tema kartu berdasarkan status aktif
    Color cardColor = staff.isActive ? Colors.white : Colors.grey[200]!;
    Color textColor = staff.isActive ? Colors.black : Colors.grey;
    
    // Tentukan warna role tag
    Color roleColor;
    if (!staff.isActive) {
      roleColor = Colors.grey;
    } else {
      roleColor = staff.role.toLowerCase() == 'admin' 
          ? Colors.red[900]! 
          : Colors.orange[600]!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (staff.isActive) 
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  staff.namaLengkap + (staff.isActive ? "" : " (Nonaktif)"),
                  style: TextStyle(
                    fontSize: 17, 
                    fontWeight: FontWeight.bold, 
                    color: textColor
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') _dialogEditStaff(context, staff);
                  if (val == 'toggle') _konfirmasiToggle(staff);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text("Edit Data")),
                  PopupMenuItem(
                    value: 'toggle', 
                    child: Text(
                      staff.isActive ? "Nonaktifkan Akun" : "Aktifkan Kembali", 
                      style: TextStyle(color: staff.isActive ? Colors.red : Colors.green)
                    )
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Tag Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              staff.role.toUpperCase(),
              style: TextStyle(
                color: roleColor, 
                fontSize: 9, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Info Baris (Email, Telp, Alamat)
          _infoRow(Icons.email_outlined, staff.email, textColor),
          _infoRow(Icons.phone_android_outlined, staff.nomorTelpon, textColor),
          _infoRow(Icons.location_on_outlined, staff.alamat, textColor),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.4)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.isEmpty ? "-" : text,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Edit Data
  void _dialogEditStaff(BuildContext context, StaffModel staff) {
    final namaC = TextEditingController(text: staff.namaLengkap);
    final telpC = TextEditingController(text: staff.nomorTelpon);
    final alamatC = TextEditingController(text: staff.alamat);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Data Pekerja",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: namaC,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline)
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: telpC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor Telepon", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined)
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: alamatC,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Alamat", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined)
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (namaC.text.isNotEmpty) {
                  staffC.updateStaff(staff.id!, namaC.text, telpC.text, alamatC.text);
                } else {
                  Get.snackbar("Peringatan", "Nama tidak boleh kosong");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Simpan Perubahan", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Dialog Konfirmasi Nonaktif/Aktif
  void _konfirmasiToggle(StaffModel staff) {
    Get.defaultDialog(
      title: staff.isActive ? "Nonaktifkan Akun" : "Aktifkan Kembali",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Yakin ingin mengubah status akun ${staff.namaLengkap}?",
      textConfirm: "Ya, Ubah",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: staff.isActive ? const Color(0xFFC62828) : const Color(0xFFC62828),
      onConfirm: () {
        staffC.toggleStatusStaff(staff.id!, staff.isActive);
        Get.back();
      },
    );
  }
}