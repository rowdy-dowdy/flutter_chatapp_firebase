import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({required this.child, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>  with WidgetsBindingObserver, TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      window.addEventListener('visibilitychange', onVisibilityChange);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      window.addEventListener('visibilitychange', onVisibilityChange);
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  void onVisibilityChange(Event e) {
    if (document.visibilityState == "visible") {
      didChangeAppLifecycleState(AppLifecycleState.resumed);
    }
    else {
      didChangeAppLifecycleState(AppLifecycleState.paused);
    }
    // didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider.notifier).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}