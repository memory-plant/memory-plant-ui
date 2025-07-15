import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:memory_plant_application/providers/navigation_provider.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/services/groq_service.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:memory_plant_application/widgets/save_option.dart';
import 'package:provider/provider.dart';

class WritePage extends StatefulWidget {
  final DateTime selectedDay;
  const WritePage({super.key, required this.selectedDay});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSaveEnabled = false; // 저장 활성화 이거 추가
  final CohereService _cohereService = CohereService();
  bool _isLoading = false;
  String _selectedOption = 'summary'; // 기본 선택된 옵션

  @override
  void initState() {
    super.initState();
    // 제목과 내용 입력 상태를 감지
    _titleController.addListener(_updateSaveButtonState);
    _contentController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateSaveButtonState() {
    // 제목과 내용이 둘 다 비어있지 않으면 저장 활성화
    setState(() {
      _isSaveEnabled = _titleController.text.isNotEmpty ||
          _contentController.text.isNotEmpty;
    });
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<void> addMemory(bool isKorean) async {
    try {
      final newMemory = MemoryLog(
          title: _titleController.text,
          contents: _contentController.text,
          timestamp: widget.selectedDay.toString().substring(0, 10),
          isUser: true // 작성 페이지에서 쓴 글은 무조건 isUser 가 true
          );
      context.read<MemoryLogProvider>().addMemory(newMemory);
      if (_selectedOption == 'summary') {
        setState(() {
          _isLoading = true;
        });
        final botResponse =
            await _cohereService.sendMemory(_titleController.text, _contentController.text);
        final monthSummaryTitle = isKorean
            ? '${widget.selectedDay.year}년 ${widget.selectedDay.month}월의 기억 요약'
            : 'Summary of Memories in ${_getMonthAbbreviation(widget.selectedDay.month)} ${widget.selectedDay.year}';

        if (mounted) {
          context.read<MemoryLogProvider>().updateOrCreateMonthlySummary(
              monthSummaryTitle, botResponse, widget.selectedDay.toString());
        }
        setState(() {
          _isLoading = false;
        });
      }

      if (mounted) {
        context.read<NavigationProvider>().updateIndex(0); // HomePage 인덱스
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKorean
                ? "네트워크 연결상태를 확인하세요"
                : "Please check your network connection"),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  String formattedDate(BuildContext context, bool isKorean) {
    final day = widget.selectedDay.day;
    final month = widget.selectedDay.month;
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
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekday = widget.selectedDay.weekday;
    return isKorean
        ? '$month월 $day일 ${weekdaysKorean[weekday - 1]}'
        : '${weekdaysEnglish[weekday - 1]}, ${monthNames[month - 1]} $day';
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 그림자 제거
        title: Text(
          formattedDate(context, isKorean),
          style: const TextStyle(
            fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
          ),
        ),
        centerTitle: true,
        actions: [
          SaveOptionDropdown(
            onOptionSelected: (String selectedOption) {
              setState(() {
                _selectedOption = selectedOption; // 선택된 옵션 상태 업데이트
              });
            },
          ),
          TextButton(
            onPressed: _isSaveEnabled && !_isLoading
                ? () async {
                    await addMemory(isKorean);
                  }
                : null, //활성화 되지 않은 상태에서는 null 처리
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트 사이의 간격 최소화
                    children: [
                      const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
                      Text(
                        isKorean ? "저장" : "Save",
                        style: TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                          color: _isSaveEnabled
                              ? AppStyles.maindeepblue
                              : Colors.grey, // 비활성화 시 회색
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 아이템 왼쪽 정렬
          children: [
            TextField(
              maxLength: 500,
              controller: _titleController,
              style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                  fontSize: 21),
              decoration: InputDecoration(
                counterText: '', // 글자 수 카운트 제거
                hintText: isKorean ? "제목" : "Title.",
                border: InputBorder.none, // 밑줄 제거
                hintStyle: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                    color: Colors.grey),
              ),
            ),
            // 얇은 회색 선
            const Divider(
              color: Colors.grey, // 선 색상
              thickness: 0.5, // 선 두께
              height: 1, // 선의 높이
            ),
            const SizedBox(height: 8), // 선과 내용 사이 간격
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE', fontSize: 16),
                decoration: InputDecoration(
                  hintText: isKorean ? "내용을 입력하세요." : "Write the content.",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                      fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                      color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
