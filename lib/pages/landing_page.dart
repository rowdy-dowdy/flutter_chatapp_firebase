import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,),
          child: Column(
            children: [
              const SizedBox(height: 50,),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/img/cat1.png"),
                        // const SizedBox(height: 10),
                        const Text(
                          "Wellcome to WhatsApp",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Read your Privacy Policy. Tap \"Agree and continue\" to accept the Terms of Services",
                          style: TextStyle(
                            color: Colors.grey
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("AGREE TO CONTINUE"), 
                )
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}