import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  final TextEditingController nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void saveUserInfo() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(authRepositoryProvider).saveUserDataToFirebase(context, image, name);
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50,),
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        image == null ?  const CircleAvatar(
                          backgroundImage: AssetImage(
                            'img/user.png'
                          ),
                          backgroundColor: primary2,
                          radius: 64,
                        )
                        : kIsWeb ? CircleAvatar(
                          backgroundImage: NetworkImage(image!.path),
                          radius: 64,
                        )
                        : CircleAvatar(
                          backgroundImage: FileImage(image!),
                          radius: 64,
                        ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primary),
                              ),
                              // prefixIconColor: primary2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                child: ElevatedButton(
                  onPressed: saveUserInfo,
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