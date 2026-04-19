import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/topping_controller.dart';

class AddToppingPage extends StatefulWidget {
  const AddToppingPage({super.key});

  @override
  State<AddToppingPage> createState() => _AddToppingPageState();
}

class _AddToppingPageState extends State<AddToppingPage> {
  final toppingC = Get.find<ToppingController>();

  final namaC = TextEditingController();
  final hargaC = TextEditingController();
  final stokC = TextEditingController();

  String? errorNama;
  String? errorHarga;
  String? errorStok;

  String kategoriTerpilih = "Kering"; 
  bool isTakTerbatas = false; 
  XFile? fotoProduk;
  Uint8List? webImage;

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

  // --- FUNGSI HAPUS FOTO YANG DIPILIH ---
  void hapusPilihanFoto() {
    setState(() {
      fotoProduk = null;
      webImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool adaFoto = (fotoProduk != null || webImage != null);

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC62828)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Tambah Topping",
          style: GoogleFonts.poppins(color: const Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack( // Ubah GestureDetector jadi Stack
                          children: [
                            GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                                  image: _buildImageDecoration(),
                                ),
                                child: (!adaFoto)
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
                                          const SizedBox(height: 5),
                                          Text("AMBIL FOTO", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                            
                            // Tombol Edit (Pensil)
                            Positioned(
                              bottom: 0, // Disesuaikan agar pas di pojok
                              right: 0,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC62828),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ),

                            // --- BARU: Tombol Hapus (Sampah) - Muncul jika ada foto ---
                            if (adaFoto)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: hapusPilihanFoto,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFC62828).withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                    ),
                                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Unggah foto topping",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    children: [
                      Container(width: 5, height: 25, decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(width: 10),
                      Text("Informasi Topping", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),

                  const SizedBox(height: 25),
                  _buildLabel("Nama Topping"),
                  _buildTextField(namaC, "Masukkan nama topping", errorNama, (v) => setState(() => errorNama = null)),

                  const SizedBox(height: 20),
                  _buildLabel("Kategori"),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["Kering", "Frozen", "Minuman"].map((kat) {
                        bool isSelected = kategoriTerpilih == kat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(kat),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => kategoriTerpilih = kat);
                            },
                            selectedColor: const Color(0xFFC62828),
                            backgroundColor: const Color(0xFFEBEBEB),
                            labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            side: BorderSide.none,
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Harga Jual"),
                  _buildTextField(
                    hargaC, 
                    "0", 
                    errorHarga, 
                    (v) => setState(() => errorHarga = null), 
                    prefix: "Rp" 
                  ),

                  const SizedBox(height: 20),
                  
                  _buildLabel("Status Stok"),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("Terbatas", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          value: false,
                          groupValue: isTakTerbatas,
                          activeColor: const Color(0xFFC62828),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => isTakTerbatas = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("Tak Terbatas", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          value: true,
                          groupValue: isTakTerbatas,
                          activeColor: const Color(0xFFC62828),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() {
                            isTakTerbatas = val!;
                            stokC.clear(); 
                            errorStok = null;
                          }),
                        ),
                      ),
                    ],
                  ),

                  if (!isTakTerbatas) ...[
                    const SizedBox(height: 10),
                    _buildLabel("Stok Awal"),
                    _buildTextField(stokC, "0", errorStok, (v) => setState(() => errorStok = null), suffix: "Pcs"),
                  ],
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Obx(() => ElevatedButton.icon(
                  onPressed: toppingC.isLoading.value ? null : _validateAndSave,
                  icon: toppingC.isLoading.value 
                      ? const SizedBox.shrink() 
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: toppingC.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: const Color(0xFFC62828).withOpacity(0.4),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildTextField(
  TextEditingController controller, 
  String hint, 
  String? error, 
  Function(String)? onChanged, 
  {String? prefix, String? suffix}
) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: prefix != null || suffix != null ? TextInputType.number : TextInputType.text,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    decoration: InputDecoration(
      hintText: hint,
      errorText: error,
      prefixIcon: prefix != null 
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 12), 
              child: Text(
                prefix, 
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC62828), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16
                ),
              ),
            ) 
          : (suffix != null 
              ? const SizedBox(width: 15) 
              : null),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

      suffixIcon: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 15, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    suffix,
                    style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(
        vertical: 18, 
        horizontal: (prefix == null && suffix == null) ? 20 : 0,
      ),
    ),
  );
}

  void _validateAndSave() async {
    setState(() {
      errorNama = null;
      errorHarga = null;
      errorStok = null;
    });

    bool isInvalid = false;

    String namaInput = namaC.text.trim().replaceAll('<', '').replaceAll('>', '');

    if (namaInput.isEmpty) {
      setState(() => errorNama = "Nama topping tidak boleh kosong");
      isInvalid = true;
    } else if (toppingC.isNamaDuplikat(namaInput, excludeId: null)) { 
      setState(() => errorNama = "Nama topping sudah ada, gunakan nama lain");
      isInvalid = true;
    }

    final hargaVal = int.tryParse(hargaC.text);
    if (hargaVal == null || hargaVal < 500) {
      setState(() => errorHarga = "Minimal Rp. 500");
      isInvalid = true;
    }

    int stokAkhir = 0;
    if (!isTakTerbatas) {
      final stokVal = int.tryParse(stokC.text);
      if (stokVal == null) {
        setState(() => errorStok = "Wajib diisi angka");
        isInvalid = true;
      } else if (stokVal < 0) { 
        setState(() => errorStok = "Stok tidak boleh minus");
        isInvalid = true;
      } else {
        stokAkhir = stokVal;
      }
    }

    if (isInvalid) return;

    await toppingC.simpanTopping(
      namaInput,
      kategoriTerpilih,
      hargaVal!,
      stokAkhir, 
      isTakTerbatas, 
      fotoProduk,
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
}