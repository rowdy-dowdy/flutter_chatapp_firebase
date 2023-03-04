import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/layouts/main_layout.dart';
import 'package:flutter_chatapp_firebase/models/auth_model.dart';
import 'package:flutter_chatapp_firebase/pages/call_page.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
import 'package:flutter_chatapp_firebase/pages/landing_page.dart';
import 'package:flutter_chatapp_firebase/pages/loading_page.dart';
import 'package:flutter_chatapp_firebase/pages/login_page.dart';
import 'package:flutter_chatapp_firebase/pages/message_page.dart';
import 'package:flutter_chatapp_firebase/pages/otp_page.dart';
import 'package:flutter_chatapp_firebase/pages/people_page.dart';
import 'package:flutter_chatapp_firebase/pages/setting_page.dart';
import 'package:flutter_chatapp_firebase/pages/user_info_page.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  final List<String> loginPages = ["/landing", "/login", "/otp", "/user-info"];

  RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, 
    (_, __) => notifyListeners());
  }

  String? _redirectLogin(_, GoRouterState state) {
    final authSate = _ref.read(authControllerProvider).authState;
    
    if (authSate == AuthState.initial) return null;

    final areWeLoginIn = loginPages.indexWhere((e) => e == state.subloc);

    if (authSate != AuthState.login) {
      return areWeLoginIn >= 0 ? null : '/landing';
    }

    if (areWeLoginIn >= 0 || state.subloc == "/loading") return '/';

    return null;    
  }

  List<RouteBase> get _routers => [
    GoRoute(
      name: 'loading',
      path: '/loading',
      builder: (context, state) => const LoadingPage(),
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
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'chat',
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              name: 'chat-detail',
              path: 'chats/:id',
              builder: (context, state) => MessagePage(id: state.params['id']),
            ),
          ]
        ),
        GoRoute(
          name: 'calls',
          path: '/calls',
          builder: (context, state) => const CallPage(),
        ),
        GoRoute(
          name: 'people',
          path: '/people',
          builder: (context, state) => const PeoplePage(),
        ),
        GoRoute(
          name: 'settings',
          path: '/settings',
          builder: (context, state) => const SettingPage(),
        ),
      ]
    )
  ];
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: router,
    // redirect: router._redirectLogin,
    routes: router._routers
  );
});