import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/topping_page.dart';
import '../pages/kasir_page.dart'; 
import '../pages/login_page.dart';

class DotLoadingIndicator extends StatefulWidget {
  const DotLoadingIndicator({super.key});

  @override
  State<DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<DotLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

            double opacity = 1.0;
            if (value < 0.5) {
              opacity = 0.3 + (value * 2 * 0.7);
            } else {
              opacity = 1.0 - ((value - 0.5) * 2 * 0.7);
            }

            return Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5), 
                width: 14, 
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle, 
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;
  var userRole = ''.obs;

  void _showLoadingOverlay() {
    Get.dialog(
      PopScope(
        canPop: false, 
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DotLoadingIndicator(),
              const SizedBox(height: 15),
              Text(
                "Loading ...",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900, 
                  decoration: TextDecoration.none, 
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7), 
      name: "LoadingOverlay",
    );
  }

  void _hideLoadingOverlay() {
    if (Get.isDialogOpen == true) {
      Get.back(); 
    }
  }

  void _showErrorDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(title, style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 13)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(), 
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text("TUTUP", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFC62828))),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 13)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text("TUTUP", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      _showLoadingOverlay(); 

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await supabase
            .from('profiles')
            .select('role, is_active')
            .eq('id', response.user!.id)
            .single();

        if (userData['is_active'] == false) {
          await supabase.auth.signOut(); 
          _hideLoadingOverlay(); 
          _showErrorDialog("Akses Ditolak", "Akun Anda telah dinonaktifkan.\nSilakan hubungi Admin.");
          return;
        }

        userRole.value = userData['role'];
        
        await Future.delayed(const Duration(milliseconds: 1200));
        
        _hideLoadingOverlay(); 

        // --- UBAH ANIMASI LOGIN JADI GESER (SLIDE) ---
        if (userRole.value == 'admin') {
          Get.offAll(() => ToppingPage());
        } else {
          Get.offAll(() => KasirPage()); 
        }
      }
    } catch (e) {
      print("Error Login: $e");
      _hideLoadingOverlay(); 
      _showErrorDialog("Login Gagal", "Silahkan periksa kembali email dan password anda.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> tambahStaff(String email, String pass, String nama, String telp, String alamat) async {
    try {
      isLoading(true);
      final res = await supabase.auth.signUp(email: email, password: pass);
      if (res.user != null) {
        await supabase.from('profiles').insert({
          'id': res.user!.id,
          'nama_lengkap': nama,
          'email': email,
          'nomor_telpon': telp,
          'alamat': alamat,
          'role': 'kasir',
          'is_active': true,
        });
        Get.back();
        _showSuccessDialog("Berhasil!", "Akun Kasir Nyebluck Berhasil Dibuat");
      }
    } catch (e) {
      _showErrorDialog("Error Sistem", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    _showLoadingOverlay(); 
    
    await Future.delayed(const Duration(milliseconds: 1200)); 
    await supabase.auth.signOut();
    
    _hideLoadingOverlay(); 
    
    Get.offAll(() => const LoginPage(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 600));
  }
}