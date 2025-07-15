import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/providers/navigation_provider.dart';
import 'package:memory_plant_application/screens/add_page.dart';
import 'package:memory_plant_application/screens/home_page.dart';
import 'chattingbot.dart';
import 'package:provider/provider.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  final appScreens = [
    const HomePage(),
    const AddPage(),
    const Chatbot(), // Chatbot 페이지는 자체 AppBar를 사용
  ];

  void _onItemTapped(int index) {
    context.read<NavigationProvider>().updateIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    return Scaffold(
      appBar: currentIndex == 1 ||
              currentIndex == 2 // addpage 랑 Chatbot 페이지에서는 AppBar를 숨김
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                isKorean ? "기억발전소" : "Memory Plant",
                style: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                    fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    FluentSystemIcons.ic_fluent_settings_regular,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/settingPage");
                  },
                ),
              ],
            ),
      body: appScreens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        selectedFontSize: 10, // 선택된 아이템의 글씨 크기 줄임
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_home_regular),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_home_filled),
            ),
            label: isKorean ? "저장소" : "Home",
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_add_regular),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_add_filled),
            ),
            label: isKorean ? "기록" : "Add",
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_chat_regular),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 12.0), // 아이콘 위에 12.0 만큼의 여백 추가
              child: Icon(FluentSystemIcons.ic_fluent_chat_filled),
            ),
            label: isKorean ? "면담" : "Chat",
          ),
        ],
      ),
    );
  }
}
