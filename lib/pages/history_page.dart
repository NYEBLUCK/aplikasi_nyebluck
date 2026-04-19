import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/kasir_controller.dart';
import 'nota_preview_page.dart'; 

class HistoryPage extends StatelessWidget {
  final KasirController kasirCtrl = Get.find<KasirController>();

  HistoryPage({super.key}) {
    // Memastikan data terbaru diambil saat halaman dibuka
    kasirCtrl.fetchHistoryToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          // --- HEADER INFO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Urutkan: Terbaru ke Terlama",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // --- LIST TRANSAKSI ---
          Expanded(
            child: Obx(() {
              if (kasirCtrl.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB71C1C)));
              }

              if (kasirCtrl.historyToday.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => kasirCtrl.fetchHistoryToday(),
                color: const Color(0xFFB71C1C),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: kasirCtrl.historyToday.length,
                  itemBuilder: (context, index) {
                    final data = kasirCtrl.historyToday[index];
                    return _buildTransactionCard(data);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD RIWAYAT ---
  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final DateTime createdAt = DateTime.parse(data['created_at']).toLocal();
    final String timeFormatted = DateFormat('HH:mm').format(createdAt);

    // Memastikan format ID tidak error jika ID terlalu pendek
    final String uuidSegment = data['id'].toString().split('-').first.toUpperCase();
    final String invoiceId = "INV/${createdAt.year}/$uuidSegment";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoiceId,
                style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "SELESAI",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Hari ini, $timeFormatted",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rp ${data['total_harga']}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        // 1. Tampilkan loading spinner sementara data diambil
                        Get.dialog(
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFB71C1C))),
                          barrierDismissible: false,
                        );

                        // 2. Ambil detail item dari tabel transaction_items berdasarkan ID transaksi
                        final itemsResponse = await kasirCtrl.supabase
                            .from('transaction_items')
                            .select()
                            .eq('transaction_id', data['id']);

                        // 3. Tutup loading dialog setelah data didapat
                        Get.back();

                        // 4. Ambil informasi nama/email kasir
                        final String kasirEmail = kasirCtrl.supabase.auth.currentUser?.email?.split('@')[0] ?? "Kasir";

                        // 5. Buka Halaman Preview Nota
                        Get.to(() => NotaPreviewPage(
                          transactionData: data,
                          transactionItems: itemsResponse,
                          cashierName: kasirEmail,
                        ));
                        
                      } catch (e) {
                        if (Get.isDialogOpen ?? false) Get.back();
                        Get.snackbar("Gagal", "Tidak dapat memuat nota: $e",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text("Lihat Nota",
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          const Text(
            "Mencapai Akhir Riwayat",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          const Text(
            "Semua transaksi hari ini telah ditampilkan.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}