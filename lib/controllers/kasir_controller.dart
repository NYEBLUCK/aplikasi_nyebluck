import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'topping_controller.dart';
import '../pages/kasir_page.dart';
import '../pages/nota_preview_page.dart';

class KasirController extends GetxController {
  final supabase = Supabase.instance.client;
  final ToppingController toppingCtrl = Get.find<ToppingController>();

  var tabIndex = 0.obs;
  var isLoading = false.obs;

  var cart = <String, int>{}.obs; 
  var namaPembeli = "".obs;
  var levelPedas = 0.obs;
  var uangBayar = 0.obs; 
  var errorUangBayar = "".obs; 

  var historyToday = <Map<String, dynamic>>[].obs;

  void changeTab(int index) {
    tabIndex.value = index;
    if (index == 1) fetchHistoryToday();
  }

  void tambahKeKeranjang(String id) {
    try {
      var item = toppingCtrl.allTopping.firstWhere((t) => t.id == id);
      if (item.stok > 0 || item.takTerbatas) {
        cart[id] = (cart[id] ?? 0) + 1;
        
        if (!item.takTerbatas) item.stok--; 
        
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
      
      if (!item.takTerbatas) item.stok++; 
      
      toppingCtrl.allTopping.refresh();
      toppingCtrl.filteredTopping.refresh();
    }
  }

  Future<void> prosesPembayaran() async {
    if (cart.isEmpty) return;

    if (uangBayar.value == 0) {
      errorUangBayar.value = "Nominal uang tidak boleh kosong";
      return; 
    } else if (uangBayar.value < totalBayar) {
      errorUangBayar.value = "Uang kurang Rp ${totalBayar - uangBayar.value}";
      return; 
    }
    
    errorUangBayar.value = "";
    
    try {
      isLoading.value = true;

      final String? userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showFailedDialog("Sesi login berakhir. Silakan login ulang.");
        return;
      }

      int finalBayar = uangBayar.value;
      int finalKembalian = finalBayar - totalBayar;

      final transactionData = await supabase.from('transactions').insert({
        'cashier_id': userId,
        'nama_pembeli': namaPembeli.value.isEmpty ? "Pelanggan" : namaPembeli.value,
        'level_pedas': levelPedas.value,
        'total_harga': totalBayar,
        'total_quantity': totalItems, 
        'bayar': finalBayar,          
        'kembalian': finalKembalian,  
        'created_at': DateTime.now().toUtc().toIso8601String(), 
      }).select().single(); 

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
        
        if (!item.takTerbatas) {
          await supabase
              .from('toppings')
              .update({'stok': item.stok})
              .match({'id': id});
        }
      }

      final String kasirEmail = supabase.auth.currentUser?.email?.split('@')[0] ?? "Kasir";

      _showSuccessDialog(
        transactionData: transactionData,
        transactionItems: itemsToInsert,
        cashierName: kasirEmail,
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
    required Map<String, dynamic> transactionData,
    required List<dynamic> transactionItems,
    required String cashierName,
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
              Text("Pembayaran berhasil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Tutup dialog popup
                    
                    cart.clear();
                    namaPembeli.value = "";
                    levelPedas.value = 0;
                    uangBayar.value = 0;
                    errorUangBayar.value = ""; 
                    
                    Get.off(() => NotaPreviewPage(
                      transactionData: transactionData,
                      transactionItems: transactionItems,
                      cashierName: cashierName,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text("LANJUTKAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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

  void resetTransactionState() {
    cart.clear();
    namaPembeli.value = "";
    levelPedas.value = 0;
    uangBayar.value = 0;
    errorUangBayar.value = ""; 
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