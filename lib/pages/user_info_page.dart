import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  final TextEditingController nameController = TextEditingController();
  Uint8List? uploadFile;
  String userPhoto = "";

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserModel? user = await ref.read(authRepositoryProvider).getCurrentUserData();

      if (user != null) {
        userPhoto = user.profilePic;
        nameController.text = user.name;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    // image = await pickImageFromGallery(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      uploadFile = result.files.single.bytes;
      setState(() {});
    }
  }

  void saveUserInfo() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(authRepositoryProvider).saveUserDataToFirebase(context, uploadFile, name);
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
                        if (uploadFile == null) ...[
                          if (userPhoto != "") ...[
                            CircleAvatar(
                              backgroundImage: NetworkImage(userPhoto),
                              radius: 64,
                            )
                          ]
                          else ...[
                            const CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/img/user.png'
                              ),
                              backgroundColor: primary2,
                              radius: 64,
                            )
                          ]
                        ]
                        else ...[
                          CircleAvatar(
                            backgroundImage: MemoryImage(uploadFile!),
                            radius: 64,
                          )
                        ],
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