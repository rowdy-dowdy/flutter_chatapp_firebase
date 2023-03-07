import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Lottie.asset(
              'assets/lotties/19141-drive-the-car.json',
            ),
          ),
        ),
      ),
    );
  }
}