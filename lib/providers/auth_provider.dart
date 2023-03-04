// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/auth_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// class AuthController {
//   final AuthRepository authRepository;

//   AuthController({
//     required this.authRepository,
//   });

//   Future<UserModel?> getCurrentUserData() async {
//     return await authRepository.getCurrentUserData();
//   }

//   void signInWithPhone(BuildContext context, String phoneNumber) {
//     authRepository.signInWithPhone(context, phoneNumber);
//   }

//   void verifyOTP(BuildContext context, String verificationId, String smsCode) {
//     authRepository.verifyOTP(context, verificationId, smsCode);
//   }

//   void saveUserDataToFirebase(BuildContext context, File? file, String name) async {
//     authRepository.saveUserDataToFirebase(context, file, name);
//   }
// }

// final authControllerProvider = Provider((ref) {
//   final authRepository = ref.watch(authRepositoryProvider);
//   return AuthController(authRepository: authRepository);
// });

// final userDataAuthProvider = FutureProvider((ref) async {
//   final authController = ref.watch(authControllerProvider);
//   return authController.getCurrentUserData();
// });

class AuthNotifier extends StateNotifier<AuthModel> {
  final Ref ref;
  AuthNotifier(this.ref): super(const AuthModel.unknown()) {
    getCurrentUserData();
  }
  
  void getCurrentUserData() async {
    // state = state.changeState(AuthState.loading);
    UserModel? user = await ref.read(authRepositoryProvider).getCurrentUserData();

    if (user != null) {
      state = AuthModel(user: user, authState: AuthState.login);
    }
    else {
      state = AuthModel(user: null, authState: AuthState.notLogin);
    }
  }

  // void signInWithPhone(BuildContext context, String phoneNumber) {
  //   ref.read(authRepositoryProvider).signInWithPhone(context, phoneNumber);
  //   if (context.mounted) {
  //     context.go('/user-info');
  //   }
  // }

  void verifyOTP(BuildContext context, String verificationId, String smsCode) {
    ref.read(authRepositoryProvider).verifyOTP(context, verificationId, smsCode);
  }

  void setUserState(bool isOnline) async {
    ref.read(authRepositoryProvider).setUserState(isOnline);
  }

  // void saveUserDataToFirebase(BuildContext context, File? file, String name) async {
  //   ref.read(authRepositoryProvider).saveUserDataToFirebase(context, file, name);
  // }
}

final authControllerProvider = StateNotifierProvider<AuthNotifier, AuthModel>((ref) {
  return AuthNotifier(ref);
});