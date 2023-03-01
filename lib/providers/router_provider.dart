import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
import 'package:flutter_chatapp_firebase/pages/landing_page.dart';
import 'package:flutter_chatapp_firebase/pages/login_page.dart';
import 'package:flutter_chatapp_firebase/pages/otp_page.dart';
import 'package:flutter_chatapp_firebase/pages/user_info_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // _ref.listen(authProvider, 
    // (_, __) => notifyListeners());
  }

  // String? _redirect_login(_, GoRouterState state) {
  //   final authSate = _ref.read(authProvider).authSate;
    
  //   if (authSate == AuthSate.initial) return null;

  //   final are_we_loggin_in = state.location == "/login";

  //   if (authSate != AuthSate.login) {
  //     if (state.location == '/loading') {

  //     }
  //     return are_we_loggin_in ? null : '/login';
  //   }

  //   if (are_we_loggin_in || state.location == '/loading') return '/';

  //   return null;    
  // }

  List<RouteBase> get _routers => [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'landing',
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'otp',
      path: '/otp',
      builder: (context, state) => OTPPage(verificationId: state.queryParams['verificationId']!),
    ),
    GoRoute(
      name: 'user-info',
      path: '/user-info',
      builder: (context, state) => const UserInfoPage(),
    ),
  ];
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/landing',
    debugLogDiagnostics: true,
    refreshListenable: router,
    // redirect: router._redirect_login,
    routes: router._routers
  );
});