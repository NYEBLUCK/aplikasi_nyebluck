import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
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
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFC62828))),
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

  bool isNamaDuplikat(String nama, {String? excludeId}) {
    return allTopping.any((t) =>
        t.namaTopping.toLowerCase() == nama.toLowerCase() && t.id != excludeId);
  }

  Future<bool> simpanTopping(
      String nama, String kategori, int harga, int stok, bool takTerbatas, XFile? foto) async {
    try {
      isLoading(true);

      if (isNamaDuplikat(nama)) {
        Get.snackbar("Gagal", "Nama topping '$nama' sudah ada!");
        return false;
      }

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
        'nama_topping': namaFormatted, 
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'tak_terbatas': takTerbatas,
        'image_url': imageUrl,
      });

      ambilDataTopping();
      Get.back(); 
      _showSuccessDialog("Berhasil!", "Topping $namaFormatted telah ditambahkan");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Gagal Simpan: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateTopping(String id, String nama, String kategori, int harga,
      int stok, bool takTerbatas, String? urlLama, XFile? fotoBaru, bool hapusFotoLama) async {
    try {
      isLoading.value = true;

      if (isNamaDuplikat(nama, excludeId: id)) {
        Get.snackbar("Gagal", "Nama topping '$nama' sudah digunakan!");
        return false;
      }

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
      else if (hapusFotoLama && urlLama != null) {
        if (urlLama.contains('topping-images')) {
          try {
            final String oldFileName = urlLama.split('/').last;
            await supabase.storage.from('topping-images').remove([oldFileName]);
          } catch (e) {
            print("Info: File lama gagal dihapus atau tidak ditemukan.");
          }
        }
        finalImageUrl = null;
      }

      await supabase.from('toppings').update({
        'nama_topping': namaFormatted, 
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'tak_terbatas': takTerbatas,
        'image_url': finalImageUrl,
      }).eq('id', id);

      ambilDataTopping();
      Get.back(); 
      
      _showSuccessDialog("Berhasil!", "Data topping $namaFormatted berhasil diperbarui");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Gagal Update: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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
      _showSuccessDialog("Terhapus", "Topping $nama telah dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal Hapus: $e");
    } finally {
      isLoading(false);
    }
  }
}