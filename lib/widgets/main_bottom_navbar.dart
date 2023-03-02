import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/providers/router_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  static const menu = <Map>[
    {
      "icon": Icons.message_rounded,
      "path": "/",
    },
    {
      "icon": Icons.call_rounded,
      "path": "/calls",
    },
    {
      "icon": Icons.people_rounded,
      "path": "/people",
    },
    {
      "icon": Icons.settings,
      "path": "/settings",
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final location = ref.watch(routerProvider).location;
    
    return Container(
      height: 60,
      width: double.infinity,
      // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(40)
      ),
      // alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for(var i = 0; i < menu.length; i++)...[
            InkWell(
              onTap: () => context.go(menu[i]['path']),
              child: i == 0
                ? badges.Badge(
                  badgeContent: const Text("3", style: TextStyle(color: Colors.white),),
                  child: Icon(
                    menu[i]['icon'],
                    size: 30,
                    color: location != menu[i]['path'] ? primary2 : Colors.white
                  ),
                )
                : Icon(
                  menu[i]['icon'],
                  size: 30,
                  color: location != menu[i]['path'] ? primary2 : Colors.white
                ),
            ),
            if (i < menu.length - 1) ...[
              Container(
                width: 2,
                height: 30,
                decoration: const BoxDecoration(color: primary2),
              )
            ]
          ],
        ],
      ),
    );
  }
}