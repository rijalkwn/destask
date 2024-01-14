import 'package:destask/view/Beranda/Task/detail_task.dart';
import 'package:destask/view/Beranda/Task/kelola_task.dart';
import 'package:destask/view/Beranda/beranda.dart';
import 'package:destask/view/KPI/KPI.dart';
import 'package:destask/view/Menu/bottom_nav.dart';
import 'package:destask/view/Notifikasi/notifikasi.dart';
import 'package:destask/view/Pekerjaan/pekerjaan.dart';
import 'package:destask/view/Pengaturan/pengaturan.dart';
import 'package:destask/view/Pengaturan/profil.dart';
import 'package:destask/view/lo.dart';
import 'package:destask/view/login.dart';
import 'package:destask/view/lupa_password.dart';
import 'package:destask/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => BottomNav()),
        GetPage(name: '/bottomnav', page: () => BottomNav()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/lo', page: () => Lo()),
        GetPage(name: '/lupa_password', page: () => LupaPassword()),
        GetPage(name: '/beranda', page: () => Beranda()),
        GetPage(name: '/notifikasi', page: () => Notifikasi()),
        GetPage(name: '/detail_task', page: () => DetailTask()),
        GetPage(name: '/kelola_task', page: () => KelolaTask()),
        GetPage(name: '/pekerjaan', page: () => Pekerjaan()),
        GetPage(name: '/kpi', page: () => KPI()),
        GetPage(name: '/pengaturan', page: () => Pengaturan()),
        GetPage(name: '/edit_profil', page: () => Profil()),
      ],
      home: Splash(),
    );
  }
}
