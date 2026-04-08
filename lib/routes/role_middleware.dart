// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';

// class AdminMiddleware extends GetMiddleware {
//   @override
//   RouteSettings? redirect(String? route) {
//     // Ambil data dari AuthController yang sudah kita Get.put di main.dart
//     final authC = Get.find<AuthController>();

//     // CEK: Jika user bukan admin, tendang balik ke Login atau Kasir
//     if (authC.userRole.value != 'admin') {
//       Get.snackbar(
//         "Akses Ditolak", 
//         "Maaf, halaman ini hanya bisa dibuka oleh Admin NYEBLUCK!",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
      
//       // Jika dia kasir, biarkan dia di halaman kasir saja
//       return const RouteSettings(name: '/login');
//     }
    
//     // Jika dia admin, silakan lewat (return null)
//     return null;
//   }
// }