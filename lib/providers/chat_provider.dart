// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatController {
  final ChatRepository chatRepository;
  final Ref ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  void sendTextMessage({required BuildContext context, required String text, required String receiverUserId}) async {
    final userData = ref.watch(authControllerProvider).user;
    chatRepository.sendTextMessage(context: context, text: text, receiverUserId: receiverUserId, senderUser: userData!);
  }

  void sendFileMessage({ required BuildContext context, required File file, required String receiverUserId, required MessageEnum messageEnum }) async {
    final userData = ref.watch(authControllerProvider).user;
    chatRepository.sendFileMessage(
      context: context, file: file, receiverUserId: receiverUserId, 
      senderUserData: userData!, messageEnum: messageEnum
    );
  }

  Stream<List<ChatModel>> getContacts () {
    return chatRepository.getContacts();
  }

  Stream<List<MessageModel>> getMessages (String receiverUserId) {
    return chatRepository.getMessages(receiverUserId);
  }
  
  Stream<List<UserModel>> getUsers () {
    return chatRepository.getUsers();
  }
}

final chatControllerProvider = Provider<ChatController>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});