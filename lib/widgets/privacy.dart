import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  final bool isKorean;

  const Privacy({super.key, required this.isKorean});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.all(16.0), // 여백 추가
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 텍스트 높이에 맞춰 상자 크기 조절
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10), // 제목과 본문 사이 간격 추가
            Text(
              isKorean
                  ? ''' AI 요약 서비스를 이용할 경우, 입력된 일기 내용은 요약 결과 제공을 위한 분석 과정에 사용될 수 있습니다.\n따라서 이름, 주소, 전화번호, 계좌번호 등 민감한 개인정보를 포함하지 않도록 주의하시기 바랍니다. 해당 데이터는 요약 처리 외의 목적으로 사용되지 않으며 외부에 공유되지 않도록 철저히 보호됩니다.\n\n 다만, 사용자가 입력한 내용에 포함된 개인정보로 인해 발생할 수 있는 문제에 대해서는 앱 개발자가 책임지지 않으니, 안전하고 신중하게 서비스를 이용해 주시기 바랍니다.
                  '''
                  : '''When using the AI summary service, the content of your diary entries may be utilized for analysis to provide summarized results.\nTherefore, please ensure that sensitive personal information, such as names, addresses, phone numbers, or account details, is not included.\n\nThe data will only be used for summary processing purposes and will be strictly protected from external sharing.\nHowever, the app developer cannot be held responsible for any issues arising from personal information included in the content provided by users.\n\nPlease use the service carefully and responsibly.
                  ''',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'NanumFontSetup_TTF_SQUARE',
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
