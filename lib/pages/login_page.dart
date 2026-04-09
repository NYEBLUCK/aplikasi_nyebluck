import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      body: Column(
        children: [
          // --- BAGIAN ATAS (LOGO) ---
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFC62828),
              child: Center(
                child: Image.asset(
                  'assets/images/nyebluckw.png',
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    "NYEBLUCK",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          // --- BAGIAN BAWAH (FORM) ---
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40), // Padding atas untuk kontainer putih
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER TEXT (STATIK - TIDAK IKUT SCROLL) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello!",
                          style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        Text(
                          "Welcome back to the heat.",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // --- FORM SECTION (SCROLLABLE) ---
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // EMAIL ADDRESS
                            Text("EMAIL ADDRESS",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: const Color(0xFFC62828))),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: emailC,
                              hint: "chef@nyembluck.com",
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 25),

                            // PASSWORD
                            Text("PASSWORD",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: const Color(0xFFC62828))),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: passC,
                              hint: "••••••••",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 40),

                            // BUTTON LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: Obx(() {
                                bool canClick = !authC.isLoading.value &&
                                    emailC.text.isNotEmpty &&
                                    passC.text.isNotEmpty;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC62828),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    elevation: 5,
                                  ),
                                  onPressed: canClick
                                  ? () {
                                      // 1. Ambil data sebelum dikosongkan
                                      String email = emailC.text.trim();
                                      String password = passC.text.trim();

                                      // 2. Langsung kosongkan textfield
                                      emailC.clear();
                                      passC.clear();
                                      
                                      // 3. Trigger state update untuk menonaktifkan tombol kembali (karena field kosong)
                                      setState(() {});

                                      // 4. Jalankan fungsi login
                                      authC.login(email, password);
                                    }
                                  : null,
                                  child: authC.isLoading.value
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Login",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.arrow_forward,
                                                color: Colors.white, size: 24),
                                          ],
                                        ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isObscure : false,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black45, size: 24),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black45,
                    size: 24),
                onPressed: () => setState(() => isObscure = !isObscure),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFEBEBEB),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }
}