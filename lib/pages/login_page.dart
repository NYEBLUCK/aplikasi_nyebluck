import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isObscure = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideLogoAnimation;
  late Animation<Offset> _slideCardAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _slideLogoAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _slideCardAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFC62828),
              child: Center(
                child: SlideTransition(
                  position: _slideLogoAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
            ),
          ),

          Expanded(
            flex: 7,
            child: SlideTransition(
              position: _slideCardAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40), 
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang!",
                              style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            Text(
                              "Silahkan Masuk ke Akun Anda",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("EMAIL",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: const Color(0xFFC62828))),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: emailC,
                                  hint: "chef@nyebluck.com",
                                  icon: Icons.email_outlined,
                                ),

                                const SizedBox(height: 25),

                                Text("PASSWORD",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: const Color(0xFFC62828))),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: passC,
                                  hint: "Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),

                                const SizedBox(height: 40),

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
                                          String email = emailC.text.trim();
                                          String password = passC.text.trim();

                                          emailC.clear();
                                          passC.clear();
                                          
                                          setState(() {});

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