import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/pdf_service.dart';

class NotaPreviewPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;
  final List<dynamic> transactionItems;
  final String cashierName;

  const NotaPreviewPage({
    super.key,
    required this.transactionData,
    required this.transactionItems,
    required this.cashierName,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(transactionData['created_at']).toLocal();
    
    final String dateFormatted = DateFormat('dd/MM/yyyy').format(createdAt);
    
    final String timeFormatted = DateFormat('HH:mm:ss').format(createdAt);
    
    final String shortId = transactionData['id'].toString().replaceAll('-', '').substring(0, 16).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[200], 
      appBar: AppBar(
        centerTitle: true,
        title: Text("Preview Nota", style: GoogleFonts.poppins(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFC62828)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  width: 350, 
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.storefront, size: 50),
                            const SizedBox(height: 10),
                            const Text("NYEBLUCK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const Text("Jl. Jakarta Blok CT No.15, Samarinda", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            const Text("No. Telp 082152069178", style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                              child: Text(shortId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const _DashedDivider(),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateFormatted, style: const TextStyle(fontSize: 12)),
                          Text("Kasir : $cashierName", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(timeFormatted, style: const TextStyle(fontSize: 12)),
                          Text("${transactionData['nama_pembeli'] ?? 'Pelanggan'}", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("Level Pedas: ${transactionData['level_pedas']}", style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      const _DashedDivider(),
                      const SizedBox(height: 10),

                      ...transactionItems.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        var item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$index. ${item['topping_name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("   ${item['quantity']} x Rp ${item['price']}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                  Text("Rp ${item['quantity'] * item['price']}", style: const TextStyle(fontSize: 13)),
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 5),
                      const _DashedDivider(),
                      const SizedBox(height: 10),

                      Text("Total QTY : ${transactionData['total_quantity'] ?? '-'}", style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sub Total", style: TextStyle(fontSize: 13)),
                          Text("Rp ${transactionData['total_harga']}", style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("Rp ${transactionData['total_harga']}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bayar", style: TextStyle(fontSize: 13)),
                          Text("Rp ${transactionData['bayar'] ?? transactionData['total_harga']}", style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kembali", style: TextStyle(fontSize: 13)),
                          Text("Rp ${transactionData['kembalian'] ?? 0}", style: GoogleFonts.poppins(fontSize: 13)),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Center(child: Text("Terimakasih Telah Datang", style: TextStyle(fontSize: 13))),
                      const SizedBox(height: 15),
                      const Center(child: Text("Powered by Nyebluck", style: TextStyle(fontSize: 9, color: Colors.grey))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFFC62828),width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text("Kembali", style: GoogleFonts.poppins(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await PdfService.generateReceipt(
                        transaction: transactionData,
                        items: transactionItems,
                        cashierName: cashierName,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: Text("Cetak Nota", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
            );
          }),
        );
      },
    );
  }
}