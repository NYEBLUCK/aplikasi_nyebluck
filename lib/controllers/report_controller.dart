import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var transactions = <Map<String, dynamic>>[].obs;
  
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

  @override
  void onInit() {
    fetchReportData();
    super.onInit();
  }

  Future<void> fetchReportData() async {
    try {
      isLoading(true);
      
      var query = supabase.from('transactions').select('*, profiles(nama_lengkap)');

      if (startDate.value != null && endDate.value != null) {
        final startIso = DateTime(startDate.value!.year, startDate.value!.month, startDate.value!.day, 0, 0, 0).toUtc().toIso8601String();
        final endIso = DateTime(endDate.value!.year, endDate.value!.month, endDate.value!.day, 23, 59, 59).toUtc().toIso8601String();
        
        query = query.gte('created_at', startIso).lte('created_at', endIso);
      }

      final response = await query.order('created_at', ascending: true);
      
      transactions.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat laporan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchReportData(); 
  }

  void resetFilter() {
    startDate.value = null;
    endDate.value = null;
    fetchReportData(); 
  }

  int get jumlahTransaksi => transactions.length;

  int get totalPendapatan {
    return transactions.fold(0, (sum, item) => sum + (item['total_harga'] as int? ?? 0));
  }

  List<FlSpot> get chartSpots {
    if (transactions.isEmpty) return [];

    Map<String, int> dailyTotals = {};
    DateTime start;
    DateTime end;

    if (startDate.value != null && endDate.value != null) {
      start = startDate.value!;
      end = endDate.value!;
    } else {
      start = DateTime.parse(transactions.first['created_at']).toUtc().add(const Duration(hours: 8));
      end = DateTime.parse(transactions.last['created_at']).toUtc().add(const Duration(hours: 8));
      if (start.isAfter(end)) {
        final temp = start; start = end; end = temp;
      }
    }

    DateTime current = DateTime(start.year, start.month, start.day);
    DateTime last = DateTime(end.year, end.month, end.day);
    
    while (!current.isAfter(last)) {
      final key = DateFormat('yyyy-MM-dd').format(current);
      dailyTotals[key] = 0;
      current = current.add(const Duration(days: 1));
    }

    for (var tx in transactions) {
      final dateWita = DateTime.parse(tx['created_at']).toUtc().add(const Duration(hours: 8));
      final key = DateFormat('yyyy-MM-dd').format(dateWita);
      if (dailyTotals.containsKey(key)) {
        dailyTotals[key] = dailyTotals[key]! + (tx['total_harga'] as int? ?? 0);
      }
    }

    var sortedKeys = dailyTotals.keys.toList()..sort();
    
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyTotals[sortedKeys[i]]!.toDouble()));
    }

    if (spots.length == 1) {
      spots.add(FlSpot(1, spots.first.y));
    }

    return spots;
  }
}