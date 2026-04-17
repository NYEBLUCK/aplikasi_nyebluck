import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/topping_page.dart';
import '../pages/kasir_page.dart'; 
import '../pages/login_page.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;
  var userRole = ''.obs;

  // --- FUNGSI POP UP: LOGIN BERHASIL ---
  void _showSuccessLoginDialog(String role) {
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
              const Text("Login Berhasil!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text(
                "Selamat Datang ${role == 'admin' ? 'Admin' : 'Kasir'}!", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.black, fontSize: 13)
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Tutup dialog
                    // Navigasi ke halaman sesuai role
                    if (role == 'admin') {
                      Get.offAll(() => ToppingPage());
                    } else {
                      Get.offAll(() => KasirPage());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("LANJUTKAN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Wajib klik tombol Lanjutkan
    );
  }

  // --- FUNGSI POP UP: GAGAL / ERROR ---
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 13)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(), // Hanya tutup dialog agar bisa coba lagi
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("TUTUP", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- FUNGSI POP UP: SUKSES UMUM ---
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
                  child: const Text("TUTUP", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- LOGIKA LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 1. AMBIL DATA ROLE DARI TABEL PROFILES
        final userData = await supabase
            .from('profiles')
            .select('role, is_active')
            .eq('id', response.user!.id)
            .single();

        // 2. CEK STATUS AKTIF (Safety Check)
        if (userData['is_active'] == false) {
          // Hanya sign out dari sesi Supabase, tidak panggil logout() yang memicu perpindahan halaman
          await supabase.auth.signOut(); 
          _showErrorDialog("Akses Ditolak", "Akun Anda telah dinonaktifkan.\nSilakan hubungi Admin.");
          return;
        }

        userRole.value = userData['role'];

        // 3. TAMPILKAN POP UP SUKSES
        // (Navigasi ke Kasir/Admin akan dipicu saat user klik "LANJUTKAN" di dalam pop-up)
        _showSuccessLoginDialog(userRole.value);
      }
    } catch (e) {
      print("Error Login: $e");
      // Menampilkan Pop-Up Gagal Login
      _showErrorDialog("Login Gagal", "Silahkan periksa kembali email dan password anda.");
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA TAMBAH STAFF (Jika masih dipakai di controller ini) ---
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
        // Menampilkan Pop-Up Sukses
        _showSuccessDialog("Berhasil!", "Akun Kasir Nyebluck Berhasil Dibuat");
      }
    } catch (e) {
      _showErrorDialog("Error Sistem", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA LOGOUT ---
  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => const LoginPage());
  }
}