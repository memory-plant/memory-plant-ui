import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:intl/intl.dart'; // 날짜 처리를 위한 패키지
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import 'package:memory_plant_application/widgets/diary_tile.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    return Scaffold(
      body: Consumer<MemoryLogProvider>(
        builder: (context, memoryLogProvider, child) {
          // 로딩 상태를 다루지 않고, 이미 로드된 상태에서 UI 갱신
          if (memoryLogProvider.memoryList.isEmpty) {
            return _buildEmptyState(isKorean);
          }

          return _buildMemoryList(context, memoryLogProvider);
        },
      ),
    );
  }

  Widget _buildMemoryList(
      BuildContext context, MemoryLogProvider memoryLogProvider) {
    final memoryList = memoryLogProvider.memoryList;

    return ListView.separated(
      itemCount: memoryList.length,
      itemBuilder: (context, index) {
        final memory = memoryList[index];
        final currentMonth = _getMonthFromTimestamp(memory.timestamp!);

        bool showMonthSeparator = (index == 0) ||
            (_getMonthFromTimestamp(memoryList[index - 1].timestamp!) !=
                currentMonth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMonthSeparator) _buildMonthSeparator(currentMonth),
            DiaryTile(
              memory: memory,
              index: index,
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  Widget _buildEmptyState(bool isKorean) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/No_memory.png',
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 20),
          Text(
            isKorean ? "첫 기억을 추가해보세요" : "Add your first memory",
            style: const TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE', fontSize: 18),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getMonthFromTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    return DateFormat.yMMMM().format(date); // 예: "November 2024"
  }

  Widget _buildMonthSeparator(String month) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        month,
        style: const TextStyle(
          fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
