import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chatapp_firebase/providers/router_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Flutter Chat App',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          foregroundColor: primary
        ),
        // scaffoldBackgroundColor: primary4,
        // primarySwatch: primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primary2,
        ),
        primaryColor: primary,
        indicatorColor: primary2,
        primaryColorLight: primary,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary2,
            minimumSize: const Size(double.infinity, 48),
            elevation: 0.0,
            shadowColor: Colors.transparent,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary
          )
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: primary),
        ),
        iconTheme: const IconThemeData(
          color: primary
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: primary),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid, 
              color: primary
          ),
          )
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: primary,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary2
        )
      ),
      // darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}