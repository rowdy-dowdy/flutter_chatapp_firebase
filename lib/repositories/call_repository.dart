// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/call_model.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/repositories/firestore_repository.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CallRepository {
  final Ref ref;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CallRepository({
    required this.ref,
    required this.auth,
    required this.firestore,
  });
  
  Stream<List<CallModel>> getCalls () {
    return firestore.collection('users')
      .doc(auth.currentUser!.uid).collection('calls').orderBy('timeCall', descending: false).snapshots().map((event) {
        List<CallModel> calls = [];
        for(var document in event.docs) {
          calls.add(CallModel.fromMap(document.data()));
        }
        return calls;
      });
  }
  
  Stream<DocumentSnapshot> get callStream =>
    firestore.collection('calls').doc(auth.currentUser!.uid).snapshots();

  void makeCall(
    CallModel senderCallData,
    BuildContext context,
    CallModel receiverCallData,
  ) async {
    try {
      await firestore
        .collection('calls')
        .doc(senderCallData.callerId)
        .set(senderCallData.toMap());
      await firestore
        .collection('calls')
        .doc(senderCallData.receiverId)
        .set(receiverCallData.toMap());

      if (context.mounted) {
        context.go('/calls/${senderCallData.callId}');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void calling(
    CallModel senderCallData,
    CallModel receiverCallData,
    BuildContext context,
  ) async {
    try {
      CallModel senderCallDataValue =  senderCallData.copyValueWithStatus(CallEnum.calling);
      CallModel receiverCallDataValue =  receiverCallData.copyValueWithStatus(CallEnum.calling);

      await firestore.collection('calls').doc(senderCallData.callerId).set(senderCallDataValue.toMap());
      await firestore.collection('calls').doc(receiverCallData.receiverId).set(receiverCallDataValue.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
    CallModel senderCallData,
    CallModel receiverCallData,
    BuildContext context,
  ) async {
    try {
      CallModel senderCallDataValue =  senderCallData.copyValueWithStatus(CallEnum.stoppedCalling);
      CallModel receiverCallDataValue =  receiverCallData.copyValueWithStatus(CallEnum.stoppedCalling);

      await firestore.collection('calls').doc(senderCallData.callerId).set(senderCallDataValue.toMap());
      await firestore.collection('calls').doc(receiverCallData.receiverId).set(receiverCallDataValue.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepository(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance, ref: ref);
});