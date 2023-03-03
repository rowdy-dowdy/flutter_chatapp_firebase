// import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';

class CustomBubbleChat extends ConsumerWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isLast;
  final bool isFirst;
  const CustomBubbleChat({required this.message, required this.time, required this.isLast, required this.isFirst, this.isMe = true, super.key});
  
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: isMe ? const Radius.circular(50) : isFirst ? const Radius.circular(50) : const Radius.circular(20),
                topRight: !isMe ? const Radius.circular(50) : isFirst ? const Radius.circular(50) : const Radius.circular(20),
                bottomRight: !isMe ? const Radius.circular(50) : isLast ? const Radius.circular(50) : const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(50) : isLast ? const Radius.circular(50) : const Radius.circular(20)
              ),
              color: bgColor
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: TextStyle(color: textColor ),),
                const SizedBox(width: 5,),
                isMe ? Transform.translate(
                  offset: const Offset(0, 2),
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
          ),
        ),
      ]
    );
  }
}
