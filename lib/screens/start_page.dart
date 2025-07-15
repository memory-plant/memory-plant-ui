import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:memory_plant_application/providers/name_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;


// 사용자 정의 예외 클래스
class EmptyNameException implements Exception {
  final String message;
  EmptyNameException(this.message);

  @override
  String toString() => message;
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  int currentButtonIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );


  Future<void> _signInWithApple() async {
  try {
    // Apple Auth Provider 생성
    final appleProvider = AppleAuthProvider();

    // Firebase Auth로 Apple로 로그인 요청
    final UserCredential userCredential = await _auth.signInWithProvider(appleProvider);

    User? user = userCredential.user;

    if (user != null) {
      // Firestore 사용자 문서 참조
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Firestore에서 사용자 문서 확인
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Firestore에 사용자 문서가 없으면 최초 로그인 처리
        try {
          // Apple에서 제공한 추가 정보 (email, displayName) 확인
          final idToken = await user.getIdTokenResult();
          final claims = idToken.claims;

          String? email = claims?['email'] ?? 'unknown@apple.com';
          String? displayName = claims?['name'] ?? 'Apple User';

          // Firestore에 사용자 정보 저장
          await userRef.set({
            'uid': user.uid,
            'email': email,
            'displayName': displayName,
            'nickname': displayName, // 최초 로그인 시 nickname 설정
            'photoURL': user.photoURL,
            'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
            'creationTime': user.metadata.creationTime?.toIso8601String(),
          });

          debugPrint('최초 로그인: Firestore에 사용자 정보가 저장되었습니다.');
        } catch (e) {
          debugPrint('Firestore에 사용자 정보를 저장하는 중 오류 발생: $e');
        }
      } else {
        debugPrint('사용자가 이미 Firestore에 존재합니다.');
      }

      // nickname 필드 확인 후 페이지 이동
      final updatedUserDoc = await userRef.get();
      if (updatedUserDoc.exists && updatedUserDoc.data()?['nickname'] != null) {
        // nickname 필드가 존재하면 페이지 이동
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/startPageAfterLogin");
        }
      } else {
        // nickname 필드가 없으면 추가 정보 입력 페이지로 이동
        changeButton();
      }
    } else {
      // 로그인 실패 시 버튼 상태 변경
      changeButton();
    }
  } catch (e) {
    // Apple 로그인 오류 처리
    debugPrint("Apple Login Error: $e");
  }
}


  Future<void> _signInWithGoogle() async {
    try {
      // 구글 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소했을 때
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인 인증 시도
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Firestore에 사용자 정보 저장
      if (user != null) {
        try {
          final userRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          // 사용자의 정보를 Firestore에 저장. 기존 데이터가 있다면 덮어쓰기

          await userRef.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'lastSignInTime': user.metadata.lastSignInTime,
            'creationTime': user.metadata.creationTime,
          }, SetOptions(merge: true));

          // print('사용자 정보가 Firestore에 성공적으로 저장되었습니다.');
        } catch (e) {
          // print('Firestore에 사용자 정보를 저장하는 중 오류 발생: $e');
        }
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userRef.get();
        if (userDoc.exists && userDoc.data()?['nickname'] != null) {
          // nickname 필드가 이미 존재하면 바로 페이지로 이동
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/startPageAfterLogin");
          }
        } else {
          changeButton();
        }
      } else {
        changeButton();
      }
    } catch (e) {
      // 예외 처리
      // print("구글 로그인 오류: $e");
    }
  }

  final List<List<String>> buttonTexts = [
    // 각 페이지의 [한국어 텍스트, 영어 텍스트]
    ['한국어', 'English'], // 언어 선택 페이지
    ['Sign in with Google', 'Sign in with Apple'], // 로그인 선택 페이지
    ['이름을 입력해주세요.', 'Please enter your name'], // 이름 입력 페이지 힌트 메시지
    ['제출', 'Comfirm']
  ];

  final List<String> pageMessages = [
    'Please select your preferred language', // 한국어: 언어 선택 페이지 메시지
    '로그인할 계정을 선택해주세요', // 한국어: 로그인 선택 페이지 메시지
    '이름을 작성해주세요', // 한국어: 이름 입력 페이지 메시지
    'Please select your preferred language', // 영어: 언어 선택 페이지 메시지
    'Select the account to log in', // 영어: 로그인 선택 페이지 메시지
    'Please enter your name' // 영어: 이름 입력 페이지 메시지
  ];

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
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

  void changeButton() {
    setState(() {
      if (currentButtonIndex < buttonTexts.length - 1) {
        currentButtonIndex++;
      }
    });
  }

  Future<void> _submitName() async {
    try {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        throw EmptyNameException(
            context.read<LanguageProvider>().currentLanguage == Language.ko
                ? '이름을 입력해주세요!'
                : 'Please enter your name!');
      }

      // Firestore에 이름 저장
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'nickname': name,
        });
      }

      // 다음 페이지로 이동
      if (mounted) {
        await context.read<NameProvider>().updateName(name);
        if (mounted) {
          Navigator.pushNamed(context, "/startPageAfterLogin");
        }
      }
    } on EmptyNameException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            context.read<LanguageProvider>().currentLanguage == Language.ko
                ? '이름 저장에 실패했습니다.'
                : 'Failed to save the name.';
      });
      // print("Error saving name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.22,
                ),
                const Text(
                  'AI for\nrecording life',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Text(
                  currentButtonIndex == 0
                      ? (isKorean
                          ? pageMessages[0] // 한국어: 언어 선택
                          : pageMessages[3]) // 영어: 언어 선택
                      : currentButtonIndex == 1
                          ? (isKorean
                              ? pageMessages[1] // 한국어: 로그인 선택
                              : pageMessages[4]) // 영어: 로그인 선택
                          : (isKorean
                              ? pageMessages[2] // 한국어: 이름 입력
                              : pageMessages[5]), // 영어: 이름 입력
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                if (currentButtonIndex < 2) ...[
                  OutlinedButton(
                    onPressed: () async {
                      if (currentButtonIndex == 0) {
                        context
                            .read<LanguageProvider>()
                            .setLanguage(Language.ko);
                        changeButton();
                      } else if (currentButtonIndex == 1) {
                        await _signInWithGoogle(); // 구글 로그인 결과 확인
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentButtonIndex == 1)
                          Image.asset(
                            'assets/images/google.png',
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          buttonTexts[currentButtonIndex][0],
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (currentButtonIndex == 0) {
                        context
                            .read<LanguageProvider>()
                            .setLanguage(Language.en);
                        changeButton();
                      } else if (currentButtonIndex == 1) {
                        if (Platform.isAndroid) {
                          // 안드로이드에서는 애플 로그인을 막고 스낵바 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isKorean
                                    ? '안드로이드에서는 애플 로그인을 사용할 수 없습니다.'
                                    : 'Apple Sign-In is not available on Android.',
                              ),
                            ),
                          );
                        } else {
                          // iOS에서는 애플 로그인 시도
                          await _signInWithApple();
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentButtonIndex == 1)
                          Image.asset(
                            'assets/images/apple.png',
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          buttonTexts[currentButtonIndex][1],
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if (currentButtonIndex == 1) TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppStyles.maingray,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16), // 모서리 둥글게
                              ),
                              contentPadding: const EdgeInsets.all(17), // 내부 패딩
                              titlePadding: const EdgeInsets.only(
                                  top: 20, bottom: 0, left: 17, right: 17),
                              actionsPadding: const EdgeInsets.all(
                                  0), // 버튼 간격을 없애고 자체적인 감싸기
                              title: Text(
                                isKorean ? "게스트로 로그인" : "Login as a guest",
                                //textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily:
                                      'NanumFontSetup_TTF_SQUARE_ExtraBold',
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              content: Text(
                                isKorean
                                    ? "게스트로 로그인시 데이터는 저장하지 않습니다.\n진행하시겠습니까?"
                                    : "Logging in as a guest\nwill not save your data.\nDo you want to proceed?",
                                //textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'NanumFontSetup_TTF_SQUARE',
                                    color: Colors.black),
                              ),
                              actions: [
                                Padding(
                                  padding:
                                      const EdgeInsets.all(15), // 상하에 패딩 추가
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center, // 버튼을 가운데 정렬
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pop(); // 다이얼로그 닫기
                                            Navigator.pushNamed(context,
                                                "/startPageAfterLogin");
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0), // 상자 안의 여백
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8.0), // 상자의 둥근 모서리
                                              color: AppStyles.maindeepblue,
                                            ),
                                            child: Center(
                                              child: Text(
                                                  isKorean ? "예" : "Yes",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'NanumFontSetup_TTF_SQUARE',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16), // 버튼 사이에 간격
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pop(); // 다이얼로그 닫기
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0), // 상자 안의 여백
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8.0), // 상자의 둥근 모서리
                                              color: Colors.grey,
                                            ),
                                            child: Center(
                                              child: Text(
                                                  isKorean ? "아니오" : "No",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'NanumFontSetup_TTF_SQUARE',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          barrierDismissible: false, // 다이얼로그 밖을 눌러도 닫히지 않음
                        );
                      },
                      child: Text(
                        isKorean ? '게스트로 로그인' : 'Login as a guest',
                        style: const TextStyle(color: Colors.black),
                      ),
                    )
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: SizedBox(
                      width: 250,
                      height: 50,
                      child: TextField(
                        autofocus: true,
                        maxLength: 8,
                        controller: _nameController,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          hintText: buttonTexts[2]
                              [isKorean ? 0 : 1], // 힌트 메시지 변경
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  OutlinedButton(
                    onPressed: _submitName,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(250, 50),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      buttonTexts[3]
                          [isKorean ? 0 : 1], // 버튼 텍스트를 '제출' 또는 'Confirm'으로 설정
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
