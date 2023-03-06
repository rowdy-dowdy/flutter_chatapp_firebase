import 'dart:io';
import 'dart:html' as html;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/providers/chat_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/repositories/firestore_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_chatapp_firebase/widgets/chat_buble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:file_picker/file_picker.dart';

class MessagePage extends ConsumerWidget {
  final String? id;
  const MessagePage({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: MessageAppBar(id: id!),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageBodyChat(id: id!),
            ),
            MessageBottomBar(id: id!)
          ],
        ),
      ),
    );
  }
}

class MessageAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final double height;
  final String id;
  const MessageAppBar({required this.id, this.height = 60, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageAppBarState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class _MessageAppBarState extends ConsumerState<MessageAppBar> {
  final searchController = TextEditingController();

  void makeCall(WidgetRef ref, BuildContext context) {
    // ref.read(callControllerProvider).makeCall(
    //   context,
    //   name,
    //   uid,
    //   profilePic,
    //   isGroupChat,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.arrow_back_ios_new_rounded), 
      ),
      titleSpacing: 0,
      centerTitle: false,
      title: StreamBuilder<UserModel>(
        stream: ref.read(authRepositoryProvider).userDataById(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: primary2,
              highlightColor: primary3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: primary2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2,),
                      Container(width: 100, height: 20, decoration: BoxDecoration(
                        color: primary2,
                        borderRadius: BorderRadius.circular(6)
                      ),),
                      const SizedBox(height: 5,),
                      Container(width: 50, height: 10, decoration: BoxDecoration(
                        color: primary2,
                        borderRadius: BorderRadius.circular(6)
                      ),),
                    ],
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return const Text('Error');
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: primary2),
                  color: primary2,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(snapshot.data!.profilePic),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.data!.name),
                  Text(
                    snapshot.data!.isOnline ? 'online' : 'offline',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call, size: 20,),
        ),
        IconButton(
          onPressed: () => makeCall(ref, context),
          icon: const Icon(Icons.video_call),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ]
    );
  }
}

class MessageBottomBar extends ConsumerStatefulWidget {
  final String id;
  const MessageBottomBar({required this.id, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MessageBottomBarState();
}

class MessageBottomBarState extends ConsumerState<MessageBottomBar> {
  final textMessageController = TextEditingController();
  late FlutterSoundRecorder? recorder;

  final List<String> allowedExtensions = ['jpg', 'mp4', 'gif', 'mp3', 'png'];

  void selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,   
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (allowedExtensions.indexWhere((v) => v == file.extension) < 0) {
        if (context.mounted) {
          showSnackBar(context: context, content: "File extensions is not support");
        }
        return;
      }

      if (file.size > 2097152) {
        if (context.mounted) {
          showSnackBar(context: context, content: "File size larger than 2 mb");
        }
        return;
      }

      Uint8List? uploadFile = result.files.single.bytes;
      
      if (uploadFile != null && context.mounted) {
        ref.read(chatControllerProvider).sendFileMessage(
          context: context, 
          file: uploadFile, receiverUserId: widget.id, 
          messageEnum: file.extension == "jpg" || file.extension == "png"
            ? MessageEnum.image
            : file.extension == "mp4" ? MessageEnum.video
            : file.extension == "mp3" ? MessageEnum.audio
            : MessageEnum.gif
        );
      }
    }
  }

  void sendTextMessage() {
    ref.read(chatControllerProvider)  
      .sendTextMessage(context: context, text: textMessageController.text.trim(), receiverUserId: widget.id);

    setState(() {  
      textMessageController.text = "";
    });
  }

  void record() async {
    await recorder!.startRecorder(toFile: 'audio');
  }

  void stopRecord() async {
    final path = await recorder!.stopRecorder();
    final audioFile = File(path!);

    print('audio $audioFile');
  }

  void initRecorder() async {
    recorder = FlutterSoundRecorder();

    if(kIsWeb) {
      final perm = await html.window.navigator.permissions!.query({"name": "microphone"});
      if (perm.state != "granted") {
        throw 'Microphone permission is not granted';
      }
    }
    else {
      final status = await Permission.microphone.request();

      if (status != PermissionStatus.granted) {
        throw 'Microphone permission is not granted';
      }
    }

    await recorder!.openRecorder();
    recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3)
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: selectImage,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.attachment, size: 22,),
                    )
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: textMessageController,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  !recorder!.isRecording ? InkWell(
                    onTap: record,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.mic, size: 22,),
                    )
                  )
                  : InkWell(
                    onTap: stopRecord,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.stop, size: 22, color: Colors.red,),
                    )
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: sendTextMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary2,
                borderRadius: BorderRadius.circular(3)
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.send, color: Colors.white, size: 18,),
            ),
          )
        ],
      ),
    );
  }
}

class MessageBodyChat extends ConsumerStatefulWidget {
  final String id;
  const MessageBodyChat({required this.id, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBodyChatState();
}

class _MessageBodyChatState extends ConsumerState<MessageBodyChat> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userCurrent = ref.watch(authControllerProvider).user;
    return StreamBuilder(
      stream: ref.read(chatControllerProvider).getMessages(widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(child: CircularProgressIndicator())
          );
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController
            .jumpTo(messageController.position.maxScrollExtent);
        });

        var userSenderIdCache = "";

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final message = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(message.timeSent);
            bool isMe = message.senderId == userCurrent!.uid;
            bool isFirst = false;
            bool isLast = false;

            if (userSenderIdCache != message.senderId) {
              isFirst = true;
            }

            userSenderIdCache = message.senderId;

            if ((index < snapshot.data!.length - 1 && userSenderIdCache != snapshot.data![index + 1].senderId)
              || index == snapshot.data!.length - 1) {
              isLast = true;
            }

            return CustomBubbleChat(
              message: message.text,
              time: timeSent,
              isMe: isMe,
              isLast: isLast,
              isFirst: isFirst,
              messageEnum: message.type,
            );
          },
        );
      },
    );
  }
}













