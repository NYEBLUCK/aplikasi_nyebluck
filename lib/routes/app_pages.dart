// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// // --- IMPORT SEMUA UI LANGSUNG DARI FOLDER PAGES ---
// import 'package:aplikasi_nyebluck/pages/login_page.dart';
// // import '../pages/admin_dashboard_page.dart';
// import '../pages/topping_page.dart';
// import '../pages/add_topping_page.dart';
// // import '../pages/edit_topping_page.dart';
// // import '../pages/cashier_home_page.dart';

// // Import Middleware Tetap Dibutuhkan buat Keamanan
// import 'role_middleware.dart';

// class AdminMiddleware extends GetMiddleware {
//   @override
//   RouteSettings? redirect(String? route) {
//     final session = Supabase.instance.client.auth.currentSession;

//     // Jika tidak ada session (belum login), lempar ke Login
//     if (session == null) {
//       return const RouteSettings(name: Routes.LOGIN);
//     }

//     // Jika sudah login, izinkan masuk (null berarti lanjut ke halaman tujuan)
//     return null; 
//   }
// class Routes {
//   static const LOGIN = '/login';
//   static const ADMIN_DASHBOARD = '/admin-dashboard';
//   static const TOPPING = '/manage-topping';
//   static const ADD_TOPPING = '/add-topping';
//   static const EDIT_TOPPING = '/edit-topping';
//   static const CASHIER_HOME = '/cashier-home';
// }

// class AppPages {
//   static final pages = [
//     // 1. Login
//     GetPage(
//       name: Routes.LOGIN,
//       page: () => LoginPage(),
//     ),

//     GetPage(
//       name: Routes.TOPPING,
//       page: () => ToppingPage(),
//       middlewares: [AdminMiddleware()],
//     ),
//     GetPage(
//       name: Routes.ADD_TOPPING,
//       page: () => AddToppingPage(),
//       middlewares: [AdminMiddleware()],
//     ),
//     // GetPage(
//     //   name: Routes.EDIT_TOPPING,
//     //   page: () => EditToppingPage(),
//     //   middlewares: [AdminMiddleware()],
//     // ),

//     // // 3. Kasir
//     // GetPage(
//     //   name: Routes.CASHIER_HOME,
//     //   page: () => CashierHomePage(),
//     // ),
//   ];
// }