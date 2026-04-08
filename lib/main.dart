import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/auth_controller.dart';
import 'controllers/topping_controller.dart';
import 'package:aplikasi_nyebluck/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  Get.put(AuthController(), permanent: true);
  Get.put(ToppingController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
      textTheme: GoogleFonts.poppinsTextTheme(),),
      title: 'NYEBLUCK',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}