import 'package:flutter/material.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:provider/provider.dart';

class SaveOptionDropdown extends StatefulWidget {
  final void Function(String) onOptionSelected;

  const SaveOptionDropdown({super.key, required this.onOptionSelected});

  @override
  State<SaveOptionDropdown> createState() => _SaveOptionDropdownState();
}

class _SaveOptionDropdownState extends State<SaveOptionDropdown> {
  String _selectedOption = 'summary'; // 기본 선택된 옵션

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;

    return IntrinsicWidth(
      child: Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.white, // 드롭다운 배경 흰색
            shape: RoundedRectangleBorder(
              side:
                  const BorderSide(color: Colors.grey, width: 0.3), // 회색 테두리 추가
              borderRadius: BorderRadius.circular(8), // 모서리 둥글게
            ),
          ),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 40), // 드롭다운 위치
          onSelected: (String selectedOption) {
            setState(() {
              _selectedOption = selectedOption; // 선택된 옵션 업데이트
            });
            widget.onOptionSelected(selectedOption); // 콜백 호출
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'summary',
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 왼쪽 아이콘과 오른쪽 체크 정렬
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppStyles.maindeepblue, size: 16), // 반짝이는 아이콘
                      const SizedBox(width: 8),
                      Text(
                        isKorean ? 'AI 요약' : 'AI summary',
                        style: const TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _selectedOption == 'summary'
                        ? Icons.check_circle
                        : null, // 선택된 경우 체크 아이콘 표시
                    color: AppStyles.maindeepblue,
                    size: 16,
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'memo',
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 왼쪽 텍스트와 오른쪽 체크 정렬
                children: [
                  Row(
                    children: [
                      const SizedBox(
                          width: 24), // 아이콘 자리 공간 확보 (아이콘 크기 + 간격 맞춤)
                      Text(
                        isKorean ? '메모만 저장' : 'Just memo',
                        style: const TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _selectedOption == 'memo'
                        ? Icons.check_circle
                        : null, // 선택된 경우 체크 아이콘 표시
                    color: AppStyles.maindeepblue,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  bottom: 8.0,
                ), // 상단에만 패딩
                child: Icon(Icons.expand_more, size: 20),
              ),
              SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
