import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateReceipt({
    required Map<String, dynamic> transaction,
    required List<dynamic> items,
    required String cashierName,
  }) async {
    
    // --- 1. DEFINISIKAN FONT ICON DI SINI ---
    final iconFont = await PdfGoogleFonts.materialIcons();
    // ----------------------------------------

    final pdf = pw.Document();

    // Format Tanggal & Waktu
    final DateTime createdAt = DateTime.parse(transaction['created_at']).toLocal();
    final String dateFormatted = DateFormat('yyyy-MM-dd').format(createdAt);
    final String timeFormatted = DateFormat('HH:mm:ss').format(createdAt);
    
    // Potong ID agar tidak terlalu panjang (menyerupai struk asil)
    final String shortId = transaction['id'].toString().replaceAll('-', '').substring(0, 16).toUpperCase();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(children: [
                  // 2. GUNAKAN FONT ICON YANG SUDAH DIDEFINISIKAN
                  pw.Icon(
                    const pw.IconData(0xe8d1), 
                    font: iconFont, // Sekarang tidak akan error lagi
                    size: 40
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text("NYEBLUCK", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Jl. Alamat Nyebluck No.19", textAlign: pw.TextAlign.center),
                  pw.Text("Samarinda", textAlign: pw.TextAlign.center),
                  pw.Text("No. Telp 0812345678"),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                    child: pw.Text(shortId),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                ]),
              ),

              // --- INFO TRANSAKSI ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(dateFormatted),
                  pw.Text(cashierName),
                ]
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(timeFormatted),
                  pw.Text(transaction['nama_pembeli'] ?? "Pelanggan"),
                ]
              ),
              pw.SizedBox(height: 5),
              pw.Text("Metode: ${transaction['metode'].toString().toUpperCase()} - Lvl: ${transaction['level_pedas']}"),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // --- DAFTAR BARANG ---
              pw.SizedBox(height: 5),
              ...items.asMap().entries.map((entry) {
                int index = entry.key + 1;
                var item = entry.value;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("$index. ${item['topping_name']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("   ${item['quantity']} x ${item['price']}"),
                          pw.Text("Rp ${item['quantity'] * item['price']}"),
                        ]
                      )
                    ]
                  )
                );
              }),
              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // --- TOTAL & PEMBAYARAN ---
              pw.SizedBox(height: 5),
              pw.Text("Total QTY : ${transaction['total_quantity'] ?? '-'}"),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Sub Total"),
                  pw.Text("Rp ${transaction['total_harga']}"),
                ]
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text("Rp ${transaction['total_harga']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ]
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Bayar (${transaction['metode'].toString().toUpperCase()})"),
                  pw.Text("Rp ${transaction['bayar'] ?? transaction['total_harga']}"),
                ]
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Kembali"),
                  pw.Text("Rp ${transaction['kembalian'] ?? 0}"),
                ]
              ),

              // --- FOOTER ---
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("Terimakasih Telah Berbelanja")),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text("Powered by Nyebluck System", style: const pw.TextStyle(fontSize: 8))),
            ],
          );
        },
      ),
    );

    // Ini akan membuka dialog preview PDF di HP, user bisa pilih simpan ke PDF atau print Bluetooth
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}