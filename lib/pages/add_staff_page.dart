import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String? errorNama;
  String? errorEmail;
  String? errorTelp;
  String? errorAlamat;
  String? errorPass;

  bool isObscure = true;

  void validasiDanSimpan() async{
    setState(() {
      errorNama = null;
      errorEmail = null;
      errorTelp = null;
      errorAlamat = null;
      errorPass = null;
    });

    bool isInvalid = false;

    if (namaC.text.trim().isEmpty) {
      setState(() => errorNama = "Nama lengkap wajib diisi");
      isInvalid = true;
    }
    // 2. Validasi Email
    if (emailC.text.trim().isEmpty) {
      setState(() => errorEmail = "Email wajib diisi");
      isInvalid = true;
    } else if (!GetUtils.isEmail(emailC.text.trim())) {
      setState(() => errorEmail = "Format email tidak valid");
      isInvalid = true;
    } else {
      staffC.isLoading(true);
      // Pastikan di Controller namanya sudah: cekEmailTersedia
      bool tersedia = await staffC.cekEmailTersedia(emailC.text.trim());
      staffC.isLoading(false);

      if (!mounted) return;

      if (!tersedia) {
        setState(() => errorEmail = "Email sudah terdaftar");
        isInvalid = true;
      }
    }

    // 3. Validasi Nomor Telepon (10-13 Karakter)
    String telp = telpC.text.trim();
    if (telp.isEmpty) {
      setState(() => errorTelp = "Nomor telepon wajib diisi");
      isInvalid = true;
    } else if (telp.length < 10 || telp.length > 13) {
      setState(() => errorTelp = "Nomor telepon harus 10-13 digit");
      isInvalid = true;
    }

    // 4. Validasi Alamat
    if (alamatC.text.trim().isEmpty) {
      setState(() => errorAlamat = "Alamat wajib diisi");
      isInvalid = true;
    }

    // 5. Validasi Password
    if (passC.text.trim().isEmpty) {
      setState(() => errorPass = "Password wajib diisi");
      isInvalid = true;
    } else if (passC.text.trim().length < 8) {
      setState(() => errorPass = "Password minimal 8 karakter");
      isInvalid = true;
    }
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC62828)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Tambah Akun",
          style: GoogleFonts.poppins(
            color: const Color(0xFFC62828),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nama Lengkap"),
              _buildTextField(
                hint: "Contoh: Deni Pradana",
                controller: namaC,
                icon: Icons.person,
                errorText: errorNama,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    // Logika mengubah "deni pradana" -> "Deni Pradana"
                    String capitalized = value.split(' ').map((word) {
                      if (word.isEmpty) return "";
                      return word[0].toUpperCase() + word.substring(1).toLowerCase();
                    }).join(' ');

                    // Update controller dan jaga posisi kursor agar tidak pindah ke depan
                    if (value != capitalized) {
                      namaC.value = namaC.value.copyWith(
                        text: capitalized,
                        selection: TextSelection.collapsed(offset: capitalized.length),
                      );
                    }
                  }
                },
              ),
            const SizedBox(height: 20),
            _buildLabel("Email"),
            _buildTextField(
              hint: "staff@nyembluck.id",
              controller: emailC,
              icon: Icons.email,
              errorText: errorEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildLabel("Nomor Telepon"),
            _buildTextField(
              hint: "0812 XXXX XXXX",
              controller: telpC,
              icon: Icons.phone,
              errorText: errorTelp,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildLabel("Alamat Lengkap"),
            _buildTextField(
              hint: "Masukkan alamat tinggal staff saat ini...",
              controller: alamatC,
              icon: Icons.location_on,
              errorText: errorAlamat,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildLabel("Password"),
            _buildPasswordField(errorText: errorPass),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // MENGGUNAKAN BOTTOM NAVIGATION BAR AGAR TIDAK IKUT SCROLL
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
        child: Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: staffC.isLoading.value ? null : validasiDanSimpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  elevation: 5,
                  shadowColor: const Color(0xFFC62828).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: staffC.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "Buat Akun",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
  required String hint,
  required TextEditingController controller,
  required IconData icon,
  String? errorText,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  Function(String)? onChanged, // Tambahkan ini
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged, // Pasang di sini
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint,
      errorText: errorText,
      suffixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

  Widget _buildPasswordField({String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: passC,
          obscureText: isObscure,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Masukkan Password Staff",
            errorText: errorText,
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => setState(() => isObscure = !isObscure),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "MINIMAL 8 KARAKTER DENGAN KOMBINASI ANGKA",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
