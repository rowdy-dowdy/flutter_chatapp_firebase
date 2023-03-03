import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/providers/chat_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/chat_buble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
            return const CircularProgressIndicator();
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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textMessageController.dispose();
    super.dispose();
  }

  void sendTextMessage() {
    ref.read(chatControllerProvider)  
      .sendTextMessage(context: context, text: textMessageController.text.trim(), receiverUserId: widget.id);

    setState(() {  
      textMessageController.text = "";
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3)
              ),
              child: Row(
                children: [
                  const Icon(Icons.attachment, color: primary, size: 22,),
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
                  const Icon(Icons.mic, color: primary, size: 22,),
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
            );
          },
        );
      },
    );
  }
}













