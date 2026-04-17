import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff_model.dart'; 

class StaffController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var allStaff = <StaffModel>[].obs;
  var filteredStaff = <StaffModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    ambilDataStaff();
    super.onInit();
  }

  // --- FUNGSI PENCEGAH INJEKSI KODE (XSS) ---
  String _sanitizeInput(String input) {
    // Menghapus karakter < dan > yang sering digunakan untuk injeksi script/HTML
    return input.replaceAll('<', '').replaceAll('>', '').trim();
  }

  // --- FUNGSI POP UP SUKSES ---
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

  // 1. Ambil Data (Read)
  Future<void> ambilDataStaff() async {
    try {
      isLoading(true);
      final data = await supabase
          .from('profiles')
          .select()
          .neq('role', 'admin') 
          .order('is_active', ascending: false) // Yang aktif di atas
          .order('nama_lengkap', ascending: true);

      allStaff.value = (data as List).map((e) => StaffModel.fromJson(e)).toList();
      filteredStaff.value = allStaff;
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data: $e");
    } finally {
      isLoading(false);
    }
  }

  // 2. Fungsi Pencarian (Filter)
  void filterStaff(String query) {
    if (query.isEmpty) {
      filteredStaff.value = allStaff;
    } else {
      String safeQuery = _sanitizeInput(query);
      filteredStaff.value = allStaff
          .where((s) => 
              s.namaLengkap.toLowerCase().contains(safeQuery.toLowerCase()) || 
              s.email.toLowerCase().contains(safeQuery.toLowerCase()))
          .toList();
    }
  }

  // 3. Simpan Staff (Auth SignUp + Upsert Profiles)
  Future<void> simpanStaff(String nama, String email, String telp, String alamat, String password) async {
    try {
      isLoading(true);

      final AuthResponse res = await supabase.auth.signUp(
        email: email.trim(), // Email cukup ditrim
        password: password,
      );

      final String? newUserId = res.user?.id;

      if (newUserId != null) {
        await supabase.from('profiles').upsert({
          'id': newUserId, 
          'nama_lengkap': _sanitizeInput(nama), // Bersihkan data
          'email': email.trim(),
          'nomor_telpon': _sanitizeInput(telp), // Bersihkan data
          'alamat': _sanitizeInput(alamat), // Bersihkan data
          'role': 'kasir',
        });
        
        await ambilDataStaff();
        
        Get.back(); // Tutup halaman form
        _showSuccessDialog("Berhasil!", "Akun Kasir ${_sanitizeInput(nama)} telah berhasil dibuat.");
      }
    } on AuthException catch (e) {
      Get.snackbar("Gagal Daftar", e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // 4. Update Staff (Hanya Profiles)
  Future<void> updateStaff(String id, String nama, String telp, String alamat) async {
    try {
      isLoading(true);
      await supabase.from('profiles').update({
        'nama_lengkap': _sanitizeInput(nama), // Bersihkan data
        'nomor_telpon': _sanitizeInput(telp), // Bersihkan data
        'alamat': _sanitizeInput(alamat), // Bersihkan data
      }).eq('id', id);

      await ambilDataStaff();
      Get.back(); // Tutup form edit
      _showSuccessDialog("Diperbarui!", "Data pekerja berhasil diperbarui.");
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // 5. Hapus Staff (Toggle Status)
  Future<void> toggleStatusStaff(String id, bool currentStatus) async {
    try {
      await supabase
          .from('profiles')
          .update({'is_active': !currentStatus}) 
          .eq('id', id);
      
      await ambilDataStaff();
      String status = !currentStatus ? "diaktifkan" : "dinonaktifkan";
      _showSuccessDialog("Status Diubah", "Akun pekerja telah $status.");
    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah status: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<bool> cekEmailTersedia(String email) async {
    try {
      final data = await supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      return data == null; 
    } catch (e) {
      print("Cek Email Error: $e");
      return false; 
    }
  }
}