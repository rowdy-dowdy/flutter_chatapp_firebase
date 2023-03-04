// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/repositories/firestore_repository.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final Ref ref;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ChatRepository({
    required this.ref,
    required this.auth,
    required this.firestore,
  });
  
  Stream<List<ChatModel>> getContacts () {
    return firestore.collection('users').doc(auth.currentUser?.uid)
      .collection('chats')
      .snapshots().asyncMap((event) async {
        List<ChatModel> contacts = [];

        for (var document in event.docs) {
          var contact = ChatModel.fromMap(document.data());
          var userData = await firestore.collection('users')
            .doc(contact.contactId)
            .get();
          UserModel user = UserModel.fromMap(userData.data()!);

          contacts.add(ChatModel(
            name: user.name, 
            profilePic: user.profilePic, 
            contactId: contact.contactId, 
            timeSent: contact.timeSent, 
            lastMessage: contact.lastMessage)
          );
        }

        return contacts;
      }
    );
  }

  Stream<List<MessageModel>> getMessages (String receiverUserId) {
    return firestore.collection('users')
      .doc(auth.currentUser!.uid).collection('chats').doc(receiverUserId)
      .collection('messages').orderBy('timeSent', descending: false).snapshots().map((event) {
        List<MessageModel> messages = [];
        for(var document in event.docs) {
          messages.add(MessageModel.fromMap(document.data()));
        }
        return messages;
      });
  }

  Stream<List<UserModel>> getUsers () {
    return firestore.collection('users').snapshots().map((event) {
      List<UserModel> users = [];
      for(var document in event.docs) {
        var userTemp = UserModel.fromMap(document.data());
        if (userTemp.uid != auth.currentUser!.uid) {
          users.add(userTemp);
        }
      }
      return users;
    });
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required MessageEnum messageEnum
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref.read(firebaseStoreRepositoryProvider).storeFileToFIrebase('chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId', file);

      UserModel receiverUserData;
      var userDataMap = await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;
      switch(messageEnum) {
        case MessageEnum.image:
          contactMsg = "📷 Photo";
          break;
        case MessageEnum.audio:
          contactMsg = "🔊 Audio";
          break;
        case MessageEnum.video:
          contactMsg = "📹 Video";
          break;
        case MessageEnum.gif:
          contactMsg = "Gif";
          break;
        default:
          contactMsg = "File";
          break;
      }

      saveDataToContactsSubCollection(senderUserData, receiverUserData, contactMsg, timeSent);

      saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId, 
        text: imageUrl, timeSent: timeSent, 
        messageId: messageId, username: senderUserData.name, 
        receiverUserName: receiverUserData.name, 
        messageType: messageEnum
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void sendTextMessage({required BuildContext context, required String text, required String receiverUserId, required UserModel senderUser}) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap = await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      saveDataToContactsSubCollection(senderUser, receiverUserData, text, timeSent);
      saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId, 
        text: text, timeSent: timeSent, 
        messageId: messageId, 
        username: senderUser.name, 
        receiverUserName: receiverUserData.name, 
        messageType: MessageEnum.text
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveDataToContactsSubCollection(UserModel senderUserData, UserModel receiverUserData, String lastMessage, DateTime timeSent) async {
    var receiverChat = ChatModel(
      name: senderUserData.name, 
      profilePic: senderUserData.profilePic, 
      contactId: senderUserData.uid, 
      timeSent: timeSent, 
      lastMessage: lastMessage
    );

    await firestore.collection('users').doc(receiverUserData.uid).collection('chats').doc(auth.currentUser!.uid)
      .set(receiverChat.toMap());

    var senderChat = ChatModel(
      name: receiverUserData.name, 
      profilePic: receiverUserData.profilePic, 
      contactId: receiverUserData.uid, 
      timeSent: timeSent, 
      lastMessage: lastMessage
    );

    await firestore.collection('users').doc(auth.currentUser!.uid).collection('chats').doc(receiverUserData.uid)
      .set(senderChat.toMap());
  }

  void saveMessageToMessageSubCollection({
    required String receiverUserId, 
    required String text, 
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String receiverUserName,
    required MessageEnum messageType
  }) async {
    final message = MessageModel(
      senderId: auth.currentUser!.uid, 
      receiverId: receiverUserId, 
      text: text, 
      type: messageType, 
      timeSent: timeSent, 
      messageId: messageId, 
      isSeen: false, 
      repliedMessage: "repliedMessage", 
      repliedTo: "repliedTo", 
      repliedMessageType: messageType
    );

    await firestore.collection('users').doc(auth.currentUser!.uid).collection('chats')
      .doc(receiverUserId).collection('messages').doc(messageId).set(message.toMap());

    await firestore.collection('users').doc(receiverUserId).collection('chats')
      .doc(auth.currentUser!.uid).collection('messages').doc(messageId).set(message.toMap());
  }
  
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance, ref: ref);
});