import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phoneController = TextEditingController();
  Country? country = Country.tryParse('VN');

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(context: context, onSelect: (onSelect) {
      setState(() {
        country = onSelect;
      });
    });
  }

  void loginWithGithub() {
    ref.read(authRepositoryProvider).signInWithGithub(context);
  }

  void loginWithFacebook() {
    ref.read(authRepositoryProvider).signInWithFacebook(context);
  }
  void loginWithGoogle() {
    ref.read(authRepositoryProvider).signInWithGoogle(context);
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref.read(authRepositoryProvider).signInWithPhone(context, "+${country!.phoneCode}$phoneNumber");
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,),
          child: Column(
            children: [
              const SizedBox(height: 50,),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Image.asset("img/cat2.png", width: 300)),
                      // const SizedBox(height: 10),
                      const Text(
                        "Enter your phone number",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "WhatsApp will need to verify your phone number",
                        style: TextStyle(
                          color: Colors.grey
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: pickCountry,
                              child: country != null ? _flagWidget(country!) : const Icon(Icons.arrow_drop_down),
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Your phone',
                                ),
                              ),
                            ),
                            const SizedBox(width: 5,),
                            const Icon(Icons.contact_page_rounded)
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Or login with Social Network",
                        style: TextStyle(
                          color: Colors.grey
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children: [
                          InkWell(
                            onTap: loginWithFacebook,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                "svg/bxl-facebook.svg",
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              )
                            ),
                          ),
                          InkWell(
                            onTap: loginWithGoogle,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: yellow,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                "svg/bxl-google.svg",
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              )
                            ),
                          ),
                          InkWell(
                            onTap: loginWithGithub,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                "svg/bxl-github.svg",
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: sendPhoneNumber,
                  child: const Text("Send"), 
                )
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Row(
        children: [
          Text(
            country.iswWorldWide
                ? '\uD83C\uDF0D'
                : Utils.countryCodeToEmoji(country.countryCode),
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          const SizedBox(width: 5,),
          Text("+ ${country.phoneCode}"),
          const SizedBox(width: 5,),
          const Icon(Icons.arrow_drop_down)
        ],
      ),
    );
  }
}

class Utils {
  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
