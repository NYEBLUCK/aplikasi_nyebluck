import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/kasir_controller.dart';
import '../controllers/topping_controller.dart';

class PembayaranPage extends StatelessWidget {
  final kasirCtrl = Get.find<KasirController>();
  final toppingCtrl = Get.find<ToppingController>();

  PembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("PEMBAYARAN",
            style: GoogleFonts.poppins(
                color: const Color(0xFFC62828),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("NAMA PEMBELI"),
            TextField(
              onChanged: (v) => kasirCtrl.namaPembeli.value = v,
              decoration: InputDecoration(
                hintText: "Masukkan nama (opsional)",
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),
            
            _sectionLabel("PILIH LEVEL PEDAS"),
            _buildLevelPicker(),
            const SizedBox(height: 25),
            
            _buildOrderDetailCard(),
            const SizedBox(height: 25),
            
            // --- KOLOM TUNAI PERMANEN ---
            _sectionLabel("NOMINAL UANG DITERIMA (CASH)"),
            Obx(() => TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) {
                kasirCtrl.errorUangBayar.value = ""; 
                String cleanNumber = v.replaceAll(RegExp(r'[^0-9]'), '');
                kasirCtrl.uangBayar.value = int.tryParse(cleanNumber) ?? 0;
              },
              decoration: InputDecoration(
                hintText: "Contoh: 50000",
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                prefixText: "Rp ",
                errorText: kasirCtrl.errorUangBayar.value.isEmpty 
                    ? null 
                    : kasirCtrl.errorUangBayar.value, 
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            )),
            
            const SizedBox(height: 120), 
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildLevelPicker() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            bool isSelected = kasirCtrl.levelPedas.value == index;
            return GestureDetector(
              onTap: () => kasirCtrl.levelPedas.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFEBEBEB),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                      : [],
                ),
                child: Text("$index",
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87)),
              ),
            );
          }),
        ));
  }

  Widget _buildOrderDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFFC62828)),
              const SizedBox(width: 10),
              Text("Detail Pesanan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          
          Obx(() {
            if (kasirCtrl.cart.isEmpty) {
              return const Text("Keranjang Kosong");
            }
            return Column(
              children: kasirCtrl.cart.entries.map((entry) {
                final produk = toppingCtrl.allTopping.firstWhere((t) => t.id == entry.key);
                int qty = entry.value;
                int subtotalItem = produk.harga * qty;
                return _orderItem(produk.namaTopping, "${qty}x", "Rp $subtotalItem", produk.kategori ?? "Topping");
              }).toList(),
            );
          }),

          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
              Obx(() => Text("Rp ${kasirCtrl.totalBayar}",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900))),
            ],
          )
        ],
      ),
    );
  }

  Widget _orderItem(String title, String qty, String price, String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$title $qty", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text(category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(price, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOTAL BAYAR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              Obx(() => Text("Rp ${kasirCtrl.totalBayar}",
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEBEBEB),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("BATAL", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: kasirCtrl.isLoading.value ? null : () => kasirCtrl.prosesPembayaran(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: kasirCtrl.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("BAYAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}