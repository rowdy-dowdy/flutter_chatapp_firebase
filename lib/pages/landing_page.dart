import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                const Text(
                  "Wellcome to WhatsApp",
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height / 9,),
                Image.asset("assets/img/bg.png", height: 340, width: 340, color: tabColor,),
                SizedBox(height: size.height / 9,),
                const Text(
                  "Read your Privacy Policy. Tap \"Agree and continue\" to accept the Terms of Services",
                  style: TextStyle(
                    color: greyColor
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width * .75,
                  child: ButtonCustom(
                    onPressed: () => context.go('/login'),
                    text: "AGREE TO CONTINUE", 
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}