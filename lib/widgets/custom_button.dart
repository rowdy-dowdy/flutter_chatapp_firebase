import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonCustom extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;

  const ButtonCustom({required this.text, this.onPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(tabColor),
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50))
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white
        ),
      ),
    );
  }
}