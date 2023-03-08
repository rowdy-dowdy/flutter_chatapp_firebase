// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/call_model.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/call_repository.dart';
import 'package:flutter_chatapp_firebase/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CallController {
  final CallRepository callRepository;
  final Ref ref;

  CallController({
    required this.callRepository,
    required this.ref,
  });

  
  Stream<List<CallModel>> getCalls () {
    return callRepository.getCalls();
  }

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePic, bool isGroupChat) {
        
    final userData = ref.watch(authControllerProvider).user;
    String callId = const Uuid().v1();
    CallModel senderCallData = CallModel(
      callerId: userData!.uid,
      callerName: userData.name,
      callerPic: userData.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: true,
    );

    CallModel receiverCallData = CallModel(
      callerId: userData.uid,
      callerName: userData.name,
      callerPic: userData.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: false,
    );

    callRepository.makeCall(senderCallData, context, receiverCallData);
  }
}

final callControllerProvider = Provider<CallController>((ref) {
  final callRepository = ref.watch(callRepositoryProvider);
  return CallController(callRepository: callRepository, ref: ref);
});