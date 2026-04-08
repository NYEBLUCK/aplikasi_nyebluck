import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/topping_controller.dart';

class EditToppingPage extends StatefulWidget {
  const EditToppingPage({super.key});

  @override
  State<EditToppingPage> createState() => _EditToppingPageState();
}

class _EditToppingPageState extends State<EditToppingPage> {
  // Inisialisasi Controller
  final toppingC = Get.find<ToppingController>();

  // Mengambil data yang dikirim via Get.arguments
  final dynamic toppingData = Get.arguments;

  // Controller untuk Input Text
  late TextEditingController namaC;
  late TextEditingController hargaC;
  late TextEditingController stokC;

  // State untuk Validasi Error
  String? errorNama;
  String? errorHarga;
  String? errorStok;

  // State untuk Kategori dan Foto
  late String kategoriTerpilih;
  XFile? fotoBaru;
  Uint8List? webImage;

  @override
  void initState() {
    super.initState();
    // Isi otomatis field dengan data lama
    namaC = TextEditingController(text: toppingData.namaTopping);
    hargaC = TextEditingController(text: toppingData.harga.toString());
    stokC = TextEditingController(text: toppingData.stok.toString());
    kategoriTerpilih = toppingData.kategori;
  }

  // Fungsi ambil gambar
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
          fotoBaru = image;
        });
      } else {
        setState(() {
          fotoBaru = image;
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
          "Edit Topping",
          style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AREA PREVIEW FOTO ---
            Center(
              child: GestureDetector(
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
            const Text("Stok", style: TextStyle(fontWeight: FontWeight.bold)),
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

            // --- TOMBOL AKSI (SIMPAN & BATAL) ---
            Row(
              children: [
                // Tombol Simpan Perubahan
                Expanded(
                  flex: 2,
                  child: Obx(() => SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: toppingC.isLoading.value
                              ? null
                              : () {
                                  setState(() {
                                    errorNama = null;
                                    errorHarga = null;
                                    errorStok = null;
                                  });

                                  bool isInvalid = false;

                                  if (namaC.text.trim().isEmpty) {
                                    setState(() => errorNama = "Wajib diisi");
                                    isInvalid = true;
                                  }

                                  final hargaVal = int.tryParse(hargaC.text);
                                  if (hargaVal == null || hargaVal < 500) {
                                    setState(() => errorHarga = "Min Rp 500");
                                    isInvalid = true;
                                  }

                                  final stokVal = int.tryParse(stokC.text);
                                  if (stokVal == null) {
                                    setState(() => errorStok = "Wajib angka");
                                    isInvalid = true;
                                  }

                                  if (isInvalid) return;

                                  // Eksekusi Update ke Controller
                                  toppingC.updateTopping(
                                    toppingData.id,
                                    namaC.text.trim(),
                                    kategoriTerpilih,
                                    hargaVal!,
                                    stokVal!,
                                    toppingData.imageUrl,
                                    fotoBaru,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          child: toppingC.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.save, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Simpan Perubahan",
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )),
                ),
                
                const SizedBox(width: 10),

                // Tombol Batal
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8D6E63), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.close, color: Color(0xFF8D6E63), size: 20),
                          SizedBox(width: 4),
                          Text(
                            "Batal",
                            style: TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Logika untuk menampilkan gambar (Prioritas: Foto Baru > Foto Lama > Kosong)
  DecorationImage? _buildImageDecoration() {
  if (kIsWeb && webImage != null) {
    return DecorationImage(image: MemoryImage(webImage!), fit: BoxFit.cover);
  } else if (!kIsWeb && fotoBaru != null) {
    return DecorationImage(image: FileImage(File(fotoBaru!.path)), fit: BoxFit.cover);
  } 
  // GANTI .fotoUrl menjadi .imageUrl di bawah ini
  else if (toppingData.imageUrl != null && toppingData.imageUrl.isNotEmpty) {
    return DecorationImage(image: NetworkImage(toppingData.imageUrl), fit: BoxFit.cover);
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