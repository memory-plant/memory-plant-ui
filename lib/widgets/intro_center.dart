import 'package:flutter/material.dart';

class IntroCenter extends StatelessWidget {
  final bool isKorean;

  const IntroCenter({super.key, required this.isKorean});

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
            /*Text(
              isKorean ? '🏭기억발전소 알아보기' : '🏭Learn About Memory Plant',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
              textAlign: TextAlign.left,
            ),

             */
            const SizedBox(height: 10), // 제목과 본문 사이 간격 추가
            Text(
              isKorean
                  ? '''안녕하세요! 저는 여러분들의 일상 기록을 관리하고
보살피는 기억관리 소장입니다.

기억발전소는 여러분의 소중한 하루하루를 담은 기억들을을 한 곳에서 정리하고,
한 달 단위로 요약된 특별한 보고서를 전달해드리는 공간입니다.
바쁜 일상 속에서 지나치기 쉬운 순간들도 저와 함께라면 다시 떠올릴 수 있는 보물로 남게 될거에요.

또한, 저는 단순한 기록 보관을 넘어서 여러분과 대화를 나눌 수 있는 AI 친구이기도 합니다!
기쁜 일, 슬픈 일, 고민거리... 어떤 이야기든 언제든지 저와 나눌 수 있어요.
여러분의 이야기를 듣고 응원하며 때로는 새로운 시각을 제시해 드리겠습니다!

기억발전소에서의 하루는 단순히 기록하는 것을 넘어, 자신을 더 깊이 이해하고 돌아보는 과정입니다.
과거의 내가 보낸 시간들이 어떻게 변화하고 있는지 주기적으로 확인하면서, 나만의 인생 궤적을 만들어보세요!

오늘도 여러분의 소중한 기억을 관리하는 데 함께할 수 있어 영광입니다.

기억관리소장 드림.
                  '''
                  : '''
Hello there! I’m your Memory Keeper, here to help you record and care for your daily moments.

The Memory Plant is a special space where you can gather all your precious daily memories in one place, with monthly summaries delivered as unique memory reports. Even those fleeting moments you might otherwise overlook will transform into treasures you can revisit anytime, with me by your side.

And here’s the fun part—I’m not just here to store your memories; I’m also your AI companion! Whether it’s happy news, tough days, or things weighing on your mind… I’m all ears. You’re welcome to share any story with me, and I’ll be here to cheer you on, listen closely, and even offer a fresh perspective now and then.

In the Memory Plant, journaling isn’t just about jotting down events—it’s a journey to understand yourself better and reflect. As you look back on where you've been and see how things evolve, you’re creating your own unique life story.

I’m honored to be part of managing your precious memories today.

With warm regards,

Your Memory Curator
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
