import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/call_model.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/auth_provider.dart';
import 'package:flutter_chatapp_firebase/providers/call_provider.dart';
import 'package:flutter_chatapp_firebase/services/signaling.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallDetailPage extends ConsumerWidget {
  final String id;
  const CallDetailPage({required this.id, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(authControllerProvider).user;
    // return CallingDetail();
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          CallModel call = CallModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          var isMeCall = false;

          if (userData!.uid == call.callId) {
            isMeCall = true;
          }

          if (call.status == CallEnum.stoppedCalling) {
            return CallDetailEnd(call: call);
          }
          else if (call.status == CallEnum.startCalling) {
            return CallDetailNew(call: call, isMeCall: isMeCall);
          }
          else {
            return CallingDetail(call: call, isMeCall: isMeCall);
          }
        }

        return Container();
      },
    );
  }
}

class CallDetailNew extends ConsumerWidget {
  final CallModel call; 
  final bool isMeCall;
  const CallDetailNew({required this.call, required this.isMeCall, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // color: Colors.red,
              image: DecorationImage(
                image: NetworkImage(call.receiverPic),
                fit: BoxFit.cover,
              )
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primary2,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(call.receiverPic)
                          )
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(call.receiverName),
                      const SizedBox(height: 3,),
                      const Text("Incoming call", style: TextStyle(fontSize: 12),),
                    ],
                  ),
                ),
              ),
            ),
          ),
          !isMeCall ? Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => ref.watch(callControllerProvider).endCall(call, context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.call_end_rounded, color: Colors.white,),
                  ),
                ),
                InkWell(
                  onTap: () => ref.watch(callControllerProvider).calling(call, context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: primary2,
                      shape: BoxShape.circle
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.call, color: Colors.white,),
                  ),
                )
              ],
            ),
          ) : Container()
        ],
      ),
    );
  }
}

class CallDetailEnd extends ConsumerWidget {
  final CallModel call; 
  const CallDetailEnd({required this.call, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(call.callerPic)
              )
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(call.callerPic)
                          )
                        ),
                      ),
                      const SizedBox(height: 5,),
                      const Text("Call end"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallingDetail extends ConsumerWidget {
  final CallModel call;
  final bool isMeCall;
  const CallingDetail({required this.call, required this.isMeCall, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: GetAppBar(),
      backgroundColor: primary,
      body: SafeArea(
        child: GetBody(call:call, isMeCall: isMeCall)
      ),
      bottomNavigationBar: GetBottomBar(call:call),
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
  final CallModel call;
  const GetBottomBar({required this.call, super.key});

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
          InkWell(
            onTap: () => ref.watch(callControllerProvider).endCall(call, context),
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: primary3
              ),
              alignment: Alignment.center,
              child: const FaIcon(Icons.call_end_rounded, color: Colors.red,),
            ),
          )
        ],
      ),
    );
  }
}

class GetBody extends ConsumerStatefulWidget {
  final CallModel call;
  final bool isMeCall;
  const GetBody({required this.call, required this.isMeCall, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetBodyState();
}

class _GetBodyState extends ConsumerState<GetBody> {
  Signaling? signaling;
  final RTCVideoRenderer _localRender = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRender = RTCVideoRenderer();

  @override
  void initState() {
    _localRender.initialize();
    _remoteRender.initialize();

    signaling = ref.read(signalingProvider);

    signaling!.onAddRemoteStream = ((stream) {
      _remoteRender.srcObject = stream;
      setState(() {});
    });

    if (widget.isMeCall) {
      signaling!.createRoom(_remoteRender, widget.call.roomId);
    }
    else {
      signaling!.joinRoom(_remoteRender, widget.call.roomId);
    }

    signaling!.openUserMedia(_localRender, _remoteRender);
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _localRender.dispose();
    _remoteRender.dispose();
    signaling!.hangUp(_localRender);
    super.dispose();
  }

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
          clipBehavior: Clip.hardEdge,
          child: RTCVideoView(
            _remoteRender,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
            ),
            clipBehavior: Clip.hardEdge,
            // alignment: Alignment.center,
            child: RTCVideoView(
              _localRender, 
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        )
      ],
    );
  }
}