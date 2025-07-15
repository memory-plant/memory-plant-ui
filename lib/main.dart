import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_plant_application/providers/chatbot_provider.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:memory_plant_application/styles/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/screens/bottom_nav_page.dart';
import 'package:memory_plant_application/screens/setting_page.dart';
import 'package:memory_plant_application/screens/start_page.dart';
import 'package:memory_plant_application/screens/start_page_after_login.dart';
import 'package:memory_plant_application/providers/navigation_provider.dart'; // NavigationProvider import
import 'package:memory_plant_application/providers/name_provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  User? user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자 확인

  WidgetsFlutterBinding.ensureInitialized(); // 광고 ads mobile
  unawaited(MobileAds.instance.initialize());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 세로 모드
    DeviceOrientation.portraitDown, // 세로 모드 (거꾸로)
  ]).then((_) {
    runApp(MyApp(user: user));
  });
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => MemoryLogProvider()),
        ChangeNotifierProvider(create: (_) => NameProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
            create: (_) => ChatProvider()), // ChatbotProvider 추가
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // 시스템에 맞는 테마
        theme: AppTheme.lightTheme, // lightTheme 적용
        darkTheme: AppTheme.darkTheme, // darkTheme 적용
        routes: {
          "/": (context) => user != null
              ? const StartPageAfterLogin() // 로그인 상태이면 StartPageAfterLogin
              : const StartPage(), // 로그인 상태가 아니면 StartPage
          "/startPage": (context) => const StartPage(),
          "/startPageAfterLogin": (context) => const StartPageAfterLogin(),
          "/bottomNavPage": (context) => const BottomNavPage(),
          "/settingPage": (context) => const SettingPage(),
        },
      ),
    );
  }
}
