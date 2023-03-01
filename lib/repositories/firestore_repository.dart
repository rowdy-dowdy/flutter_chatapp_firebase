import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStoreRepository {
  final FirebaseStorage firebaseStore;

  FirebaseStoreRepository({
    required this.firebaseStore,
  });

  Future<String> storeFileToFIrebase(String ref, File file) async {
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    UploadTask uploadTask;

    if (kIsWeb) {
      XFile fileUpload = XFile(file.path); 
      uploadTask = firebaseStore.ref().child(ref).putData(await fileUpload.readAsBytes(), metadata);
    } else {
      uploadTask = firebaseStore.ref().child(ref).putFile(file, metadata);
    }

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}

final firebaseStoreRepositoryProvider = Provider((ref) {
  return FirebaseStoreRepository(firebaseStore: FirebaseStorage.instance);
});