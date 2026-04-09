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
      filteredStaff.value = allStaff
          .where((s) => 
              s.namaLengkap.toLowerCase().contains(query.toLowerCase()) || 
              s.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // 3. Simpan Staff (Auth SignUp + Upsert Profiles)
  Future<void> simpanStaff(String nama, String email, String telp, String alamat, String password) async {
    try {
      isLoading(true);

      // A. Daftarkan di Authentication Supabase
      // Ini akan membuat user di tabel auth.users
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final String? newUserId = res.user?.id;

      if (newUserId != null) {
        // B. Masukkan atau Perbarui data di tabel Profiles
        // Menggunakan UPSERT agar jika ID sudah ada (karena percobaan sebelumnya gagal), 
        // data akan diperbarui bukannya error duplicate.
        await supabase.from('profiles').upsert({
          'id': newUserId, // Menghubungkan dengan ID dari Auth
          'nama_lengkap': nama,
          'email': email,
          'nomor_telpon': telp,
          'alamat': alamat,
          'role': 'kasir',
        });
        
        // Refresh data di UI
        await ambilDataStaff();
        
        Get.back(); // Tutup halaman/dialog
        Get.snackbar(
          "Berhasil", 
          "Akun Kasir $nama telah dibuat",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on AuthException catch (e) {
      // Menangkap error khusus Auth (misal: email sudah terdaftar)
      Get.snackbar("Gagal Daftar", e.message);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem: $e");
    } finally {
      isLoading(false);
    }
  }

  // 4. Update Staff (Hanya Profiles)
  Future<void> updateStaff(String id, String nama, String telp, String alamat) async {
    try {
      isLoading(true);
      await supabase.from('profiles').update({
        'nama_lengkap': nama,
        'nomor_telpon': telp,
        'alamat': alamat,
      }).eq('id', id);

      await ambilDataStaff();
      Get.back();
      Get.snackbar("Berhasil", "Data staff diperbarui");
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    } finally {
      isLoading(false);
    }
  }

  // 5. Hapus Staff (Delete)
  Future<void> toggleStatusStaff(String id, bool currentStatus) async {
    try {
      await supabase
          .from('profiles')
          .update({'is_active': !currentStatus}) // Balikkan statusnya
          .eq('id', id);
      
      ambilDataStaff();
      Get.snackbar("Sukses", currentStatus ? "Akun dinonaktifkan" : "Akun diaktifkan");
    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah status: $e");
    }
  }

  Future<bool> cekEmailTersedia(String email) async {
    try {
      // Kita cek ke tabel profiles apakah email sudah terdaftar
      final data = await supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      // Jika data null, berarti email BELUM ADA (Tersedia = true)
      return data == null; 
    } catch (e) {
      print("Cek Email Error: $e");
      // Jika error (misal koneksi), kita kembalikan false demi keamanan
      return false; 
    }
  }
}