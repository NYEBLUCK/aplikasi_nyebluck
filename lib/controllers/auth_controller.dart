import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/topping_page.dart';
import '../pages/kasir_page.dart'; // Pastikan import kasir_page
import '../pages/login_page.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;
  var userRole = ''.obs;

  // Login
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
          await logout();
          Get.snackbar("Akses Ditolak", "Akun Anda tidak aktif.");
          return;
        }

        userRole.value = userData['role'];

        Get.snackbar(
          "Login Berhasil", 
          "Selamat Datang ${userRole.value == 'admin' ? 'Admin' : 'Kasir'}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
          duration: const Duration(seconds: 2)
        );

        // 3. NAVIGASI BERDASARKAN ROLE
        if (userRole.value == 'admin') {
          Get.offAll(() => ToppingPage());
        } else {
          Get.offAll(() => KasirPage());
        }
      }
    } catch (e) {
      print("Error Login: $e");
      Get.snackbar(
        "Login Gagal", 
        "Silahkan periksa kembali email dan password anda",
        backgroundColor: const Color.fromARGB(255, 139, 0, 0),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading(false);
    }
  }

  // Tambah Staff Baru (Hanya Admin)
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
        Get.snackbar("Sukses", "Akun Kasir Nyebluck Berhasil Dibuat");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => const LoginPage());
  }
}