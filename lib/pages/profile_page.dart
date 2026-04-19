import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), 
      body: Obx(() {
        if (profileC.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
        }

        final user = profileC.currentUser.value;
        if (user == null) {
          return const Center(child: Text("Data profil tidak ditemukan"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- NAMA LENGKAP ---
              Text(
                user.namaLengkap,
                style: GoogleFonts.poppins(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // --- BADGE ROLE ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0), 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD1D1)), 
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFC62828),
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 30), 

              // --- INFO CARDS ---
              _buildInfoCard(Icons.email_rounded, "EMAIL", user.email),
              const SizedBox(height: 12), 
              _buildInfoCard(Icons.phone_rounded, "NOMOR TELEPON", user.nomorTelpon),
              const SizedBox(height: 12),
              _buildInfoCard(Icons.location_on_rounded, "ALAMAT", user.alamat),

              const SizedBox(height: 35),

              // --- TOMBOL EKSKLUSIF ADMIN: GANTI PASSWORD ---
              if (user.role.toLowerCase() == 'admin') ...[
                SizedBox(
                  width: double.infinity,
                  height: 48, 
                  child: OutlinedButton.icon(
                    onPressed: () => _dialogGantiPasswordAdmin(context, profileC),
                    icon: const Icon(Icons.lock_reset, color: Color(0xFFC62828), size: 20), 
                    label: Text(
                      "Ganti Password Anda",
                      style: GoogleFonts.poppins(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC62828),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // --- TOMBOL KELUAR ---
              SizedBox(
                width: double.infinity,
                height: 48, 
                child: ElevatedButton.icon(
                  onPressed: () => profileC.logout(),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20), 
                  label: Text(
                    "Keluar",
                    style: GoogleFonts.poppins(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    elevation: 3, 
                    shadowColor: const Color(0xFFD32F2F).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade300, width: 2), 
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
          Container(
            padding: const EdgeInsets.all(10), 
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD32F2F), size: 20), 
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "-" : value,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 13, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG POP UP GANTI PASSWORD PRIBADI ---
  void _dialogGantiPasswordAdmin(BuildContext context, ProfileController profileC) {
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
              Text("Ganti Password Anda", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Masukkan password baru untuk mengamankan akun ini.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 25),
              
              TextField(
                controller: passwordC,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: "Password Baru",
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
                      child: Text("Batal", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
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
                          } else if (passwordC.text.trim().length < 6) {
                            errorPassword = "Password minimal 6 karakter";
                          }
                        });

                        if (errorPassword == null) {
                          profileC.gantiPasswordPribadi(passwordC.text.trim());
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
}