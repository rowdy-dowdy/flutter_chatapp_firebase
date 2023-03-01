// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController {
  final AuthRepository authRepository;

  AuthController({
    required this.authRepository,
  });

  Future<UserModel?> getCurrentUserData() async {
    return await authRepository.getCurrentUserData();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyOTP(BuildContext context, String verificationId, String smsCode) {
    authRepository.verifyOTP(context, verificationId, smsCode);
  }

  void saveUserDataToFirebase(BuildContext context, File? file, String name) async {
    authRepository.saveUserDataToFirebase(context, file, name);
  }
}

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

final userDataProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider);
  return authController.getCurrentUserData();
});