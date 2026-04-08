import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: const Color(0xFFF9F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- LOGO ---
              Center(
                child: Image.asset(
                  'assets/images/logo_nyebluck.png',
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "NYEBLUCK",
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // --- INPUT EMAIL ---
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2C2C), fontSize: 15),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailC,
                onChanged: (value) => setState(() {}), // Pantau perubahan teks
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Masukkan email Anda",
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF4A2C2C)),
                  filled: true,
                  fillColor: const Color(0xFFEBEBEB),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- INPUT PASSWORD ---
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2C2C), fontSize: 15),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passC,
                obscureText: isObscure,
                onChanged: (value) => setState(() {}), // Pantau perubahan teks
                decoration: InputDecoration(
                  hintText: "Masukkan password Anda",
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A2C2C)),
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => isObscure = !isObscure),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEBEBEB),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // --- TOMBOL MASUK ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  // Logika Validasi: Aktif jika tidak loading dan input tidak kosong
                  bool isInputValid = emailC.text.trim().isNotEmpty && passC.text.trim().isNotEmpty;
                  bool canClick = !authC.isLoading.value && isInputValid;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      disabledBackgroundColor: Colors.grey.shade400, // Warna saat terkunci
                      elevation: canClick ? 4 : 0,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: canClick 
                        ? () {
                            // 1. Simpan data sementara
                            final email = emailC.text.trim();
                            final pass = passC.text.trim();

                            // 2. Kosongkan kolom input langsung
                            emailC.clear();
                            passC.clear();
                            
                            // 3. Update UI agar tombol kembali abu-abu (disabled)
                            setState(() {}); 

                            // 4. Jalankan fungsi login
                            authC.login(email, pass);
                          }
                        : null, // Menjadi disabled jika input kosong
                    child: authC.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                            ],
                          ),
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }
}