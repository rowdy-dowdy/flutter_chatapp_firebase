import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_chatapp_firebase/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phoneControler = TextEditingController();
  Country? country;

  @override
  void dispose() {
    super.dispose();
    phoneControler.dispose();
  }

  void pickCountry() {
    showCountryPicker(context: context, onSelect: (onSelect) {
      setState(() {
        country = onSelect;
      });
    });
  }

  void sendPhoneNumber () {
    String phoneNumber = phoneControler.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref.read(authControllerProvider).signInWithPhone(context, "+${country!.phoneCode}$phoneNumber");
    }
    else {
      showSnackBar(context: context, content: "Fill out all the fields");
    }
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    final heightSafeArea = MediaQuery.of(context).size.height -
      AppBar().preferredSize.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your phone number"),
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: heightSafeArea),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20,),
                const Text("WhatsApp will need to verify your phone number."),
                const SizedBox(height: 10,),
                TextButton(
                  onPressed: pickCountry, 
                  child: const Text("Pick Country")
                ),
                const SizedBox(height: 5,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (country != null) ...[
                      Text("+ ${country!.phoneCode}"),
                    ],
                    const SizedBox(width: 10,),
                    SizedBox(
                      width: size.width * 0.7,
                      child: TextField(
                        controller: phoneControler,
                        decoration: const InputDecoration(
                          hintText: 'Phone number'
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                const Spacer(),
                SizedBox(
                  width: 90,
                  child: ButtonCustom(
                    onPressed: () => sendPhoneNumber(),
                    text: "NEXT", 
                  )
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}