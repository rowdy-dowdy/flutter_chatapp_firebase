import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomBubbleChat extends ConsumerWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isLast;
  final bool isFirst;
  final MessageEnum messageEnum;
  const CustomBubbleChat({required this.message, required this.time, required this.isLast, required this.isFirst, required this.messageEnum, this.isMe = true, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color bgColor = isMe ? primary2 : primary3;
    final Color textColor = isMe ? primary4 : primary;
    final size = MediaQuery.of(context).size;
    
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: const BoxDecoration(),
            clipBehavior: Clip.hardEdge,

            child: messageEnum == MessageEnum.text 
              ? TextMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : messageEnum == MessageEnum.image ? ImageMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : Container()
          ),
        ),
      ]
    );
  }
}

class TextMessage extends ConsumerWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;
  const TextMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned(
          top: -36,
          bottom: -36,
          left: -36,
          right: -36,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                width: 36,
                color: Colors.white
              ),
              borderRadius: BorderRadius.only(
                topLeft: isMe ? const Radius.circular(56) : isFirst ? const Radius.circular(56) : const Radius.circular(42),
                topRight: !isMe ? const Radius.circular(56) : isFirst ? const Radius.circular(56) : const Radius.circular(42),
                bottomRight: !isMe ? const Radius.circular(56) : isLast ? const Radius.circular(56) : const Radius.circular(42),
                bottomLeft: isMe ? const Radius.circular(56) : isLast ? const Radius.circular(56) : const Radius.circular(42)
              )
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              margin: isMe ? const EdgeInsets.only(right: 45) : null,
              child: Text(message, style: TextStyle(color: textColor ),)
            ),
            isMe ? Positioned(
              bottom: 4,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time,style: TextStyle(
                    fontSize: 10, 
                    color: Colors.white.withOpacity(0.6))
                  ),
                  const SizedBox(width: 5,),
                  Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
                ],
              ),
            ) : const SizedBox(),
          ],
        ),
      ],
    );
  }
}

class ImageMessage extends ConsumerWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;

  const ImageMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.7),
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 200
          ),
          child: ClipRRect(borderRadius: borderRadius, child: CachedNetworkImage(
            imageUrl: message,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Container(
              width: 110,
              height: 40,
              margin: const EdgeInsets.only(right: 45),
              alignment: Alignment.center,
              child: Row(
                children: const [
                  SizedBox(width: 10,),
                  Icon(Icons.error, color: Colors.white,),
                  SizedBox(width: 5,),
                  Text("Image error", style: TextStyle(fontSize: 11, color: Colors.white),)
                ],
              )
            ),
          )),
        ),
        isMe ? Positioned(
          bottom: 4,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time,style: TextStyle(
                fontSize: 10, 
                color: Colors.white.withOpacity(0.6))
              ),
              const SizedBox(width: 5,),
              Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
            ],
          ),
        ) : const SizedBox(),
      ],
    );
  }
}