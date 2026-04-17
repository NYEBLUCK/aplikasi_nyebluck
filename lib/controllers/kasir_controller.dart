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
  var metodePembayaran = "tunai".obs;
  var uangBayar = 0.obs; 
  
  // BARU: State untuk menampung pesan error pada input uang cash
  var errorUangBayar = "".obs; 

  var historyToday = <Map<String, dynamic>>[].obs;

  void changeTab(int index) {
    tabIndex.value = index;
    if (index == 1) fetchHistoryToday();
  }

  void tambahKeKeranjang(String id) {
    try {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      // BISA DITAMBAH JIKA STOK > 0 ATAU STOK == -1 (Unlimited)
      if (item.stok > 0 || item.stok == -1) {
        cart[id] = (cart[id] ?? 0) + 1;
        
        // KURANGI STOK SEMENTARA HANYA JIKA BUKAN UNLIMITED
        if (item.stok != -1) item.stok--; 
        
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
      
      // KEMBALIKAN STOK SEMENTARA HANYA JIKA BUKAN UNLIMITED
      if (item.stok != -1) item.stok++; 
      
      toppingCtrl.allTopping.refresh();
      toppingCtrl.filteredTopping.refresh();
    }
  }

  // --- PROSES SIMPAN TRANSAKSI ---
  Future<void> prosesPembayaran() async {
    if (cart.isEmpty) return;

    // --- BARU: BLOK VALIDASI UANG TUNAI ---
    if (metodePembayaran.value == 'tunai') {
      if (uangBayar.value == 0) {
        errorUangBayar.value = "Nominal uang tidak boleh kosong";
        return; // Hentikan proses jika error
      } else if (uangBayar.value < totalBayar) {
        errorUangBayar.value = "Uang kurang Rp ${totalBayar - uangBayar.value}";
        return; // Hentikan proses jika error
      }
    }
    // Jika lolos validasi, kosongkan pesan error
    errorUangBayar.value = "";
    // --------------------------------------
    
    try {
      isLoading.value = true;

      final String? userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showFailedDialog("Sesi login berakhir. Silakan login ulang.");
        return;
      }

      int finalBayar = metodePembayaran.value == 'qris' ? totalBayar : uangBayar.value;
      if (finalBayar < totalBayar) finalBayar = totalBayar; 
      int finalKembalian = finalBayar - totalBayar;

      final transactionData = await supabase.from('transactions').insert({
        'cashier_id': userId,
        'nama_pembeli': namaPembeli.value.isEmpty ? "Pelanggan" : namaPembeli.value,
        'level_pedas': levelPedas.value,
        'metode': metodePembayaran.value, 
        'total_harga': totalBayar,
        'total_quantity': totalItems, 
        'bayar': finalBayar,          
        'kembalian': finalKembalian,  
        'created_at': DateTime.now().toUtc().toIso8601String(), 
      }).select('id').single();

      final String transactionId = transactionData['id'];

      List<Map<String, dynamic>> itemsToInsert = [];
      for (var entry in cart.entries) {
        String toppingId = entry.key;
        var item = toppingCtrl.allTopping.firstWhere((t) => t.id == toppingId);
        
        itemsToInsert.add({
          'transaction_id': transactionId,
          'topping_name': item.namaTopping,
          'quantity': entry.value,
          'price': item.harga,
        });
      }

      if (itemsToInsert.isNotEmpty) {
        await supabase.from('transaction_items').insert(itemsToInsert);
      }

      for (var entry in cart.entries) {
        String id = entry.key;
        var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
        if (item.stok != -1) {
          await supabase
              .from('toppings')
              .update({'stok': item.stok})
              .match({'id': id});
        }
      }

      _showSuccessDialog(
        transactionId: transactionId,
        namaPembeli: namaPembeli.value.isEmpty ? "Pelanggan" : namaPembeli.value,
        totalHarga: totalBayar,
        totalQuantity: totalItems,
        bayar: finalBayar,
        kembalian: finalKembalian,
        metode: metodePembayaran.value,
      );

      fetchHistoryToday();

    } catch (e) {
      debugPrint("Error Proses Bayar: $e");
      _showFailedDialog("Terjadi kesalahan saat memproses transaksi:\n$e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog({
    required String transactionId,
    required String namaPembeli,
    required int totalHarga,
    required int totalQuantity,
    required int bayar,
    required int kembalian,
    required String metode,
  }) {
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
              const Text("Transaksi Berhasil!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              _buildDialogDetailRow("Metode", metode.toUpperCase()),
              _buildDialogDetailRow("Total QTY", "$totalQuantity item"),
              _buildDialogDetailRow("Total Bayar", "Rp $totalHarga"),
              _buildDialogDetailRow("Kembalian", "Rp $kembalian"),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); 
                    resetTransactionState(); 
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("OKE, KEMBALI KE KASIR", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, 
    );
  }

  void _showFailedDialog(String errorMessage) {
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
              const Text("Transaksi Gagal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
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

  Widget _buildDialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void resetTransactionState() {
    cart.clear();
    namaPembeli.value = "";
    levelPedas.value = 0;
    metodePembayaran.value = "tunai";
    uangBayar.value = 0;
    errorUangBayar.value = ""; // BARU: Reset error state
    Get.offAll(() => KasirPage());
  }

  Future<void> fetchHistoryToday() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0).toUtc().toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String();

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

  int get totalItems => cart.values.fold(0, (sum, qty) => sum + qty);

  int get totalBayar {
    int total = 0;
    cart.forEach((id, qty) {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      total += (item.harga * qty);
    });
    return total;
  }

  int get kembalianInfo {
    if (uangBayar.value < totalBayar) return 0;
    return uangBayar.value - totalBayar;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}