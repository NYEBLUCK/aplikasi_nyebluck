import 'package:flutter/material.dart'; // Wajib ditambahkan untuk memanggil UI Dialog
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/topping_model.dart';

class ToppingController extends GetxController {
  final supabase = Supabase.instance.client;

  var currentIndex = 0.obs;
  var allTopping = <ToppingModel>[].obs;
  var filteredTopping = <ToppingModel>[].obs;
  var selectedCategory = "Semua".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    ambilDataTopping();
    super.onInit();
  }

  // --- HELPER: FORMAT TITLE CASE ---
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // --- HELPER: TAMPILKAN POP UP SUKSES ---
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 13)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(), // Tutup pop-up
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
      barrierDismissible: false, // Wajib klik tombol tutup
    );
  }

  // --- LOGIKA AMBIL DATA ---
  void ambilDataTopping() async {
    try {
      isLoading(true);
      final data = await supabase
          .from('toppings')
          .select()
          .order('nama_topping', ascending: true);

      allTopping.value =
          (data as List).map((e) => ToppingModel.fromJson(e)).toList();
      filterData("", selectedCategory.value);
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil data: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA FILTER & SEARCH ---
  void filterData(String query, String kategori) {
    selectedCategory.value = kategori;
    var hasil = allTopping.where((item) {
      bool cocokNama =
          item.namaTopping.toLowerCase().contains(query.toLowerCase());
      bool cocokKategori = (kategori == "Semua") || (item.kategori == kategori);
      return cocokNama && cocokKategori;
    }).toList();

    hasil.sort((a, b) =>
        a.namaTopping.toLowerCase().compareTo(b.namaTopping.toLowerCase()));
    filteredTopping.value = hasil;
  }

  // --- LOGIKA VALIDASI DUPLIKAT ---
  bool isNamaDuplikat(String nama, {String? excludeId}) {
    return allTopping.any((t) =>
        t.namaTopping.toLowerCase() == nama.toLowerCase() && t.id != excludeId);
  }

  // --- LOGIKA SIMPAN (INSERT) ---
  Future<bool> simpanTopping(
      String nama, String kategori, int harga, int stok, XFile? foto) async {
    try {
      isLoading(true);

      if (isNamaDuplikat(nama)) {
        Get.snackbar("Gagal", "Nama topping '$nama' sudah ada!");
        return false;
      }

      // FORMAT NAMA MENJADI TITLE CASE
      String namaFormatted = _toTitleCase(nama);

      String? imageUrl;
      if (foto != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final bytes = await foto.readAsBytes();
        await supabase.storage
            .from('topping-images')
            .uploadBinary(fileName, bytes);
        imageUrl =
            supabase.storage.from('topping-images').getPublicUrl(fileName);
      }

      await supabase.from('toppings').insert({
        'nama_topping': namaFormatted, // Gunakan nama yang sudah diformat
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'image_url': imageUrl,
      });

      ambilDataTopping();
      Get.back(); // Tutup halaman tambah topping
      
      // MUNCULKAN POP UP SUKSES
      _showSuccessDialog("Berhasil!", "Topping '$namaFormatted' telah ditambahkan.");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Gagal Simpan: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA PERBARUI (UPDATE) ---
  Future<bool> updateTopping(String id, String nama, String kategori, int harga,
      int stok, String? urlLama, XFile? fotoBaru) async {
    try {
      isLoading.value = true;

      if (isNamaDuplikat(nama, excludeId: id)) {
        Get.snackbar("Gagal", "Nama topping '$nama' sudah digunakan!");
        return false;
      }

      // FORMAT NAMA MENJADI TITLE CASE
      String namaFormatted = _toTitleCase(nama);
      String? finalImageUrl = urlLama;

      if (fotoBaru != null) {
        if (urlLama != null && urlLama.contains('topping-images')) {
          try {
            final String oldFileName = urlLama.split('/').last;
            await supabase.storage.from('topping-images').remove([oldFileName]);
          } catch (e) {
            print("Info: File lama tidak ditemukan di storage.");
          }
        }

        final bytes = await fotoBaru.readAsBytes();
        final String newFileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await supabase.storage
            .from('topping-images')
            .uploadBinary(newFileName, bytes);
        
        finalImageUrl = supabase.storage
            .from('topping-images')
            .getPublicUrl(newFileName);
      }

      await supabase.from('toppings').update({
        'nama_topping': namaFormatted, // Gunakan nama yang sudah diformat
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'image_url': finalImageUrl,
      }).eq('id', id);

      ambilDataTopping();
      Get.back(); // Tutup halaman edit
      
      // MUNCULKAN POP UP SUKSES
      _showSuccessDialog("Berhasil!", "Data '$namaFormatted' berhasil diperbarui.");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Gagal Update: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA HAPUS (DELETE) ---
  Future<void> hapusTopping(String id, String nama, String? imageUrl) async {
    try {
      isLoading(true);
      
      await supabase.from('toppings').delete().eq('id', id);

      if (imageUrl != null && imageUrl.contains('topping-images')) {
        try {
          final fileName = imageUrl.split('/').last;
          await supabase.storage.from('topping-images').remove([fileName]);
        } catch (e) {
          print("Storage file sudah tidak ada.");
        }
      }
      
      ambilDataTopping();
      
      // MUNCULKAN POP UP SUKSES
      _showSuccessDialog("Terhapus", "Topping '$nama' telah dihapus dari daftar.");
    } catch (e) {
      Get.snackbar("Error", "Gagal Hapus: $e");
    } finally {
      isLoading(false);
    }
  }
}