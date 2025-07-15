import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:provider/provider.dart';

class ReadMemoryPage extends StatelessWidget {
  final MemoryLog memory;
  const ReadMemoryPage({super.key, required this.memory});

  String _formattedDate(BuildContext context, String? timestamp) {
    try {
      final isKorean =
          context.watch<LanguageProvider>().currentLanguage == Language.ko;

      if (timestamp == null) return isKorean ? "날짜 없음" : "No Date";

      final date = DateTime.parse(timestamp); // timestamp를 DateTime으로 변환
      final weekdaysKorean = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      final weekdaysEnglish = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];

      final weekday = date.weekday;

      if (isKorean) {
        return '${DateFormat('MM월 dd일').format(date)} ${weekdaysKorean[weekday - 1]}';
      } else {
        return '${weekdaysEnglish[weekday - 1]}, ${DateFormat('MMM dd').format(date)}';
      }
    } catch (e) {
      return context.watch<LanguageProvider>().currentLanguage == Language.ko
          ? "날짜 없음"
          : "No Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: memory.isUser!
            ? Text(
                _formattedDate(context, memory.timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              )
            : const Text(
                "Summary",
                style: TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                ),
              ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Text(
              memory.title ?? "",
              style: const TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 8),
            // 얇은 회색 선
            const Divider(
              color: Colors.grey, // 선 색상
              thickness: 0.5, // 선 두께
              height: 1, // 선의 높이
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  memory.contents ?? "",
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'NanumFontSetup_TTF_SQUARE',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
