import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'topping_controller.dart';
import '../pages/kasir_page.dart';

class KasirController extends GetxController {
  final supabase = Supabase.instance.client;
  final ToppingController toppingCtrl = Get.find<ToppingController>();

  // --- STATE NAVIGASI & UI ---
  var tabIndex = 0.obs;
  var isLoading = false.obs;

  // --- STATE TRANSAKSI ---
  var cart = <String, int>{}.obs; 
  var namaPembeli = "".obs;
  var levelPedas = 0.obs;
  var metodePembayaran = "tunai".obs; // Gunakan lowercase untuk menghindari check constraint
  var historyToday = <Map<String, dynamic>>[].obs;

  void changeTab(int index) {
    tabIndex.value = index;
    // Jika pindah ke tab riwayat, otomatis ambil data terbaru
    if (index == 1) fetchHistoryToday();
  }

  // --- LOGIKA KERANJANG ---
  void tambahKeKeranjang(String id) {
    try {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      if (item.stok > 0) {
        cart[id] = (cart[id] ?? 0) + 1;
        item.stok--;
        
        // Memaksa UI Topping untuk update stok sementara
        toppingCtrl.allTopping.refresh();
        toppingCtrl.filteredTopping.refresh();
      }
    } catch (e) {
      debugPrint("Error Tambah: $e");
    }
  }

  void kurangiDariKeranjang(String id) {
    if (cart.containsKey(id) && cart[id]! > 0) {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      if (cart[id] == 1) {
        cart.remove(id);
      } else {
        cart[id] = cart[id]! - 1;
      }
      
      item.stok++;
      toppingCtrl.allTopping.refresh();
      toppingCtrl.filteredTopping.refresh();
    }
  }

  // --- PROSES SIMPAN TRANSAKSI ---
  Future<void> prosesPembayaran() async {
    if (cart.isEmpty) return;
    
    try {
      isLoading.value = true;

      // 1. Ambil ID Kasir (Session Auth)
      final String? userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar("Error", "Sesi login berakhir. Silakan login ulang.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // 2. Simpan Header Transaksi ke tabel 'transactions'
      await supabase.from('transactions').insert({
        'cashier_id': userId,
        'nama_pembeli': namaPembeli.value.isEmpty ? "Pelanggan" : namaPembeli.value,
        'level_pedas': levelPedas.value,
        'metode': metodePembayaran.value, 
        'total_harga': totalBayar,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. Update Stok Permanen di tabel 'toppings'
      for (var entry in cart.entries) {
        String id = entry.key;
        var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
        
        await supabase
            .from('toppings')
            .update({'stok': item.stok})
            .match({'id': id});
      }

      // --- LOGIKA SETELAH BERHASIL ---

      // 4. Reset State Transaksi (PENTING: agar keranjang kosong kembali)
      cart.clear();
      namaPembeli.value = "";
      levelPedas.value = 0;
      metodePembayaran.value = "tunai";
      
      // 5. Kembali ke Kasir Page
      // offAll akan menghapus semua halaman sebelumnya dari memory, 
      // sehingga user tidak bisa menekan tombol 'back' untuk kembali ke halaman pembayaran.
      // Jika kamu tidak menggunakan named routes, gunakan: Get.offAll(() => KasirPage());
      Get.offAll(() => KasirPage());

      // 6. Refresh data history untuk tab riwayat
      fetchHistoryToday();

      // 7. Tampilkan feedback sukses
      Get.snackbar("Sukses", "Transaksi Berhasil Disimpan!", 
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
          
    } catch (e) {
      debugPrint("Error Proses Bayar: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan sistem: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- AMBIL RIWAYAT HARI INI ---
  Future<void> fetchHistoryToday() async {
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      // Gunakan tabel 'transactions' agar sinkron dengan prosesPembayaran
      final response = await supabase
          .from('transactions')
          .select()
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay)
          .order('created_at', ascending: false);

      historyToday.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint("Error Fetch History: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- GETTER CALCULATIONS ---
  int get totalItems => cart.values.fold(0, (sum, qty) => sum + qty);

  int get totalBayar {
    int total = 0;
    cart.forEach((id, qty) {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      total += (item.harga * qty);
    });
    return total;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}