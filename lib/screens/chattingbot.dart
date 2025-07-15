import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/chatbot_provider.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/providers/navigation_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:provider/provider.dart';
import '../services/message_log.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Chatbot extends StatelessWidget {
  const Chatbot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final isKorean =
            context.watch<LanguageProvider>().currentLanguage == Language.ko;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () {
                context
                    .read<NavigationProvider>()
                    .updateIndex(0); // HomePage 인덱스
              },
            ),
            title: _buildAppBarTitle(isKorean),
            centerTitle: true,
            actions: const [],
          ),
          body: Column(
            children: [
              // 메시지 리스트
              Expanded(
                  child: _buildMessageList(chatProvider, context, isKorean)),

              // 메시지 입력 필드
              _buildMessageInput(chatProvider, isKorean, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(bool isKorean) {
    return Text(
      isKorean ? "기억관리소장" : "Memory Curator",
      style: const TextStyle(
        fontFamily: 'NanumFontSetup_TTF_SQUARE_Extrabold',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMessageList(
      ChatProvider chatProvider, BuildContext context, bool isKorean) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: chatProvider.messageList.length,
            itemBuilder: (context, index) {
              final message = chatProvider.messageList[index];
              final bool isMe = message.isSentByMe ?? false;

              // 날짜 구분선 표시 여부를 판단

              return Column(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      chatProvider.deleteMessage(message); // Firestore에서 삭제
                    },
                    child: _buildMessageBubble(message, isMe, context),
                  ),
                ],
              );
            },
          ),
        ),
        if (chatProvider.isTyping) // 상대방 타이핑 상태
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    TyperAnimatedText('Typing ...'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(
      MessageLog message, bool isMe, BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const Padding(
              padding: EdgeInsets.only(left: 15.0, bottom: 12.0),
            ),
          Flexible(
            // Flexible로 Row 자식의 크기 제한
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMe
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.width * 0.9, // 상대방 말풍선 제한
              ),
              margin: EdgeInsets.only(
                top: 0.0,
                bottom: 20.0,
                left: isMe ? 8.0 : 5.0, // 상대방 말풍선 간격 조정
                right: isMe ? 15.0 : 8.0,
              ),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isMe
                    ? AppStyles.maindeepblue
                    : Colors.transparent, // 상대방은 투명 배경
                borderRadius: isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(17.0),
                        topRight: Radius.circular(3.0),
                        bottomLeft: Radius.circular(17.0),
                        bottomRight: Radius.circular(17.0),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(17.0),
                        topRight: Radius.circular(17.0),
                        bottomLeft: Radius.circular(3.0), // 왼쪽 아래만 뾰족하게 처리
                        bottomRight: Radius.circular(17.0),
                      ),
              ),
              child: Text(
                message.content ?? "(빈 메시지)",
                style: isMe
                    ? const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      )
                    : const TextStyle(
                        fontFamily: 'NanumFontSetup_TTF_SQUARE',
                        fontWeight: FontWeight.w400,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
      ChatProvider chatProvider, bool isKorean, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatProvider.controller,
              focusNode: chatProvider.focusNode,
              maxLines: 5,
              minLines: 1,
              maxLength: 500,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                hintText: isKorean ? "메세지 보내기" : "Enter your message",
                hintStyle: const TextStyle(
                  fontFamily: 'NanumFontSetup_TTF_SQUARE',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: AppStyles.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: AppStyles.maindeepblue),
                ),
                counterText: "", // 글자수 카운트 제거
                suffixIcon: IconButton(
                  icon: Transform.translate(
                    offset: const Offset(0, -3), // y 값이 -5로 아이콘을 위로 5만큼 이동
                    child: Transform.rotate(
                      angle: -27 * (3.14159 / 180), // 45도를 라디안 값으로 변환 (반시계 방향)
                      child: Icon(
                        FluentSystemIcons.ic_fluent_send_regular,
                        color: AppStyles.maindeepblue,
                        size: 25,
                      ),
                    ),
                  ),
                  onPressed: () => chatProvider.sendMessage(context),
                ),
              ),
              onSubmitted: (_) => chatProvider.sendMessage(context),
              cursorColor: AppStyles.maindeepblue,
            ),
          ),
        ],
      ),
    );
  }
}
