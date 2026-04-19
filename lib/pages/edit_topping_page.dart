import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/topping_controller.dart';

class EditToppingPage extends StatefulWidget {
  const EditToppingPage({super.key});

  @override
  State<EditToppingPage> createState() => _EditToppingPageState();
}

class _EditToppingPageState extends State<EditToppingPage> {
  final toppingC = Get.find<ToppingController>();
  final dynamic toppingData = Get.arguments;

  late TextEditingController namaC;
  late TextEditingController hargaC;
  late TextEditingController stokC;

  String? errorNama;
  String? errorHarga;
  String? errorStok;

  late String kategoriTerpilih;
  late bool isTakTerbatas; 
  XFile? fotoBaru;
  Uint8List? webImage;

  // --- BARU: State untuk menandai user ingin menghapus foto LAMA yang ada di DB ---
  bool hapusFotoLamaTakTersimpan = false;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: toppingData.namaTopping);
    hargaC = TextEditingController(text: toppingData.harga.toString());
    stokC = TextEditingController(text: toppingData.stok.toString());
    kategoriTerpilih = toppingData.kategori;
    isTakTerbatas = toppingData.takTerbatas; 
  }

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
          // Jika pilih foto baru, batalkan niat hapus foto lama (jika ada)
          hapusFotoLamaTakTersimpan = false; 
        });
      } else {
        setState(() {
          fotoBaru = image;
          // Jika pilih foto baru, batalkan niat hapus foto lama (jika ada)
          hapusFotoLamaTakTersimpan = false;
        });
      }
    }
  }

  // --- FUNGSI LOGIKA TOMBOL SAMPAH ---
  void aksiTombolHapus() {
    setState(() {
      if (fotoBaru != null || webImage != null) {
        // Kondisi A: User sedang preview foto BARU, lalu dihapus (kembali ke kondisi awal)
        fotoBaru = null;
        webImage = null;
      } else if (toppingData.imageUrl != null && !hapusFotoLamaTakTersimpan) {
        // Kondisi B: User sedang melihat foto LAMA (dari DB), lalu menekan hapus
        // Kita tandai untuk dihapus saat simpan nanti
        hapusFotoLamaTakTersimpan = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logika menampilkan tombol sampah
    bool adaFotoBaru = (fotoBaru != null || webImage != null);
    bool adaFotoLamaDiDB = (toppingData.imageUrl != null && toppingData.imageUrl.isNotEmpty);
    
    // Tombol sampah muncul jika: Ada foto baru terpilih OR (Ada foto lama DAN belum ditandai hapus)
    bool tampilkanTombolHapus = adaFotoBaru || (adaFotoLamaDiDB && !hapusFotoLamaTakTersimpan);

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
          "Edit Topping",
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
                    child: Stack( // Ubah GestureDetector jadi Stack
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBEBEB),
                              borderRadius: BorderRadius.circular(20),
                              image: _buildImageDecoration(),
                            ),
                            child: _buildPlaceholder(),
                          ),
                        ),

                        // Tombol Edit (Pensil)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),

                        // --- BARU: Tombol Hapus (Sampah) - Muncul sesuai logika ---
                        if (tampilkanTombolHapus)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: aksiTombolHapus,
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
                  _buildTextField(namaC, "Nama Topping", errorNama, (v) => setState(() => errorNama = null)),

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
                  _buildTextField(hargaC, "0", errorHarga, (v) => setState(() => errorHarga = null), prefix: "Rp"),

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
                          title: Text("Tak Terbatas", style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFFC62828), size: 18),
                    label: Text("Batal", style: GoogleFonts.poppins(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC62828), width: 2),
                      backgroundColor: const Color(0xFFEBEBEB),
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: toppingC.isLoading.value ? null : _validateAndUpdate,
                    icon: toppingC.isLoading.value ? const SizedBox.shrink() : const Icon(Icons.save_rounded, color: Colors.white),
                    label: toppingC.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      shadowColor: const Color(0xFFC62828).withOpacity(0.4),
                    ),
                  )),
                ),
              ],
            ),
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

  Widget _buildTextField(TextEditingController controller, String hint, String? error, Function(String)? onChanged, {String? prefix, String? suffix}) {
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
                child: Text(prefix, style: GoogleFonts.poppins(color: const Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 16)),
              ) 
            : (suffix != null ? const SizedBox(width: 12) : null),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 15, left: 8),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(suffix, style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFEBEBEB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: (prefix == null && suffix == null) ? 20 : 0),
      ),
    );
  }

  Widget? _buildPlaceholder() {
    // Priority 1: Sedang preview foto baru terpilih
    if (webImage != null || fotoBaru != null) return null;

    // Priority 2: Sedang preview foto lama dari DB (dan belum ditandai hapus)
    if (toppingData.imageUrl != null && toppingData.imageUrl.isNotEmpty && !hapusFotoLamaTakTersimpan) return null;

    // Priority 3: Tidak ada foto sama sekali (atau foto lama sudah ditandai hapus) -> Tampilkan placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
        const SizedBox(height: 5),
        const Text("AMBIL FOTO", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  DecorationImage? _buildImageDecoration() {
    // Priority 1: Tampilkan foto BARU terpilih (Web atau Mobile)
    if (kIsWeb && webImage != null) {
      return DecorationImage(image: MemoryImage(webImage!), fit: BoxFit.cover);
    } else if (!kIsWeb && fotoBaru != null) {
      return DecorationImage(image: FileImage(File(fotoBaru!.path)), fit: BoxFit.cover);
    } 
    // Priority 2: Tampilkan foto LAMA dari DB (jika user TIDAK menandai hapus)
    else if (toppingData.imageUrl != null && toppingData.imageUrl.isNotEmpty && !hapusFotoLamaTakTersimpan) {
      return DecorationImage(image: NetworkImage(toppingData.imageUrl), fit: BoxFit.cover);
    }
    // Priority 3: Placeholder (kembalikan null agar warna background Container terlihat)
    return null;
  }

  void _validateAndUpdate() async { 
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
    } 
    else if (toppingC.isNamaDuplikat(namaInput, excludeId: toppingData.id)) {
      setState(() => errorNama = "Nama topping sudah ada, gunakan nama lain");
      isInvalid = true;
    }

    final hargaVal = int.tryParse(hargaC.text);
    if (hargaVal == null || hargaVal < 500) {
      setState(() => errorHarga = "Min Rp 500");
      isInvalid = true;
    }

    int stokAkhir = 0;
    if (!isTakTerbatas) {
      final stokVal = int.tryParse(stokC.text);
      if (stokVal == null) {
        setState(() => errorStok = "Wajib angka");
        isInvalid = true;
      } else if (stokVal < 0) { 
        setState(() => errorStok = "Stok tidak boleh minus");
        isInvalid = true;
      } else {
        stokAkhir = stokVal;
      }
    }

    if (isInvalid) return;

    await toppingC.updateTopping(
      toppingData.id,
      namaInput,
      kategoriTerpilih,
      hargaVal!,
      stokAkhir, 
      isTakTerbatas, 
      toppingData.imageUrl,
      fotoBaru,
      hapusFotoLamaTakTersimpan, // Kirim state hapus foto lama ke controller
    );
  }
}