import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class FirebaseStoreRepository {
  final FirebaseStorage firebaseStore;

  FirebaseStoreRepository({
    required this.firebaseStore,
  }) {
    // init();
  }

  void init() async {
    final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      ? '10.0.2.2'
      : 'localhost';
    await firebaseStore.useStorageEmulator(emulatorHost, 9199);
  }

  Future<String> storeFileToFIrebase(String ref, Uint8List file) async {
    final mime = lookupMimeType('', headerBytes: file);
    final metadata = SettableMetadata(
      contentType: mime,
    );
    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = firebaseStore.ref().child(ref).putData(file, metadata);
    } else {
      uploadTask = firebaseStore.ref().child(ref).putData(file, metadata);
    }

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }
}

final firebaseStoreRepositoryProvider = Provider((ref) {
  return FirebaseStoreRepository(firebaseStore: FirebaseStorage.instance);
});