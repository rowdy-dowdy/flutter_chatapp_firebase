import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Text('setting page')
              ],
            ),
            const Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: MainBottomNavBar(),
            )
          ],
        )
      ),
    );
  }
}