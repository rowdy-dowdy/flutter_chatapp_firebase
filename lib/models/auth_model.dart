// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/repositories/auth_repository.dart';

enum AuthState {
  initial,
  login,
  notLogin
}

class AuthModel {
  final AuthState authState;
  final UserModel? user;
  
  AuthModel({
    required this.user,
    required this.authState,
  });

  const AuthModel.unknown()
    : authState = AuthState.initial,
      user = null;

  AuthModel changeState (AuthState authState) {
    return AuthModel(user: user, authState: authState);
  }
}
