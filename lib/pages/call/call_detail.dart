import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CallDetailPage extends ConsumerWidget {
  final String id;
  const CallDetailPage({required this.id, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const GetAppBar(),
      backgroundColor: primary,
      body: SafeArea(
        child: const GetBody()
      ),
      bottomNavigationBar: const GetBottomBar(),
    );
  }
}


class GetAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final double height;
  const GetAppBar({this.height = 60, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetAppBarState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class _GetAppBarState extends ConsumerState<GetAppBar> {
  final searchController = TextEditingController();

  Timer? _timer;
  Duration _start = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          _start += const Duration(seconds: 1);
        });
      },
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
      ),
      centerTitle: true,
      title: Column(
        children: [
          const Text("Việt Hùng", style: TextStyle(fontSize: 18, color: Colors.white),),
          const SizedBox(height: 3,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)
            ),
            child: Text(_printDuration(_start), style: const TextStyle(
              fontSize: 12,
              color: Colors.red
            ),),
          )
        ],
      ),
    );
  }
}

class GetBottomBar extends ConsumerWidget {
  const GetBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.center,
            child: const FaIcon(FontAwesomeIcons.cameraRotate, color: primary4,),
          ),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.center,
            child: const FaIcon(FontAwesomeIcons.videoSlash, color: primary2,),
          ),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.center,
            child: const FaIcon(FontAwesomeIcons.microphoneSlash, color: primary2,),
          ),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: primary3
            ),
            alignment: Alignment.center,
            child: const FaIcon(Icons.call_end_rounded, color: Colors.red,),
          )
        ],
      ),
    );
  }
}

class GetBody extends ConsumerStatefulWidget {
  const GetBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetBodyState();
}

class _GetBodyState extends ConsumerState<GetBody> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: primary4,
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        Positioned(
          bottom: 15,
          right: 30,
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10)
            )
          ),
        )
      ],
    );
  }
}