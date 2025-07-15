import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditNamePage extends StatefulWidget {
  final String currentName;
  final ValueChanged<String> onNameSaved;

  const EditNamePage({
    super.key,
    required this.currentName,
    required this.onNameSaved,
  });

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  late TextEditingController _nameController;
  String? _errorMessage;
  String? _photoURL; // Firestore에서 가져온 photoURL
  String? _nickname; // Firestore에서 가져온 nickname
  String? _email; // Firebase에서 가져온 사용자 이메일
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _loadUserData(); // 사용자 데이터 로드
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Firestore에서 사용자 데이터 로드 (photoURL 및 nickname)
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _photoURL = doc.data()?['photoURL']; // photoURL 가져오기
            _nickname = doc.data()?['nickname']; // nickname 가져오기
            _email = doc.data()?['email']; // email 가져오기
            _nameController.text = _nickname ?? ""; // TextField에 nickname 설정
          });
        }
      } catch (e) {
        // print("사용자 데이터 로드 중 오류 발생: $e");
      }
    }
  }

  Future<void> _saveNameToFirestore(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'nickname': name,
        });
      } catch (e) {
        throw Exception("Failed to update name in Firestore.");
      }
    } else {
      throw Exception("User not logged in.");
    }
  }

// 로그아웃 처리 함수
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase Auth 로그아웃
      await _googleSignIn.signOut();
      // print('로그아웃 성공');
    } catch (e) {
      // print('로그아웃 중 오류 발생: $e');
    }
  }

  void _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        final isKorean =
            context.read<LanguageProvider>().currentLanguage == Language.ko;
        _errorMessage = isKorean ? '이름을 입력해주세요!' : 'Please enter a name!';
      });
      return;
    }
    try {
      // Firestore에 이름 저장
      await _saveNameToFirestore(name);

      // 앱 상태에 이름 저장
      widget.onNameSaved(name);

      // 페이지 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            context.read<LanguageProvider>().currentLanguage == Language.ko
                ? '이름 저장에 실패했습니다.'
                : 'Failed to save the name.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKorean =
        context.watch<LanguageProvider>().currentLanguage == Language.ko;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isKorean ? "계정 관리" : "My Account",
          style: const TextStyle(
              fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold'),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveName,
            child: Text(
              isKorean ? '저장' : 'Save', // 언어 설정
              style: TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                color: AppStyles.maindeepblue,
                fontSize: 16,
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
            const SizedBox(height: 70),
            // 프로필 사진 및 편집 아이콘
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppStyles.primaryColor,
                  backgroundImage: _photoURL != null
                      ? NetworkImage(_photoURL!)
                      : null, // photoURL 적용
                  child: _photoURL == null
                      ? const Icon(
                          MdiIcons.robot, // 기본 아이콘
                          size: 70,
                          color: Colors.white,
                        )
                      : null, // photoURL이 없으면 기본 아이콘 표시
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 사용자 이름 및 이메일
            _buildNameAndEmailField(
              nameLabel: isKorean ? '사용자 정보' : 'USER info',
              emailLabel: isKorean ? '로그인된 이메일' : 'Signed-in Email',
              controller: _nameController,
              email: _email ?? '',
              errorMessage: _errorMessage,
            ),
            const SizedBox(height: 20),
            // 로그아웃 버튼
            _buildDoubleButton(
              nameLabel: isKorean ? '계정 관리' : 'Account',
              firstButtonName: isKorean ? '로그아웃' : 'Sign Out',
              secondButtonName: isKorean ? '계정 삭제' : 'Delete Account',
              isKorean: isKorean,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndEmailField({
    required String nameLabel,
    required String emailLabel,
    required TextEditingController controller,
    required String email,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameLabel,
          style: const TextStyle(
            fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(top: 4.0, left: 12.0, bottom: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLength: 8,
                      style: const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
                        fontSize: 16,
                      ),
                      controller: controller,
                      decoration: InputDecoration(
                          counterText: '', // 글자 수 표시 안 함
                          hintText: '사용자 이름을 입력하세요.',
                          hintStyle: const TextStyle(
                            fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          errorText: errorMessage,
                          errorStyle: const TextStyle(
                            fontFamily: 'NanumFontSetup_TTF_SQUARE_Bold',
                            color: Colors.red,
                          )),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.clear(); // 이름 필드 지우기
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              Text(
                '$emailLabel: $email',
                style: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoubleButton({
    required String nameLabel,
    required String firstButtonName,
    required String secondButtonName,
    required bool isKorean,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameLabel,
          style: const TextStyle(
            fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/startPage",
                    (Route<dynamic> route) => false,
                  ); // StartPage로 이동
                  _signOut(); // 로그아웃 처리
                },
                child: Text(
                  firstButtonName, // 언어 설정
                  style: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
              ),
              const Divider(color: Colors.grey),
              //
              TextButton(
                onPressed: () {
                  _showConfirm(
                      isKorean
                          ? "탈퇴 확인"
                          : "Delete Account Contirmation", // 언어 설정
                      isKorean
                          ? "계정을 삭제하시겠습니까?\n\n탈퇴 후 데이터가 삭제되며, 복구되지 않습니다.\n자세한 내용은 개인정보처리방침을 확인해주세요."
                          : "Are you sure you want to delete your account?\n\nAfter withdrawal, your data will be deleted and cannot be recovered.\nPlease check the privacy policy for more details.",
                      isKorean);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  secondButtonName, // 언어 설정
                  style: const TextStyle(
                    fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ),
              //
            ],
          ),
        ),
      ],
    );
  }

  Future<void> deleteUserDataFromFirestore(String uid) async {
    try {
      // 사용자 데이터가 저장된 컬렉션 경로
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      // 사용자 문서 삭제
      await userDoc.delete();
    } catch (e) {
      // print("Firestore 데이터 삭제 중 오류 발생: $e");
    }
  }

  Future<void> handleAccountDeletion() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        // 1. Firestore 데이터 삭제
        await deleteUserDataFromFirestore(uid);

        // 2. Google 계정 연결 해제
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.disconnect();

        // 3. Firebase 사용자 삭제
        await user.delete();

        // print("사용자 탈퇴가 완료되었습니다.");
      } else {
        // print("로그인된 사용자가 없습니다.");
      }
    } catch (e) {
      // print("사용자 탈퇴 처리 중 오류 발생: $e");
    }
  }

  void _showConfirm(String title, String content, bool isKorean) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.maingray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
          ),
          contentPadding: const EdgeInsets.all(17), // 내부 패딩
          titlePadding:
              const EdgeInsets.only(top: 20, bottom: 0, left: 17, right: 17),
          actionsPadding: const EdgeInsets.all(0), // 버튼 간격을 없애고 자체적인 감싸기
          title: Text(
            title,
            style: const TextStyle(
                fontFamily: 'NanumFontSetup_TTF_SQUARE_ExtraBold',
                color: Colors.black,
                fontSize: 18),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontFamily: 'NanumFontSetup_TTF_SQUARE',
              color: Colors.black,
            ),
          ),
          actions: [
            // 버튼 감싸는 상자 (버튼을 양쪽 끝까지 확장)
            Padding(
              padding: const EdgeInsets.all(10), // 상하에 패딩 추가
              child: Row(
                children: [
                  // 확인 버튼을 감싸는 상자
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/startPage",
                          (Route<dynamic> route) => false,
                        ); // StartPage로 이동
                        handleAccountDeletion(); // 계정 삭제 처리
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // 둥글게
                          color: AppStyles.maindeepblue, // 배경색
                        ),
                        child: Center(
                          child: Text(
                            isKorean ? "확인" : "Yes",
                            style: const TextStyle(
                              fontFamily: 'NanumFontSetup_TTF_SQUARE',
                              fontSize: 14, // 버튼 텍스트 크기
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // 버튼 간 간격
                  // 취소 버튼을 감싸는 상자
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // 둥글게
                          color: Colors.grey, // 배경색
                        ),
                        child: Center(
                          child: Text(
                            isKorean ? "취소" : "No",
                            style: const TextStyle(
                              fontFamily: 'NanumFontSetup_TTF_SQUARE',
                              fontSize: 14, // 버튼 텍스트 크기
                              color: Colors.white,
                            ),
                          ),
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
    );
  }
}
