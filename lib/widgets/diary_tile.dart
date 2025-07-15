import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/screens/edit_memory_page.dart';
import 'package:memory_plant_application/screens/read_memory_page.dart';
import 'package:memory_plant_application/services/memory_log.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:intl/intl.dart';

class DiaryTile extends StatelessWidget {
  final MemoryLog memory;
  final int index;

  const DiaryTile({
    super.key,
    required this.memory,
    required this.index,
  });

  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp); // timestamp를 DateTime으로 변환
    return DateFormat('MM/dd').format(date); // MM/dd 형식으로 변환
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // MemoryDetailPage로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadMemoryPage(memory: memory),
              ),
            );
          },
          child: SwipeActionCell(
            key: Key(memory.timestamp!),
            trailingActions: [
              // 삭제 버튼
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                        Flexible(
                          // 텍스트가 공간을 초과하지 않도록 설정
                          child: Text(
                            isKorean ? '삭제 확인' : 'Confirm Delete',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // 텍스트가 한 줄을 초과하지 않도록 설정
                            overflow: TextOverflow.ellipsis, // 초과 시 말줄임 처리
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                content: _getIconButton(Colors.red, Icons.delete),
                onTap: (handler) async {
                  context.read<MemoryLogProvider>().deleteMemory(memory);

                  handler(false); // 액션 완료
                },
              ),
              // 수정 버튼
              SwipeAction(
                color: Colors.transparent,
                content: _getIconButton(Colors.grey, Icons.edit),
                onTap: (handler) async {
                  handler(false);
                  final oldMemory = MemoryLog(
                    title: memory.title,
                    contents: memory.contents,
                    timestamp: memory.timestamp,
                    isUser: memory.isUser,
                  );
                  final updatedMemory = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMemoryPage(memory: memory),
                    ),
                  );

                  if (updatedMemory != null && updatedMemory is MemoryLog) {
                    if (context.mounted) {
                      context
                          .read<MemoryLogProvider>()
                          .editMemory(oldMemory, updatedMemory);
                    }
                  }
                },
              ),
            ],
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!memory.isUser!) // memory.isUser == false일 때만 아이콘 추가
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 0.0), // 아이콘 위치 조정
                      child: Icon(
                        Icons.auto_awesome, // 원하는 아이콘 선택
                        color: AppStyles.maindeepblue, // 아이콘 색상
                        size: 16, // 아이콘 크기
                      ),
                    ),
                  Expanded(
                    // 나머지 내용을 화면 너비에 맞게 배치
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (memory.isUser!)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 0.0), // horizontal과 vertical 패딩 설정
                            child: Text(
                              _formatDate(memory.timestamp!),
                              style: const TextStyle(
                                fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        Padding(
                          padding: memory.isUser!
                              ? const EdgeInsets.symmetric(horizontal: 16.0)
                              : const EdgeInsets.symmetric(
                                  horizontal: 6.0),
                          child: Text(
                            memory.title ?? 'Untitled Memory',
                            style: const TextStyle(
                              fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: memory.isUser!
                              ? const EdgeInsets.symmetric(horizontal: 16.0)
                              : const EdgeInsets.only(
                                  right: 10.0), // 조건에 따라 다른 패딩 적용
                          child: Text(
                            memory.contents ?? 'No content available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'NanumFontSetup_TTF_SQUARE',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey[300],
          thickness: 1.0,
          indent: 16.0,
          endIndent: 16.0,
        ),
      ],
    );
  }

  Widget _getIconButton(Color color, IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: color, // 동그라미 색상 설정
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
