import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/staff_controller.dart';
import '../models/staff_model.dart';
import 'add_staff_page.dart';

class StaffPage extends StatelessWidget {
  StaffPage({super.key});

  final staffC = Get.put(StaffController());
  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      body: Column(
        children: [
          // 2. Search Bar dengan gaya rounded
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
            child: TextField(
              controller: searchC,
              onChanged: (v) => staffC.filterStaff(v),
              decoration: InputDecoration(
                hintText: "Cari nama atau peran pekerja...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 3. Tombol Tambah Pekerja (Warna Merah Utama)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const AddStaffPage()),
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
              label: Text(
                "Tambah Pekerja",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                minimumSize: const Size(double.infinity, 52),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 4. List Staff
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
                  padding: const EdgeInsets.only(bottom: 100),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.namaLengkap,
                      style: GoogleFonts.poppins(
                        fontSize: 18, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.black
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tag Status AKTIF sesuai image_c04199.png
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: staff.isActive ? const Color(0xFF27AE60) : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        staff.isActive ? "AKTIF" : "NONAKTIF",
                        style: GoogleFonts.poppins(
                          color: Colors.white, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Titik Tiga
              IconButton(
                onPressed: () => _showActionMenu(context, staff),
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              )
            ],
          ),
          const SizedBox(height: 20),
          // Baris Informasi dengan Ikon Halus
          _infoRow(Icons.email, staff.email),
          _infoRow(Icons.phone, staff.nomorTelpon),
          _infoRow(Icons.location_on, staff.alamat),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8D6E63)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty ? "-" : text,
              style: GoogleFonts.poppins(
                color: Colors.black87, 
                fontSize: 13, 
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context, StaffModel staff) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Edit Data Pekerja"),
              onTap: () {
                Get.back();
                _dialogEditStaff(context, staff);
              },
            ),
            ListTile(
              leading: Icon(
                staff.isActive ? Icons.person_off_outlined : Icons.person_outline,
                color: staff.isActive ? Colors.red : Colors.green,
              ),
              title: Text(
                staff.isActive ? "Nonaktifkan Akun" : "Aktifkan Kembali",
                style: GoogleFonts.poppins(color: staff.isActive ? Colors.red : Colors.green),
              ),
              onTap: () {
                Get.back();
                _konfirmasiToggle(staff);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Edit Data
  void _dialogEditStaff(BuildContext context, StaffModel staff) {
    final namaC = TextEditingController(text: staff.namaLengkap);
    final telpC = TextEditingController(text: staff.nomorTelpon);
    final alamatC = TextEditingController(text: staff.alamat);

    // Variabel untuk menampung pesan error
    String? errorNama;
    String? errorTelp;
    String? errorAlamat;

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Data Pekerja",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Field Nama
              TextField(
                controller: namaC,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    String capitalized = value.split(' ').map((word) {
                      if (word.isEmpty) return "";
                      return word[0].toUpperCase() + word.substring(1).toLowerCase();
                    }).join(' ');

                    if (value != capitalized) {
                      namaC.value = namaC.value.copyWith(
                        text: capitalized,
                        selection: TextSelection.collapsed(offset: capitalized.length),
                      );
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  errorText: errorNama, 
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 15),

              // Field Telepon
              TextField(
                controller: telpC,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Nomor Telepon",
                  errorText: errorTelp,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 15),

              // Field Alamat
              TextField(
                controller: alamatC,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Alamat",
                  errorText: errorAlamat,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  // LOGIKA VALIDASI MODEL "isInvalid"
                  bool isInvalid = false;

                  setModalState(() {
                    errorNama = null;
                    errorTelp = null;
                    errorAlamat = null;

                    // 1. Validasi Nama
                    if (namaC.text.trim().isEmpty) {
                      errorNama = "Nama lengkap wajib diisi";
                      isInvalid = true;
                    }

                    // 2. Validasi Telepon
                    String telp = telpC.text.trim();
                    if (telp.isEmpty) {
                      errorTelp = "Nomor telepon wajib diisi";
                      isInvalid = true;
                    } else if (telp.length < 10 || telp.length > 13) {
                      errorTelp = "Nomor telepon harus 10-13 digit";
                      isInvalid = true;
                    }

                    // 3. Validasi Alamat
                    if (alamatC.text.trim().isEmpty) {
                      errorAlamat = "Alamat wajib diisi";
                      isInvalid = true;
                    }
                  });

                  // Eksekusi jika tidak ada yang invalid
                  if (!isInvalid) {
                    staffC.updateStaff(
                      staff.id!,
                      namaC.text.trim(),
                      telpC.text.trim(),
                      alamatC.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Simpan Perubahan",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  // Dialog Konfirmasi Nonaktif/Aktif
  void _konfirmasiToggle(StaffModel staff) {
    Get.defaultDialog(
      title: staff.isActive ? "Nonaktifkan Akun" : "Aktifkan Kembali",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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