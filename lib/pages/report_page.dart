import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/report_controller.dart';
import '../services/pdf_report_service.dart';

class ReportPage extends StatelessWidget {
  final ReportController reportC = Get.put(ReportController());

  ReportPage({super.key});

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023), // Tanggal berdirinya Nyebluck
      lastDate: DateTime.now(), // MENCEGAH memilih tanggal/bulan depan yang belum dilewati
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC62828), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      reportC.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      body: Obx(() {
        if (reportC.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
        }

        return RefreshIndicator(
          onRefresh: () => reportC.fetchReportData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Laporan Penjualan", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // --- CARD FILTER TANGGAL ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text("Pilih Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      InkWell(
                        onTap: () => _pilihTanggal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                reportC.startDate.value == null 
                                    ? "Tampilkan Semua Waktu" 
                                    : "${DateFormat('dd/MM/yyyy').format(reportC.startDate.value!)}  -  ${DateFormat('dd/MM/yyyy').format(reportC.endDate.value!)}",
                                style: GoogleFonts.poppins(color: reportC.startDate.value == null ? Colors.grey : Colors.black87, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => _pilihTanggal(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text("Filter Laporan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (reportC.startDate.value != null) 
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () => reportC.resetFilter(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Semua", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- TOMBOL CETAK PDF ---
                ElevatedButton.icon(
                  onPressed: reportC.transactions.isEmpty ? null : () {
                    PdfReportService.generateReport(
                      transactions: reportC.transactions,
                      startDate: reportC.startDate.value,
                      endDate: reportC.endDate.value,
                      totalPendapatan: reportC.totalPendapatan,
                    );
                  },
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: Text("Cetak Laporan PDF", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),

                // --- SUMMARY CARDS ---
                _buildSummaryCard("Jumlah Transaksi", "${reportC.jumlahTransaksi} Transaksi", Icons.receipt_long, "Total keseluruhan"),
                const SizedBox(height: 15),
                _buildSummaryCard("Total Pendapatan", "Rp ${reportC.totalPendapatan}", Icons.payments_outlined, "Pendapatan kotor"),
                const SizedBox(height: 25),

                // --- CHART TREN PENDAPATAN ---
                if (reportC.transactions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tren\nPendapatan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 10, color: Color(0xFFC62828)),
                                const SizedBox(width: 5),
                                Text("Pendapatan", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 150,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false), 
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) => Colors.black87, // Warna background pop-up
                                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      // 1. Ambil tanggal awal dari data atau dari filter
                                      DateTime start;
                                      DateTime end;
                                      if (reportC.startDate.value != null && reportC.endDate.value != null) {
                                        start = reportC.startDate.value!;
                                        end = reportC.endDate.value!;
                                      } else {
                                        start = DateTime.parse(reportC.transactions.first['created_at']).toUtc().add(const Duration(hours: 8));
                                        end = DateTime.parse(reportC.transactions.last['created_at']).toUtc().add(const Duration(hours: 8));
                                      }
                                      // Pastikan tanggal start adalah yang paling awal
                                      if (start.isAfter(end)) start = end; 
                                      
                                      // 2. Hitung tanggal berdasarkan posisi titik X (0, 1, 2...)
                                      DateTime spotDate = start.add(Duration(days: spot.x.toInt()));
                                      String dateLabel = DateFormat('dd/MM/yyyy').format(spotDate);
                                      
                                      // 3. Tampilkan Tanggal dan Nominal
                                      return LineTooltipItem(
                                        '$dateLabel\n',
                                        const TextStyle(color: Colors.white70, fontSize: 10), // Style untuk tanggal
                                        children: [
                                          TextSpan(
                                            text: 'Rp ${spot.y.toInt()}',
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), // Style untuk Nominal
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: reportC.chartSpots,
                                  isCurved: true,
                                  color: const Color(0xFFC62828),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFFC62828).withOpacity(0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // --- DETAIL TRANSAKSI TERBARU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detail Transaksi Terbaru", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),

                ...reportC.transactions.reversed.take(10).map((tx) {
                  // PASTI KE WITA & Format Indonesia (Hari Bulan Tahun)
                  final dateWita = DateTime.parse(tx['created_at']).toUtc().add(const Duration(hours: 8));
                  final dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(dateWita);
                  
                  final shortId = tx['id'].toString().split('-').first.toUpperCase();
                  final namaKasir = tx['profiles']?['nama_lengkap'] ?? 'Kasir';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("INV/$shortId", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text("$dateStr WITA", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("Oleh: $namaKasir", style: GoogleFonts.poppins(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Rp ${tx['total_harga']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tx['metode'] == 'qris' ? Colors.amber : Colors.green[100],
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Text(tx['metode'].toString().toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: tx['metode'] == 'qris' ? Colors.black87 : Colors.green[800])),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          Icon(icon, size: 40, color: Colors.grey[300]),
        ],
      ),
    );
  }
}