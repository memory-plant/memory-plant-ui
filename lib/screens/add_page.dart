import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/providers/navigation_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:memory_plant_application/widgets/my_banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:memory_plant_application/widgets/date_diary_dialog.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // ValueNotifier를 사용하여 상태 변경을 최적화
  final ValueNotifier<DateTime> _focusedDay =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime?> _selectedDay =
      ValueNotifier<DateTime?>(DateTime.now());

  String? _getTitleForDate(DateTime day) {
    final memoryProvider =
        Provider.of<MemoryLogProvider>(context, listen: false);

    // 해당 날짜에 작성된 메모리 검색
    final memory = memoryProvider.memoryList.cast<MemoryLog?>().firstWhere(
      (m) {
        if (m == null || m.timestamp == null) return false;
        final memoryDate = DateTime.parse(m.timestamp!).toLocal();
        return memoryDate.year == day.year &&
            memoryDate.month == day.month &&
            memoryDate.day == day.day &&
            m.isUser == true; // 유저가 작성한 메모리만 포함
      },
      orElse: () => null, // 조건에 맞는 항목이 없을 때 null 반환
    );

    // 제목 반환
    return memory?.title;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 사용이 끝나면 ValueNotifier 해제
    _focusedDay.dispose();
    _selectedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKorean ? "기억발전소" : "Memory Plant",
          style: const TextStyle(
              fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.read<NavigationProvider>().updateIndex(0); // HomePage 인덱스
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyBannerAdWidget(),
          // 캘린더
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 8.0),
              child: ValueListenableBuilder<DateTime?>(
                valueListenable: _selectedDay,
                builder: (context, selectedDay, child) {
                  return TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay.value,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      _selectedDay.value = selectedDay;
                      _focusedDay.value = focusedDay;
                      //final diaries = _getDiariesForDate(selectedDay);
                      showDialog(
                        context: context,
                        builder: (context) =>
                            DateDiaryDialog(selectedDate: selectedDay),
                      );
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(),
                      todayTextStyle: const TextStyle(),
                      selectedDecoration: BoxDecoration(
                        color: AppStyles.maindeepblue.withValues(alpha: 0.77),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      defaultTextStyle: const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ),
                      weekendTextStyle: const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ),
                      holidayTextStyle: const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronVisible: true,
                      rightChevronVisible: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ), // 요일 텍스트 스타일
                      weekendStyle: TextStyle(
                        color: AppStyles.maindeepblue,
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                      ), // 주말 텍스트 스타일
                    ),
                    calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                      final title = _getTitleForDate(day);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 수직 정렬
                        children: [
                          Text(
                            day.day.toString(),
                            style: const TextStyle(
                              fontFamily: 'NanumFontSetup_TTF_SQUARE',
                            ),
                          ),
                          if (title != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0), // 텍스트와 날짜 사이 여백
                              child: Text(
                                title.length > 5
                                    ? title.substring(0, 5)
                                    : title, // 앞글자 개만 표시
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppStyles.maindeepblue,
                                  fontFamily: 'NanumFontSetup_TTF_SQUARE',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      );
                    }, markerBuilder: (context, day, events) {
                      // 검은 점 제거를 위해 빈 컨테이너 반환
                      return const SizedBox.shrink();
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
