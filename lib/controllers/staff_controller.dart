import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import '../models/staff_model.dart'; 

// --- WIDGET ANIMASI LOADING 5 TITIK KHUSUS STAFF ---
class StaffDotLoading extends StatefulWidget {
  const StaffDotLoading({super.key});
  @override
  State<StaffDotLoading> createState() => _StaffDotLoadingState();
}

class _StaffDotLoadingState extends State<StaffDotLoading> with SingleTickerProviderStateMixin {
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

  // --- FUNGSI LAYAR LOADING GELAP ---
  void _showLoadingOverlay() {
    Get.dialog(
      PopScope(
        canPop: false, 
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const StaffDotLoading(), 
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

  String _sanitizeInput(String input) {
    return input.replaceAll('<', '').replaceAll('>', '').trim();
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
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFC62828))),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
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

  Future<void> ambilDataStaff() async {
    try {
      isLoading(true);
      final data = await supabase
          .from('profiles')
          .select()
          .neq('role', 'admin') 
          .order('is_active', ascending: false) 
          .order('nama_lengkap', ascending: true);

      allStaff.value = (data as List).map((e) => StaffModel.fromJson(e)).toList();
      filteredStaff.value = allStaff;
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data: $e");
    } finally {
      isLoading(false);
    }
  }

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

  Future<void> simpanStaff(String nama, String email, String telp, String alamat, String password) async {
    try {
      isLoading(true);
      final AuthResponse res = await supabase.auth.signUp(email: email.trim(), password: password);

      final String? newUserId = res.user?.id;
      if (newUserId != null) {
        await supabase.from('profiles').upsert({
          'id': newUserId, 
          'nama_lengkap': _sanitizeInput(nama), 
          'email': email.trim(),
          'nomor_telpon': _sanitizeInput(telp), 
          'alamat': _sanitizeInput(alamat), 
          'role': 'kasir',
        });
        
        await ambilDataStaff();
        Get.back(); 
        _showSuccessDialog("Berhasil!", "Akun Kasir ${_sanitizeInput(nama)} telah berhasil dibuat.");
      }
    } on AuthException catch (e) {
      _showErrorDialog("Gagal Daftar", e.message);
    } catch (e) {
      _showErrorDialog("Error", "Terjadi kesalahan sistem: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- ALUR UPDATE STAFF BARU ---
  Future<void> updateStaff(String id, String nama, String telp, String alamat) async {
    Get.back(); // 1. TUTUP FORM BOTTOM SHEET TERLEBIH DAHULU
    _showLoadingOverlay(); // 2. TAMPILKAN LAYAR LOADING GELAP

    try {
      await supabase.from('profiles').update({
        'nama_lengkap': _sanitizeInput(nama), 
        'nomor_telpon': _sanitizeInput(telp), 
        'alamat': _sanitizeInput(alamat), 
      }).eq('id', id);

      await ambilDataStaff(); // Perbarui data dari server
      
      _hideLoadingOverlay(); // 3. TUTUP LAYAR LOADING
      _showSuccessDialog("Diperbarui!", "Data pekerja berhasil diperbarui."); // 4. TAMPILKAN POP UP SUKSES
      
    } catch (e) {
      _hideLoadingOverlay(); // Tutup loading jika gagal
      _showErrorDialog("Error", "Gagal update: $e");
    } 
  }

  // --- ALUR UBAH STATUS (NONAKTIF/AKTIF) BARU ---
  Future<void> toggleStatusStaff(String id, bool currentStatus) async {
    _showLoadingOverlay(); // Langsung muncul loading (Get.back form konfirmasi sudah dipanggil di UI)
    try {
      await supabase
          .from('profiles')
          .update({'is_active': !currentStatus}) 
          .eq('id', id);
      
      await ambilDataStaff();
      
      _hideLoadingOverlay(); // Tutup loading
      String status = !currentStatus ? "diaktifkan" : "dinonaktifkan";
      _showSuccessDialog("Status Diubah", "Akun pekerja telah $status.");
    } catch (e) {
      _hideLoadingOverlay(); // Tutup loading jika gagal
      _showErrorDialog("Error", "Gagal mengubah status: $e");
    }
  }

  Future<void> gantiPasswordAdmin(String idPekerja, String passwordBaru) async {
    Get.back(); // 1. TUTUP FORM BOTTOM SHEET TERLEBIH DAHULU
    _showLoadingOverlay(); // 2. MUNCULKAN LAYAR LOADING GELAP

    try {
      // Sedikit jeda agar animasi terlihat natural
      await Future.delayed(const Duration(milliseconds: 1000));

      final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
      final String serviceKey = dotenv.env['SUPABASE_SERVICE_KEY']!;
      final adminClient = SupabaseClient(supabaseUrl, serviceKey);

      await adminClient.auth.admin.updateUserById(
        idPekerja,
        attributes: AdminUserAttributes(password: passwordBaru),
      );

      _hideLoadingOverlay(); // 3. TUTUP LOADING
      _showSuccessDialog("Berhasil", "Password pekerja telah berhasil diganti tanpa email."); // 4. NOTIF SUKSES
      
    } on AuthException catch (e) {
      _hideLoadingOverlay(); // Tutup loading jika gagal
      String pesanError = e.message;
      if (pesanError.toLowerCase().contains("different") || pesanError.toLowerCase().contains("same")) {
        pesanError = "Password baru tidak boleh sama dengan password pekerja yang lama!";
      }
      _showErrorDialog("Gagal", pesanError);
    } catch (e) {
      _hideLoadingOverlay();
      _showErrorDialog("Error", "Terjadi kesalahan: $e");
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
      return false; 
    }
  }
}