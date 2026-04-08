import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/topping_controller.dart';

class AddToppingPage extends StatefulWidget {
  const AddToppingPage({super.key});

  @override
  State<AddToppingPage> createState() => _AddToppingPageState();
}

class _AddToppingPageState extends State<AddToppingPage> {
  // Inisialisasi Controller
  final toppingC = Get.find<ToppingController>();

  // Controller untuk Input Text
  final namaC = TextEditingController();
  final hargaC = TextEditingController();
  final stokC = TextEditingController();

  // State untuk Validasi Error
  String? errorNama;
  String? errorHarga;
  String? errorStok;

  // State untuk Kategori dan Foto
  String kategoriTerpilih = "Kering";
  XFile? fotoProduk;
  Uint8List? webImage;

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      if (kIsWeb) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          fotoProduk = image;
        });
      } else {
        setState(() {
          fotoProduk = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Tambah Topping",
          style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AREA UPLOAD FOTO ---
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                            image: _buildImageDecoration(),
                          ),
                          child: (fotoProduk == null && webImage == null)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
                                    Text("AMBIL FOTO", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Unggah foto topping untuk memudahkan identifikasi dapur",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- INFORMASI TOPPING ---
            Row(
              children: [
                Container(width: 4, height: 20, color: const Color(0xFFC62828)),
                const SizedBox(width: 8),
                const Text("Informasi Topping", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Nama Topping", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: namaC,
              onChanged: (val) => setState(() => errorNama = null),
              decoration: InputDecoration(
                hintText: "Contoh: Kerupuk Mawar Pedas",
                errorText: errorNama,
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ["Kering", "Frozen", "Minuman"].map((kat) {
                bool isSelected = kategoriTerpilih == kat;
                return ChoiceChip(
                  label: Text(kat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => kategoriTerpilih = kat);
                  },
                  selectedColor: const Color(0xFFC62828),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text("Harga Jual", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: hargaC,
              onChanged: (val) => setState(() => errorHarga = null),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "Rp ",
                errorText: errorHarga,
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Stok Awal", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: stokC,
              onChanged: (val) => setState(() => errorStok = null),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: "Pcs",
                errorText: errorStok,
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: toppingC.isLoading.value
                        ? null
                        : () {
                            // 1. Reset State Error
                            setState(() {
                              errorNama = null;
                              errorHarga = null;
                              errorStok = null;
                            });

                            bool isInvalid = false;

                            // 2. Validasi & Auto-TitleCase Nama
                            if (namaC.text.isEmpty) {
                              setState(() => errorNama = "Nama topping wajib diisi");
                              isInvalid = true;
                            } else {
                              String input = namaC.text.trim();
                              // Bakso -> Bakso | bakso -> Bakso
                              String formattedNama = input[0].toUpperCase() + input.substring(1).toLowerCase();
                              namaC.text = formattedNama;

                              // Cek Duplikat di listTopping controller
                              bool isExist = toppingC.allTopping.any((t) => t.namaTopping.toLowerCase() == formattedNama.toLowerCase());
                              if (isExist) {
                                setState(() => errorNama = "Nama topping sudah ada");
                                isInvalid = true;
                              }
                            }

                            // 3. Validasi Harga (Min 500 & Angka)
                            final hargaVal = int.tryParse(hargaC.text);
                            if (hargaVal == null) {
                              setState(() => errorHarga = "Harga wajib diisi angka");
                              isInvalid = true;
                            } else if (hargaVal < 500) {
                              setState(() => errorHarga = "Harga minimal Rp. 500");
                              isInvalid = true;
                            }

                            // 4. Validasi Stok
                            final stokVal = int.tryParse(stokC.text);
                            if (stokVal == null) {
                              setState(() => errorStok = "Stok wajib diisi angka");
                              isInvalid = true;
                            }

                            // Berhenti jika ada yang invalid
                            if (isInvalid) return;

                            // 5. Eksekusi Simpan
                            toppingC.simpanTopping(
                              namaC.text,
                              kategoriTerpilih,
                              hargaVal!,
                              stokVal!,
                              fotoProduk,
                            );
                          },
                    icon: toppingC.isLoading.value
                        ? const SizedBox.shrink()
                        : const Icon(Icons.save, color: Colors.white),
                    label: toppingC.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Simpan Topping",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                    ),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  DecorationImage? _buildImageDecoration() {
    if (kIsWeb && webImage != null) {
      return DecorationImage(image: MemoryImage(webImage!), fit: BoxFit.cover);
    } else if (!kIsWeb && fotoProduk != null) {
      return DecorationImage(image: FileImage(File(fotoProduk!.path)), fit: BoxFit.cover);
    }
    return null;
  }

  @override
  void dispose() {
    namaC.dispose();
    hargaC.dispose();
    stokC.dispose();
    super.dispose();
  }
}