import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/screens/editname_page.dart';
import 'package:memory_plant_application/widgets/language.dart';
import 'package:memory_plant_application/screens/learning_page.dart';
import 'package:memory_plant_application/widgets/my_banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/providers/name_provider.dart';
import 'package:memory_plant_application/screens/privacy_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void _showEditNameDialog(String currentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNamePage(
          currentName: currentName,
          onNameSaved: (newName) {
            final nameProvider =
                Provider.of<NameProvider>(context, listen: false);
            nameProvider.updateName(newName); // 새로운 이름 저장
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    final nameProvider = Provider.of<NameProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          top: 0.0, // 상단 패딩 줄임
          bottom: 8.0, // 하단 패딩 줄임
          left: 16.0, // 기존 가로 패딩 유지
          right: 16.0, // 기존 가로 패딩 유지
        ),
        children: [
          // 상단 Settings 제목
          Text(
            isKorean ? '설정' : 'Settings',
            style: const TextStyle(
              fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
              fontSize: 32, // 큰 폰트 크기
            ),
          ),
          MyBannerAdWidget(),
          const SizedBox(height: 8),
          // Account Section
          _buildSectionTitle(isKorean ? "계정" : "Account"),

          ListTile(
            leading: const Icon(
              Icons.person, // 공장을 나타내는 아이콘
            ),
            title: Text(
              isKorean ? "계정 관리" : "My Account",
              style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold', fontSize: 14),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showEditNameDialog(nameProvider.name);
            },
          ),
          const Divider(
            color: Colors.grey,
          ),

          // Notifications Section
          _buildSectionTitle(isKorean ? "언어" : "language"),

          const ListTile(
            leading: Icon(
              Icons.language, // 언어 아이콘 추가
            ),
            title: Text(
              "ENG/KOR",
              style: TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold', fontSize: 14),
            ),
            trailing: LanguageToggleSwitch(),
          ),
          const Divider(
            color: Colors.grey,
          ),

          // More Section
          _buildSectionTitle(isKorean ? "더 보기" : "More"),
          ListTile(
            leading: const Icon(
              Icons.business, // 공장을 나타내는 아이콘
            ),
            title: Text(
              isKorean ? "센터에 대해 배우기" : "Learn About Centers",
              style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold', fontSize: 14),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.security,
            ),
            title: Text(
              isKorean ? "이용약관" : "Privacy Policy",
              style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold', fontSize: 14),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold', fontSize: 16),
      ),
    );
  }
}
