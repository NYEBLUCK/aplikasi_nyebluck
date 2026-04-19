import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/kasir_controller.dart';
import 'nota_preview_page.dart'; 

class HistoryPage extends StatelessWidget {
  final KasirController kasirCtrl = Get.find<KasirController>();

  HistoryPage({super.key}) {
    kasirCtrl.fetchHistoryToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
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

          Expanded(
            child: Obx(() {
              if (kasirCtrl.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC62828)));
              }

              if (kasirCtrl.historyToday.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => kasirCtrl.fetchHistoryToday(),
                color: const Color(0xFFC62828),
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

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final DateTime createdAt = DateTime.parse(data['created_at']).toLocal();
    final String timeFormatted = DateFormat('HH:mm').format(createdAt);
    final String uuidSegment = data['id'].toString().split('-').first.toUpperCase();
    final String invoiceId = "INV/${createdAt.year}/$uuidSegment";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                    color: Color(0xFFC62828),
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        Get.dialog(
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFC62828))),
                          barrierDismissible: false,
                        );

                        final itemsResponse = await kasirCtrl.supabase
                            .from('transaction_items')
                            .select()
                            .eq('transaction_id', data['id']);

                        Get.back();

                        final String kasirEmail = kasirCtrl.supabase.auth.currentUser?.email?.split('@')[0] ?? "Kasir";

                        Get.to(
                          () => NotaPreviewPage(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text("Lihat Nota",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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