import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:provider/provider.dart';

class EditMemoryPage extends StatefulWidget {
  final MemoryLog memory;
  const EditMemoryPage({super.key, required this.memory});

  @override
  State<EditMemoryPage> createState() => _EditMemoryPageState();
}

class _EditMemoryPageState extends State<EditMemoryPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaveEnabled = false; // 저장 활성화 여부

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory.title);
    _contentController = TextEditingController(text: widget.memory.contents);
    // 제목과 내용 변경 상태를 감지
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
    // 현재 제목과 내용이 초기 값과 다른지 확인
    final isContentChanged = _titleController.text != widget.memory.title ||
        _contentController.text != widget.memory.contents;

    // 제목 또는 내용이 비어 있지 않고, 내용이 수정되었는지 확인
    setState(() {
      _isSaveEnabled = isContentChanged &&
          (_titleController.text.isNotEmpty ||
              _contentController.text.isNotEmpty);
    });
  }

  String _formatDate(String? timestamp) {
    // timestamp가 null인 경우 현재 날짜를 기본값으로 사용
    final date = timestamp != null ? DateTime.parse(timestamp) : DateTime.now();
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
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

    final weekday = date.weekday; // 날짜의 요일 계산

    if (isKorean) {
      return '${DateFormat('MM월 dd일').format(date)} ${weekdaysKorean[weekday - 1]}';
    } else {
      return '${weekdaysEnglish[weekday - 1]}, ${DateFormat('MMM dd').format(date)}';
    }
  }

  void _saveChanges() {
    setState(() {
      widget.memory.title = _titleController.text;
      widget.memory.contents = _contentController.text;
    });

    Navigator.pop(context, widget.memory); // 수정된 메모리 데이터를 반환
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _formatDate(widget.memory.timestamp),
          style: const TextStyle(
            fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaveEnabled
                ? _saveChanges // 저장 버튼 활성화
                : null, // 비활성화
            child: Text(
              isKorean ? "저장" : "Save",
              style: TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                color: _isSaveEnabled ? Colors.black : Colors.grey, // 비활성화 시 회색
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: isKorean ? "제목" : "Title", // 힌트 텍스트 추가
                border: InputBorder.none,
                hintStyle: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                    color: Colors.grey),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 1,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'NanumFontSetup_TTF_SQUARE'),
                decoration: InputDecoration(
                  hintText: isKorean
                      ? "내용을 입력하세요."
                      : "Write the content.", // 힌트 텍스트 추가
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                      fontFamily: 'NanumFontSetup_TTF_SQUARE',
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
