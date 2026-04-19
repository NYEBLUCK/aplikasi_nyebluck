import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'login_page.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 1. Tambahkan SingleTickerProviderStateMixin untuk animasi
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  
  // Siapkan controller dan animasi
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 2. Konfigurasi Durasi Animasi Splash Screen (1.5 Detik)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animasi Muncul Perlahan (Fade)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    // Animasi Membesar & Sedikit Memantul (Scale & Bounce)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack, // Memberikan efek pantulan elegan
      ),
    );

    // Mulai animasi
    _animController.forward();

    // Menjalankan fungsi pindah halaman setelah 3 detik
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    
    // 3. Tambahkan efek transisi fadeIn agar mulus saat pindah ke LoginPage
    Get.offAll(
      () => const LoginPage(),
      transition: Transition.fadeIn, 
      duration: const Duration(milliseconds: 800), // Durasi transisi antar halaman
    );
  }

  @override
  void dispose() {
    // Bersihkan memori animasi saat pindah halaman
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bungkus Logo dengan Animasi Scale & Fade
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/nyebluckw.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'NYEBLUCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Bungkus Loading dengan Animasi Fade saja
            FadeTransition(
              opacity: _fadeAnimation,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}