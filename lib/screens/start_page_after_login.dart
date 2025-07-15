import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/providers/name_provider.dart';
import 'package:memory_plant_application/providers/memory_log_provider.dart';
import '../providers/chatbot_provider.dart';
import 'dart:developer' as developer;

class StartPageAfterLogin extends StatefulWidget {
  const StartPageAfterLogin({super.key});

  @override
  State<StartPageAfterLogin> createState() => _StartPageAfterLoginState();
}

class _StartPageAfterLoginState extends State<StartPageAfterLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Load providers
    context.read<MemoryLogProvider>().loadMemoryLogs();
    context.read<NameProvider>().loadName();
    context.read<ChatProvider>().loadMessages();

    // network status
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
    if (_connectionStatus.contains(ConnectivityResult.none)) {
      _showNetworkErrorDialog();
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.maingray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
          ),
          contentPadding: const EdgeInsets.all(17), // 내부 패딩
          content: Column(
            mainAxisSize: MainAxisSize.min, // 다이얼로그 크기 축소
            children: [
              Icon(
                Icons.warning_amber_rounded, // 경고 아이콘
                color: AppStyles.maindeepblue,
                size: 48, // 아이콘 크기
              ),
              const SizedBox(height: 16), // 아이콘과 제목 사이 간격
              Text(
                context.read<LanguageProvider>().currentLanguage == Language.ko
                    ? '네트워크 연결 끊김'
                    : 'Check your network',
                style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
              const SizedBox(height: 12), // 제목과 내용 사이 간격
              Text(
                context.read<LanguageProvider>().currentLanguage == Language.ko
                    ? '인터넷 연결이 불안정합니다.\n연결 상태를 확인 후 재시도 해주세요.'
                    : 'The connection is unstable.\nPlease check your network status and try again.',
                style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await initConnectivity(); // 연결 상태 다시 확인
              },
              child: Text(
                context.read<LanguageProvider>().currentLanguage == Language.ko
                    ? '다시 시도'
                    : 'Try again',
                style: TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE',
                  color: AppStyles.maindeepblue,
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
            ),
          ],
        );
      },
      barrierDismissible: false, // 다이얼로그 밖을 눌러도 닫히지 않음
    );
  }

  int _getDiaryCountForDate(List<dynamic> memoryList, DateTime targetDate) {
    return memoryList.where((memory) {
      final timestamp = DateTime.parse(memory.timestamp);
      return timestamp.year == targetDate.year &&
          timestamp.month == targetDate.month &&
          timestamp.day == targetDate.day &&
          memory.isUser == true;
    }).length;
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

  @override
  Widget build(BuildContext context) {
    final nameProvider = Provider.of<NameProvider>(context, listen: true);
    final memoryLogProvider =
        Provider.of<MemoryLogProvider>(context); // MemoryLogProvider 가져오기
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    final memoryCount = memoryLogProvider.memoryList
        .where((memory) => memory.isUser == true)
        .length; // 내가 쓴 메모리 개수
    final memoryList = memoryLogProvider.memoryList;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayCount = _getDiaryCountForDate(memoryList, today);
    final yesterdayCount = _getDiaryCountForDate(memoryList, yesterday);

    // 애니메이션 길이 계산
    final maxContainerHeight = MediaQuery.of(context).size.height * 0.7;
    final animation1Height =
        (yesterdayCount * 100).clamp(0, maxContainerHeight);
    final animation2Height = (todayCount * 100).clamp(0, maxContainerHeight);

    // 애니메이션 늘어날 길이 조정정
    _animation1 =
        Tween<double>(begin: 0, end: animation1Height.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animation2 =
        Tween<double>(begin: 0, end: animation2Height.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    return GestureDetector(
      onTap: () {
        // 화면 탭 시 다음 페이지로 이동
        Navigator.pushNamed(context, "/bottomNavPage");
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 125),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${DateTime.now().year}',
                        style: const TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_getMonthAbbreviation(DateTime.now().month)} ${DateTime.now().day}',
                        style: const TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isKorean
                            ? '${nameProvider.name}님 환영합니다!'
                            : "Welcome ${nameProvider.name}!",
                        style: const TextStyle(
                            fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isKorean
                            ? "$memoryCount개의 기억" // 메모리 개수 표시
                            : "$memoryCount Memories",
                        style: const TextStyle(
                          fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Text(
                    isKorean ? "화면을 탭하여 시작하기" : "Tap the screen to start",
                    style: const TextStyle(
                      fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Animated containers on the right
            Positioned(
              top: 0,
              right: 40,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 10,
                    height: _animation1.value,
                    color: AppStyles.primaryColor,
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 20,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 10,
                    height: _animation2.value,
                    color: AppStyles.maindeepblue,
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
