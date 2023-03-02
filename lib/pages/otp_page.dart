import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPPage extends ConsumerStatefulWidget {
  final String verificationId;
  const OTPPage({required this.verificationId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OTPPageState();
}

class _OTPPageState extends ConsumerState<OTPPage> {
  String smsCode = "";

  void verifyOTP () {
    ref.read(authControllerProvider.notifier).verifyOTP(context, widget.verificationId, smsCode.trim());
  }

  @override
  Widget build(BuildContext context) {

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Image.asset("img/cat3.png", width: 300)),
                      // const SizedBox(height: 10),
                      const Text(
                        "Verification",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(height: 15),
                      OtpTextField(
                        numberOfFields: 6,
                        fillColor: Colors.black.withOpacity(.1),
                        filled: true,
                        onCodeChanged: (String code) {
                          smsCode = code;
                          setState(() {});
                        },
                        onSubmit: (String verificationCode) {
                          smsCode = verificationCode;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "We have sent an SMS with a code",
                        style: TextStyle(
                          color: greyColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () => smsCode.length == 6 ? verifyOTP() : null,
                  style: smsCode.length != 6 ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey
                  ) : null,
                  child: const Text("Verify"), 
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