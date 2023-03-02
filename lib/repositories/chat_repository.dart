// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ChatRepository({
    required this.auth,
    required this.firestore,
  });
  
  Stream<List<ContactModel>> getContacts () {
    return firestore.collection('users').doc(auth.currentUser?.uid)
      .collection('chats')
      .snapshots().asyncMap((event) async {
        List<ContactModel> contacts = [];

        for (var document in event.docs) {
          var contact = ContactModel.fromMap(document.data());
          var userData = await firestore.collection('users')
            .doc(contact.contactId)
            .get();
          UserModel user = UserModel.fromMap(userData.data()!);

          contacts.add(ContactModel(
            name: user.name, 
            profilePic: user.profilePic, 
            contactId: contact.contactId, 
            timeSent: contact.timeSent, 
            lastMessage: contact.lastMessage)
          );
        }

        return contacts;
      });
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
});