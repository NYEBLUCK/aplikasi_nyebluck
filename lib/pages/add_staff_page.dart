import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_controller.dart';

class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final staffC = Get.find<StaffController>();

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final telpC = TextEditingController();
  final alamatC = TextEditingController();
  final passC = TextEditingController();

  // Variabel untuk menampung pesan error
  String? errorNama;
  String? errorEmail;
  String? errorTelp;
  String? errorAlamat;
  String? errorPass;

  bool isObscure = true;

  // Fungsi Validasi Utama
  void validasiDanSimpan() {
    setState(() {
      // Reset semua error sebelum pengecekan
      errorNama = null;
      errorEmail = null;
      errorTelp = null;
      errorAlamat = null;
      errorPass = null;
    });

    bool isInvalid = false;

    // 1. Validasi Nama (Hanya huruf & spasi, minimal 3 karakter)
    if (namaC.text.isEmpty) {
      setState(() => errorNama = "Nama lengkap wajib diisi");
      isInvalid = true;
    } else if (namaC.text.length < 3) {
      setState(() => errorNama = "Nama minimal 3 huruf");
      isInvalid = true;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(namaC.text)) {
      setState(() => errorNama = "Nama hanya boleh berisi huruf");
      isInvalid = true;
    }

    // 2. Validasi Email (Format email standard)
    if (emailC.text.isEmpty) {
      setState(() => errorEmail = "Email wajib diisi");
      isInvalid = true;
    } else if (!GetUtils.isEmail(emailC.text)) {
      setState(() => errorEmail = "Format email tidak valid");
      isInvalid = true;
    }

    // 3. Validasi Nomor Telepon (Hanya angka, 10-13 digit)
    if (telpC.text.isEmpty) {
      setState(() => errorTelp = "Nomor telepon wajib diisi");
      isInvalid = true;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(telpC.text)) {
      setState(() => errorTelp = "Nomor telepon harus berupa angka");
      isInvalid = true;
    } else if (telpC.text.length < 10 || telpC.text.length > 13) {
      setState(() => errorTelp = "Nomor telepon tidak valid (10-13 digit)");
      isInvalid = true;
    }

    // 4. Validasi Alamat (Minimal 5 karakter)
    if (alamatC.text.isEmpty) {
      setState(() => errorAlamat = "Alamat wajib diisi");
      isInvalid = true;
    } else if (alamatC.text.length < 5) {
      setState(() => errorAlamat = "Alamat lengkap minimal 5 karakter");
      isInvalid = true;
    }

    // 5. Validasi Password (Min 8 karakter, dilarang emoji)
    if (passC.text.isEmpty) {
      setState(() => errorPass = "Password wajib diisi");
      isInvalid = true;
    } else if (passC.text.length < 8) {
      setState(() => errorPass = "Password minimal 8 karakter");
      isInvalid = true;
    } else if (RegExp(
            r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
            unicode: true)
        .hasMatch(passC.text)) {
      setState(() => errorPass = "Password tidak boleh mengandung emoji");
      isInvalid = true;
    }

    // Eksekusi jika semua validasi lolos
    if (!isInvalid) {
      staffC.simpanStaff(
        namaC.text,
        emailC.text,
        telpC.text,
        alamatC.text,
        passC.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Tambah Akun Pekerja",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              label: "Nama Lengkap",
              hint: "Contoh: Budi Santoso",
              controller: namaC,
              icon: Icons.person,
              errorText: errorNama,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: "Email",
              hint: "staff@nyembluck.id",
              controller: emailC,
              icon: Icons.email,
              errorText: errorEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: "Nomor Telepon",
              hint: "0812 XXXX XXXX",
              controller: telpC,
              icon: Icons.phone,
              errorText: errorTelp,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: "Alamat Lengkap",
              hint: "Masukkan alamat tinggal staff saat ini...",
              controller: alamatC,
              icon: Icons.location_on,
              errorText: errorAlamat,
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            _buildPasswordField(errorText: errorPass),
            const SizedBox(height: 35),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: staffC.isLoading.value ? null : validasiDanSimpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: staffC.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Buat Akun",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Text Input
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            errorText: errorText, // Menampilkan pesan error otomatis
            prefixIcon: maxLines > 1 ? null : Icon(icon, color: Colors.grey),
            suffixIcon: maxLines > 1 ? Icon(icon, color: Colors.grey) : null,
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Password Input
  Widget _buildPasswordField({String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passC,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: "••••••••••••••",
            errorText: errorText,
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => isObscure = !isObscure),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
        if (errorText == null) // Tampilkan keterangan hanya jika tidak ada error
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "MINIMAL 8 KARAKTER DENGAN KOMBINASI ANGKA",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}