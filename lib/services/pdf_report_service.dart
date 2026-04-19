import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<void> generateReport({
    required List<Map<String, dynamic>> transactions,
    required DateTime? startDate,
    required DateTime? endDate,
    required int totalPendapatan,
  }) async {
    
    // --- 1. DOWNLOAD FONT POPPINS UNTUK PDF ---
    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    // Terapkan font sebagai tema dasar dokumen PDF
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      ),
    );

    String periode = "Keseluruhan Waktu";
    if (startDate != null && endDate != null) {
      // Menggunakan Format Indonesia DD/MM/YYYY
      periode = "${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}";
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return [
            // --- HEADER ---
            pw.Text("NYEBLUCK", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
            pw.Text("Laporan Penjualan", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Periode: $periode", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 20),

            // --- SUMMARY CARDS ---
            pw.Row(
              children: [
                pw.Expanded(child: _buildSummaryCard("Total Transaksi", "${transactions.length} Transaksi")),
                pw.SizedBox(width: 15),
                pw.Expanded(child: _buildSummaryCard("Total Pendapatan", "Rp $totalPendapatan")),
              ]
            ),
            pw.SizedBox(height: 30),

            // --- TABLE DATA (KOLOM METODE DIHAPUS) ---
            pw.Text("Detail Transaksi", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            pw.TableHelper.fromTextArray(
              headers: ['Kode', 'Waktu (WITA)', 'Kasir', 'Total (Rp)'],
              // Lebar kolom disesuaikan karena hanya sisa 4 kolom
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5), // Kode Transaksi
                1: const pw.FlexColumnWidth(2.5), // Waktu
                2: const pw.FlexColumnWidth(2.5), // Nama Kasir
                3: const pw.FlexColumnWidth(2.0), // Total Harga
              },
              data: transactions.map((tx) {
                // Pastikan Konversi ke WITA (UTC+8)
                final dateWita = DateTime.parse(tx['created_at']).toUtc().add(const Duration(hours: 8));
                final waktuStr = DateFormat('dd/MM/yy, HH:mm').format(dateWita);
                
                // Ambil Kode Pendek
                final shortId = tx['id'].toString().split('-').first.toUpperCase();
                
                // Ambil Nama Kasir (Atasi jika null)
                final namaKasir = tx['profiles']?['nama_lengkap'] ?? 'Kasir';

                return [
                  shortId,
                  waktuStr,
                  namaKasir,
                  tx['total_harga'].toString(), // Data metode sudah dihapus
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight, // Total ditaruh rata kanan
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildSummaryCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10))
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        ]
      )
    );
  }
}