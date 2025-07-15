import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:memory_plant_application/screens/write_page.dart';
import 'package:memory_plant_application/screens/read_memory_page.dart';
import 'package:memory_plant_application/screens/edit_memory_page.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:intl/intl.dart';

class DateDiaryDialog extends StatelessWidget {
  final DateTime selectedDate;

  const DateDiaryDialog({
    super.key,
    required this.selectedDate,
  });

  // ✅ 오늘 또는 과거 날짜인지 판별하는 함수
  bool _isPastOrTodayDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isBefore(today) || selected.isAtSameMomentAs(today);
  }

  // ✅ Provider를 통해 해당 날짜의 일기를 필터링하는 함수
  List<MemoryLog> _getDiariesForDate(BuildContext context) {
    final memoryProvider = Provider.of<MemoryLogProvider>(context, listen: false);
    return memoryProvider.memoryList.where((memory) {
      if (memory.timestamp == null) return false;
      final memoryDate = DateTime.parse(memory.timestamp!).toLocal();
      return memoryDate.year == selectedDate.year &&
          memoryDate.month == selectedDate.month &&
          memoryDate.day == selectedDate.day;
    }).toList();
  }

  // ✅ 날짜를 'THURSDAY - Jan 9' 형식으로 변환하는 함수
  String _formatDate(DateTime date) {
    return DateFormat('EEEE - MMM d').format(date);
  }

  // ✅ 공통적으로 사용되는 아이콘 버튼 위젯
  Widget _getIconButton(Color color, IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: color,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaries = _getDiariesForDate(context);
    final isKorean = context.watch<LanguageProvider>().currentLanguage == Language.ko;
    final bool isPastOrToday = _isPastOrTodayDate(selectedDate); // ✅ 오늘 또는 과거인지 확인

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        width: 350, // ✅ 너비 고정
        constraints: const BoxConstraints(minHeight: 300, maxHeight: 500), // ✅ 크기 조절 가능
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ 다이얼로그 크기를 내용에 맞게 조정
          children: [
            // ✅ 날짜 표시 (예: 'THURSDAY - Jan 9')
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(
                _formatDate(selectedDate),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_Extra_Bold',
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // ✅ 리스트가 많아도 스크롤 되도록 조정
            Expanded(
              child: diaries.isNotEmpty
                  ? ListView.builder(
                itemCount: diaries.length,
                itemBuilder: (context, index) {
                  final diary = diaries[index];
                  return SwipeActionCell(
                    key: Key(diary.timestamp ?? DateTime.now().toString()),
                    trailingActions: [
                      // ✅ 삭제 버튼
                      SwipeAction(
                        color: Colors.transparent,
                        nestedAction: SwipeNestedAction(
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red,
                            ),
                            width: 130,
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              isKorean ? "삭제 확인" : "Confirm Delete",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NanumFontSetup_TTF_SQUARE_Extra_Bold',
                              ),
                            ),
                          ),
                        ),
                        content: _getIconButton(Colors.red, Icons.delete),
                        onTap: (handler) async {
                          context.read<MemoryLogProvider>().deleteMemory(diary);
                          handler(false);
                        },
                      ),
                      // ✅ 수정 버튼
                      SwipeAction(
                        color: Colors.transparent,
                        content: _getIconButton(Colors.grey, Icons.edit),
                        onTap: (handler) async {
                          handler(false);
                          final updatedDiary = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMemoryPage(memory: diary),
                            ),
                          );
                          if (updatedDiary != null && updatedDiary is MemoryLog) {
                            if(context.mounted){
                              context.read<MemoryLogProvider>().editMemory(diary, updatedDiary);
                            }
                          }
                        },
                      ),
                    ],
                    child: Card(
                      color: const Color(0xFFDDEFFF),   //불가피하게.. 이러케 진행
                      elevation: 0.0, // ✅ 그림자 제거
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadMemoryPage(memory: diary),
                            ),
                          );
                        },
                        title: Text(
                          diary.title ?? "No Title",
                          style: const TextStyle(
                            fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          diary.contents ?? "No Content",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'NanumFontSetup_TTF_SQUARE',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  isPastOrToday
                      ? (isKorean ? "오늘의 일기를 작성해 보세요." : "Take a moment to reflect on your day")
                      : (isKorean ? "계획을 작성해보세요." : "Plan your day ahead"),
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                  ),
                ),
              ),
            ),

            // ✅ 버튼이 항상 하단에 고정
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
              child: IconButton(
                icon: Icon(
                  Icons.library_add,
                  size: 30.0,
                  color: AppStyles.textColor.withValues(alpha: 0.25),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WritePage(selectedDay: selectedDate),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
