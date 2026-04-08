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

  // --- LOGIKA SIMPAN (INSERT) ---
  Future<void> simpanTopping(
      String nama, String kategori, int harga, int stok, XFile? foto) async {
    try {
      isLoading(true);
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
        'nama_topping': nama,
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'image_url': imageUrl,
      });

      ambilDataTopping();
      Get.back();
      Get.snackbar("Berhasil", "Topping $nama ditambahkan!");
    } catch (e) {
      Get.snackbar("Error", "Gagal Simpan: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA PERBARUI (UPDATE) ---
  Future<void> updateTopping(String id, String nama, String kategori, int harga,
      int stok, String? urlLama, XFile? fotoBaru) async {
    try {
      isLoading.value = true;
      String? finalImageUrl = urlLama;

      // Cek apakah ada foto baru yang dipilih
      if (fotoBaru != null) {
        // 1. Hapus foto lama dari Storage (jika ada dan valid)
        if (urlLama != null && urlLama.contains('topping-images')) {
          try {
            final String fileName = urlLama.split('/').last;
            // Gunakan catchError agar proses tidak berhenti jika file tidak ditemukan di server
            await supabase.storage.from('topping-images').remove([fileName]);
          } catch (e) {
            print("Gagal hapus file lama (mungkin sudah terhapus): $e");
          }
        }

        // 2. Upload foto baru
        final bytes = await fotoBaru.readAsBytes();
        final String newFileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await supabase.storage
            .from('topping-images')
            .uploadBinary(newFileName, bytes);
        
        // 3. Ambil URL baru
        finalImageUrl = supabase.storage
            .from('topping-images')
            .getPublicUrl(newFileName);
      }

      // --- PROSES UPDATE DATABASE ---
      await supabase.from('toppings').update({
        'nama_topping': nama,
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'image_url': finalImageUrl,
      }).eq('id', id);

      ambilDataTopping();
      Get.back();
      Get.snackbar("Berhasil", "Data $nama berhasil diperbarui!");
    } catch (e) {
      Get.snackbar("Error", "Gagal Update: $e");
      print("Update Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA HAPUS (DELETE) ---
  Future<void> hapusTopping(String id, String? imageUrl) async {
    try {
      isLoading(true);
      
      // Hapus data dari tabel
      await supabase.from('toppings').delete().eq('id', id);

      // Hapus foto dari Storage jika ada
      if (imageUrl != null && imageUrl.contains('topping-images')) {
        try {
          final fileName = imageUrl.split('/').last;
          await supabase.storage.from('topping-images').remove([fileName]);
        } catch (e) {
          print("Storage file sudah tidak ada.");
        }
      }
      
      ambilDataTopping();
      Get.snackbar("Berhasil", "Topping telah dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal Hapus: $e");
    } finally {
      isLoading(false);
    }
  }
}