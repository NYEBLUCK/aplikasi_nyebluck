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
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
            child: TextField(
              controller: searchC,
              onChanged: (v) => staffC.filterStaff(v),
              decoration: InputDecoration(
                hintText: "Cari nama Staff",
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(
                () => const AddStaffPage(),
                fullscreenDialog: true,
              ),
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
              label: Text(
                "Tambah Staff",
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

              return ListView.builder(
                physics: const ClampingScrollPhysics(), 
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: staffC.filteredStaff.length,
                itemBuilder: (context, index) {
                  final staff = staffC.filteredStaff[index];
                  return _buildStaffCard(context, staff);
                },
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
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 12, 
            offset: const Offset(0, 4)
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
                        color: Color(0xFFD32F2F)
                      ),
                    ),
                    const SizedBox(height: 6),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: (String value) {
                  if (value == 'edit') {
                    _dialogEditStaff(context, staff);
                  } else if (value == 'ganti_password') {
                    _dialogGantiPasswordAdmin(context, staff); 
                  } else if (value == 'toggle') {
                    _konfirmasiToggle(staff);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                        const SizedBox(width: 12),
                        Text("Edit Data Staff", style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'ganti_password',
                    child: Row(
                      children: [
                        const Icon(Icons.password, size: 20, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text("Ganti Password", style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          staff.isActive ? Icons.person_off_outlined : Icons.person_outline, 
                          size: 20, 
                          color: staff.isActive ? Colors.red : Colors.green
                        ),
                        const SizedBox(width: 12),
                        Text(
                          staff.isActive ? "Nonaktifkan Akun" : "Aktifkan Kembali", 
                          style: GoogleFonts.poppins(
                            fontSize: 13, 
                            color: staff.isActive ? Colors.red : Colors.green
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
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
          Icon(icon, size: 16, color: Colors.black),
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

  void _dialogGantiPasswordAdmin(BuildContext context, StaffModel staff) {
    final passwordC = TextEditingController();
    bool isObscure = true;
    String? errorPassword;

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
              Text("Ganti Password Staff", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Ubah password untuk akun ${staff.namaLengkap}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 25),
              
              TextField(
                controller: passwordC,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: "Masukkan Password Baru",
                  errorText: errorPassword, 
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setModalState(() => isObscure = !isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- TOMBOL BATAL & SIMPAN ---
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBEBEB),
                        side: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Batal", style: GoogleFonts.poppins(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setModalState(() {
                          errorPassword = null;
                          if (passwordC.text.trim().isEmpty) {
                            errorPassword = "Password tidak boleh kosong";
                          } else if (passwordC.text.trim().length < 8) {
                            errorPassword = "Password minimal 8 karakter";
                          }
                        });

                        if (errorPassword == null) {
                          staffC.gantiPasswordAdmin(staff.id!, passwordC.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828), 
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  void _dialogEditStaff(BuildContext context, StaffModel staff) {
    final namaC = TextEditingController(text: staff.namaLengkap);
    final telpC = TextEditingController(text: staff.nomorTelpon);
    final alamatC = TextEditingController(text: staff.alamat);

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
              Text("Edit Data Staff", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
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

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBEBEB),
                        side: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Batal", style: GoogleFonts.poppins(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        bool isInvalid = false;

                        setModalState(() {
                          errorNama = null;
                          errorTelp = null;
                          errorAlamat = null;

                          if (namaC.text.trim().isEmpty) {
                            errorNama = "Nama lengkap wajib diisi";
                            isInvalid = true;
                          }

                          String telp = telpC.text.trim();
                          if (telp.isEmpty) {
                            errorTelp = "Nomor telepon wajib diisi";
                            isInvalid = true;
                          } else if (telp.length < 10 || telp.length > 13) {
                            errorTelp = "Nomor telepon harus 10-13 digit";
                            isInvalid = true;
                          }

                          if (alamatC.text.trim().isEmpty) {
                            errorAlamat = "Alamat wajib diisi";
                            isInvalid = true;
                          }
                        });

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
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  void _konfirmasiToggle(StaffModel staff) {
    String aksi = staff.isActive ? "menonaktifkan" : "mengaktifkan kembali";
    
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
                "Apakah anda yakin ingin $aksi akun ${staff.namaLengkap}?",
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
                        staffC.toggleStatusStaff(staff.id!, staff.isActive);
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