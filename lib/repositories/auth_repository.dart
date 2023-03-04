// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/auth_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/firestore_repository.dart';
import 'package:flutter_chatapp_firebase/utils/utils.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final Ref ref;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.ref,
    required this.firestore,
  });

  Future<UserModel?> getCurrentUserData() async {
    var userData = await firestore.collection('users').doc(auth.currentUser?.uid).get();

    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(phoneNumber: phoneNumber, 
         verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          context.go('/otp?verificationId=$verificationId');
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOTP(BuildContext context, String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await auth.signInWithCredential(credential);

      if (context.mounted) {
        UserModel? user = await getCurrentUserData();
        if (user != null) {
          ref.read(authControllerProvider.notifier).state = AuthModel(user: user, authState: AuthState.login);
          if (context.mounted) {
            context.go('/');
          }
        } 
        else {
          if (context.mounted) {
            context.go('/user-info');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void signInWithGithub(BuildContext context) async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();

      if (kIsWeb) {
        await auth.signInWithPopup(githubProvider);
      }
      else {
        await auth.signInWithProvider(githubProvider);
      }

      if (context.mounted) {
        UserModel? user = await getCurrentUserData();
        if (user != null) {
          ref.read(authControllerProvider.notifier).state = AuthModel(user: user, authState: AuthState.login);
          if (context.mounted) {
            context.go('/');
          }
        } 
        else {
          if (context.mounted) {
            context.go('/user-info');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
        googleProvider.setCustomParameters({
          'login_hint': 'user@example.com'
        });

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      }
      else {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (context.mounted) {
        UserModel? user = await getCurrentUserData();
        if (user != null) {
          ref.read(authControllerProvider.notifier).state = AuthModel(user: user, authState: AuthState.login);
          if (context.mounted) {
            context.go('/');
          }
        } 
        else {
          if (context.mounted) {
            context.go('/user-info');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void signInWithFacebook(BuildContext context) async {
    try {
      if (kIsWeb) {
        FacebookAuthProvider facebookProvider = FacebookAuthProvider();
        
        facebookProvider.addScope('email');
        facebookProvider.setCustomParameters({
          'display': 'popup',
        });
        await auth.signInWithPopup(facebookProvider);
      }
      else {
        final LoginResult loginResult = await FacebookAuth.instance.login();
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

        await auth.signInWithCredential(facebookAuthCredential);
      }

      if (context.mounted) {
        UserModel? user = await getCurrentUserData();
        if (user != null) {
          ref.read(authControllerProvider.notifier).state = AuthModel(user: user, authState: AuthState.login);
          if (context.mounted) {
            context.go('/');
          }
        } 
        else {
          if (context.mounted) {
            context.go('/user-info');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveUserDataToFirebase(BuildContext context, File? file, String name) async {
    try {
      String uid = auth.currentUser!.uid;
      String imageUrl = '';
      if (file != null) {
        imageUrl = await ref.read(firebaseStoreRepositoryProvider).storeFileToFIrebase('profilePic/$uid', file);
      }

      UserModel user = UserModel(
        name: name, 
        uid: uid, 
        profilePic: imageUrl, 
        isOnline: true, 
        phoneNumber: auth.currentUser!.phoneNumber ?? "", 
        groupId: []
      );

      firestore.collection('users').doc(uid).set(user.toMap());

      ref.read(authControllerProvider.notifier).state = AuthModel(user: user, authState: AuthState.login);
      if (context.mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  Stream<UserModel> userDataById(String uid) {
    return firestore.collection('users')
      .doc(uid).snapshots()
      .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }
}

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance, ref: ref);
});