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

  String kategoriTerpilih = "Kering"; // Sesuai desain default chip merah
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background bersih sesuai desain
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
          style: GoogleFonts.poppins(color: Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: 18),
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
                  // --- AREA UPLOAD FOTO ---
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                                  image: _buildImageDecoration(),
                                ),
                                child: (fotoProduk == null && webImage == null)
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
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC62828),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Unggah foto topping untuk memudahkan identifikasi dapur",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- SECTION TITLE ---
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
                    "0", // Hint tetap 0 jika kosong
                    errorHarga, 
                    (v) => setState(() => errorHarga = null), 
                    prefix: "Rp" // Prefix akan otomatis muncul permanen
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Stok Awal"),
                  _buildTextField(stokC, "0", errorStok, (v) => setState(() => errorStok = null), suffix: "Pcs"),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // --- FIXED BOTTOM BUTTON ---
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
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
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
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    decoration: InputDecoration(
      hintText: hint,
      errorText: error,
      
      // Jika ada Rp (prefix), tampilkan. 
      // Jika tidak ada Rp tapi ini input angka (ada suffix), kasih jarak dikit (width: 15).
      prefixIcon: prefix != null 
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 12), 
              child: Text(
                prefix, 
                style: GoogleFonts.poppins(
                  color: Color(0xFFC62828), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16
                ),
              ),
            ) 
          : (suffix != null 
              ? const SizedBox(width: 15) // Jarak sedikit saja dari pinggir kiri
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
        // Nama Topping (tanpa prefix/suffix) tetap pakai 20 agar rapi
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
  String namaInput = namaC.text.trim();

  // 1. Validasi Kosong
  if (namaInput.isEmpty) {
    setState(() => errorNama = "Nama topping tidak boleh kosong");
    isInvalid = true;
  } 
  // 2. Validasi Nama Duplikat (Ganti snackbar jadi error text field)
  // Jika sedang EDIT, masukkan ID toppingnya ke excludeId
  else if (toppingC.isNamaDuplikat(namaInput, excludeId: null)) { 
    setState(() => errorNama = "Nama topping sudah ada, gunakan nama lain");
    isInvalid = true;
  }

  final hargaVal = int.tryParse(hargaC.text);
  if (hargaVal == null || hargaVal < 500) {
    setState(() => errorHarga = "Minimal Rp. 500");
    isInvalid = true;
  }

  final stokVal = int.tryParse(stokC.text);
  if (stokVal == null) {
    setState(() => errorStok = "Wajib diisi angka");
    isInvalid = true;
  } else if (stokVal < -1) { 
    // --- BARIS BARU UNTUK MENCEGAH MINUS SELAIN -1 ---
    setState(() => errorStok = "Gunakan -1 untuk Unlimited");
    isInvalid = true;
  }

  if (isInvalid) return;
  // Jalankan proses simpan jika valid
  await toppingC.simpanTopping(
    namaInput,
    kategoriTerpilih,
    hargaVal!,
    stokVal!,
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