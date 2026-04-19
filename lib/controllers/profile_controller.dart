import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/staff_model.dart';
import '../pages/login_page.dart';

// --- WIDGET ANIMASI LOADING 5 TITIK KHUSUS PROFIL ---
class ProfileDotLoading extends StatefulWidget {
  const ProfileDotLoading({super.key});
  @override
  State<ProfileDotLoading> createState() => _ProfileDotLoadingState();
}

class _ProfileDotLoadingState extends State<ProfileDotLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double delay = index * 0.15;
            double value = (_controller.value - delay) % 1.0;
            if (value < 0) value += 1.0;
            double opacity = value < 0.5 ? 0.3 + (value * 2 * 0.7) : 1.0 - ((value - 0.5) * 2 * 0.7);
            return Opacity(opacity: opacity, child: Container(margin: const EdgeInsets.symmetric(horizontal: 5), width: 14, height: 14, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)));
          },
        );
      }),
    );
  }
}
// ----------------------------------------------------

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = true.obs;
  var currentUser = Rxn<StaffModel>();

  @override void onInit() { fetchProfile(); super.onInit(); }

  // --- FUNGSI LAYAR LOADING GELAP ---
  void _showLoadingOverlay() {
    Get.dialog(
      PopScope(
        canPop: false, 
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const ProfileDotLoading(), 
              const SizedBox(height: 15), 
              Text("Loading ...", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, decoration: TextDecoration.none))
            ]
          )
        )
      ), 
      barrierDismissible: false, 
      barrierColor: Colors.black.withValues(alpha: 0.7)
    );
  }

  void _hideLoadingOverlay() {
    if (Get.isDialogOpen == true) Get.back();
  }

 void _showSuccessDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "TUTUP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "TUTUP",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
            
        currentUser.value = StaffModel.fromJson(data);
      }
    } catch (e) {
      _showErrorDialog("Error", "Gagal memuat data profil");
    } finally {
      isLoading(false);
    }
  }

  // --- ALUR GANTI PASSWORD BARU ---
  Future<void> gantiPasswordPribadi(String passwordBaru) async {
    Get.back(); // 1. TUTUP FORM BOTTOM SHEET TERLEBIH DAHULU
    _showLoadingOverlay(); // 2. MUNCULKAN LAYAR LOADING GELAP

    try {
      // Sedikit jeda agar loading terlihat natural
      await Future.delayed(const Duration(milliseconds: 1000));
      
      await supabase.auth.updateUser(UserAttributes(password: passwordBaru));
      
      _hideLoadingOverlay(); // 3. TUTUP LAYAR LOADING
      _showSuccessDialog("Berhasil!", "Password Anda berhasil diperbarui."); // 4. MUNCULKAN NOTIF
    } on AuthException catch (e) {
      _hideLoadingOverlay(); // Tutup loading jika gagal
      String pesan = e.message;
      if (pesan.toLowerCase().contains("different") || pesan.toLowerCase().contains("same")) { 
        pesan = "Password baru tidak boleh sama dengan yang lama!"; 
      }
      _showErrorDialog("Gagal", pesan);
    } catch (e) {
      _hideLoadingOverlay(); // Tutup loading jika error sistem
      _showErrorDialog("Error", "Terjadi kesalahan sistem: $e");
    } 
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                "Apakah anda yakin ingin keluar dari akun ini?",
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Tidak",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await supabase.auth.signOut();
                        Get.offAll(() => const LoginPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Ya",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }
}