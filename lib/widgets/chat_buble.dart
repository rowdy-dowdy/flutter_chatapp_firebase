import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_chatapp_firebase/widgets/audio_waveform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CustomBubbleChat extends ConsumerWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isLast;
  final bool isFirst;
  final MessageEnum messageEnum;
  const CustomBubbleChat({required this.message, required this.time, required this.isLast, required this.isFirst, required this.messageEnum, this.isMe = true, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color bgColor = isMe ? primary2 : primary3;
    final Color textColor = isMe ? primary4 : primary;
    final size = MediaQuery.of(context).size;
    
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            decoration: const BoxDecoration(),
            clipBehavior: Clip.hardEdge,

            child: messageEnum == MessageEnum.text 
              ? TextMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : messageEnum == MessageEnum.image ? ImageMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : messageEnum == MessageEnum.video ? VideoMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : messageEnum == MessageEnum.audio ? AudioMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : messageEnum == MessageEnum.gif ? GifMessage(
                bgColor: bgColor, isFirst: isFirst, 
                isLast: isLast, isMe: isMe,
                message: message, textColor: textColor, time: time
              )
              : const NotSupportExtensions()
          ),
        ),
      ]
    );
  }
}

class TextMessage extends ConsumerWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;
  const TextMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned(
          top: -36,
          bottom: -36,
          left: -36,
          right: -36,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                width: 36,
                color: Colors.white
              ),
              borderRadius: BorderRadius.only(
                topLeft: isMe ? const Radius.circular(56) : isFirst ? const Radius.circular(56) : const Radius.circular(42),
                topRight: !isMe ? const Radius.circular(56) : isFirst ? const Radius.circular(56) : const Radius.circular(42),
                bottomRight: !isMe ? const Radius.circular(56) : isLast ? const Radius.circular(56) : const Radius.circular(42),
                bottomLeft: isMe ? const Radius.circular(56) : isLast ? const Radius.circular(56) : const Radius.circular(42)
              )
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              margin: isMe ? const EdgeInsets.only(right: 45) : null,
              child: Text(message, style: TextStyle(color: textColor ),)
            ),
            isMe ? Positioned(
              bottom: 4,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time,style: TextStyle(
                    fontSize: 10, 
                    color: Colors.white.withOpacity(0.6))
                  ),
                  const SizedBox(width: 5,),
                  Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
                ],
              ),
            ) : const SizedBox(),
          ],
        ),
      ],
    );
  }
}

class ImageMessage extends ConsumerWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;

  const ImageMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.7),
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 200
          ),
          child: ClipRRect(borderRadius: borderRadius, child: CachedNetworkImage(
            imageUrl: message,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Container(
              width: 110,
              height: 40,
              margin: const EdgeInsets.only(right: 45),
              alignment: Alignment.center,
              child: Row(
                children: const [
                  SizedBox(width: 10,),
                  Icon(Icons.error, color: Colors.white,),
                  SizedBox(width: 5,),
                  Text("Image error", style: TextStyle(fontSize: 11, color: Colors.white),)
                ],
              )
            ),
          )),
        ),
        isMe ? Positioned(
          bottom: 4,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time,style: TextStyle(
                fontSize: 10, 
                color: Colors.white.withOpacity(0.6))
              ),
              const SizedBox(width: 5,),
              Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
            ],
          ),
        ) : const SizedBox(),
      ],
    );
  }
}

class VideoMessage extends ConsumerStatefulWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;

  const VideoMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoMessageState();
}

class _VideoMessageState extends ConsumerState<VideoMessage> {
  late VideoPlayerController _controller;
  // late ChewieController chewieController;
  late bool videoPlaying = false;

  @override
  void initState() {
    super.initState();
    initVideoController();
  }

  @override
  void dispose() {
    _controller.dispose();
    // chewieController.dispose();
    super.dispose();
  }

  void initVideoController() async {
    _controller = VideoPlayerController.network(widget.message)
      ..addListener(() {
        if (!_controller.value.isPlaying &&
          _controller.value.position > Duration.zero &&
          _controller.value.position.inSeconds >= _controller.value.duration.inSeconds &&
          videoPlaying) {
          // completion
          videoPlaying = false;
          _controller.seekTo(Duration.zero);
          setState(() {});
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    // _controller.addListener(() {
    //   if(_controller.value.position == _controller.value.duration) {
    //     setState(() {
    //       videoPlaying = false;
    //     });
    //   }
    // });

    // chewieController = ChewieController(
    //   videoPlayerController: _controller,
    //   autoPlay: true,
    //   looping: true,
    // );
  }

  void playVideo () {
    if (!videoPlaying) {
      videoPlaying = true;
      _controller.play();
    }
    else {
      videoPlaying = false;
      _controller.pause();
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          // width: 300,
          // height: 200,
          decoration: BoxDecoration(
            color: widget.bgColor.withOpacity(0.7),
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 200
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              children: [
                if (_controller.value.isInitialized) ...[
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: playVideo,
                        child: !videoPlaying ? Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: primary3,
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.play_arrow_rounded),
                        ) : Container(),
                      ),
                    ),
                  )
                ]
                else ...[
                  const Center(child: CircularProgressIndicator()),
                ]
              ],
            ),
          )
        ),
        widget.isMe ? Positioned(
          bottom: 4,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.time,style: TextStyle(
                fontSize: 10, 
                color: Colors.white.withOpacity(0.6))
              ),
              const SizedBox(width: 5,),
              Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
            ],
          ),
        ) : const SizedBox(),
      ],
    );
  }
}
class AudioMessage extends ConsumerStatefulWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;

  const AudioMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AudioMessageState();
}

class PositionData {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;

  const PositionData(this.position, this.bufferedPosition, this.duration);
}
class _AudioMessageState extends ConsumerState<AudioMessage> {

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final progressStream = BehaviorSubject<WaveformProgress>();

  Stream<PositionData> get _positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      audioPlayer.positionStream,
      audioPlayer.bufferedPositionStream,
      audioPlayer.durationStream,
      (position, bufferedPosition, duration) => PositionData(
        position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      audioPlayer.stop();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // audio
    audioPlayer.setUrl(widget.message);

    // waveform
    final nameFile = widget.message;
    var file = await DefaultCacheManager().getSingleFile(nameFile);

    // File test = File("${(await getTemporaryDirectory()).path}/$nameFile");
    try {
      final uid = const Uuid().v1();
      final waveFile = File(p.join((await getTemporaryDirectory()).path, '$uid.wave'));
      
      JustWaveform.extract(audioInFile: file, waveOutFile: waveFile)
        .listen(progressStream.add, onError: progressStream.addError);
    } catch (e) {
      print("-----------------------------------------------------------------");
      progressStream.addError(e);
      print("-----------------------------------------------------------------");
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Stack(
      children: [
        Container(
          // height: 60,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5,),
              StreamBuilder(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      width: 20.0,
                      height: 20.0,
                      child: const CircularProgressIndicator(),
                    );
                  }

                  if (playing != true) {
                    return InkWell(
                      onTap: audioPlayer.play,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: primary3,
                          shape: BoxShape.circle
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.play_arrow, size: 16,),
                      ),
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return InkWell(
                      onTap: audioPlayer.pause,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: primary3,
                          shape: BoxShape.circle
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pause, size: 16,),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () => audioPlayer.seek(Duration.zero),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: primary3,
                          shape: BoxShape.circle
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.replay, size: 16,),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10,),
              Container(
                width: 80,
                height: 26,
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: StreamBuilder<WaveformProgress>(
                  stream: progressStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Not load waveforms',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final progress = snapshot.data?.progress ?? 0.0;
                    final waveform = snapshot.data?.waveform;
                    if (waveform == null) {
                      return Center(
                        child: Text(
                          '${(100 * progress).toInt()}%',
                        ),
                      );
                    }
                    return AudioWaveformWidget(
                      waveform: waveform,
                      start: Duration.zero,
                      duration: waveform.duration,
                      waveColor: blue2,
                      strokeWidth: 2,
                      pixelsPerStep: 3,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10,),
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  return Container(
                    margin: const EdgeInsets.only(right: 55),
                    child: Text(_printDuration(snapshot.data?.duration ?? Duration.zero ), 
                      style: TextStyle(color: widget.textColor, fontSize: 12),
                    )
                  );
                },
              ),
            ],
          ),
        ),
        widget.isMe ? Positioned(
          bottom: 4,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.time,style: TextStyle(
                fontSize: 10, 
                color: Colors.white.withOpacity(0.6))
              ),
              const SizedBox(width: 5,),
              Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
            ],
          ),
        ) : const SizedBox(),
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

class GifMessage extends ConsumerWidget {
  final String message;
  final bool isMe;
  final Color textColor;
  final Color bgColor;
  final bool isFirst;
  final bool isLast;
  final String time;

  const GifMessage({
    required this.isMe, 
    required this.message, 
    required this.textColor,
    required this.bgColor,
    required this.isFirst,
    required this.isLast,
    required this.time,
    super.key
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !isMe ? const Radius.circular(18) : isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: isMe ? const Radius.circular(18) : isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.7),
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 200
          ),
          child: Container()
        ),
        isMe ? Positioned(
          bottom: 4,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time,style: TextStyle(
                fontSize: 10, 
                color: Colors.white.withOpacity(0.6))
              ),
              const SizedBox(width: 5,),
              Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.6),)
            ],
          ),
        ) : const SizedBox(),
      ],
    );
  }
}

class NotSupportExtensions extends ConsumerWidget {
  const NotSupportExtensions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 110,
      height: 40,
      margin: const EdgeInsets.only(right: 45),
      alignment: Alignment.center,
      child: Row(
        children: const [
          SizedBox(width: 10,),
          Icon(Icons.error, color: Colors.white,),
          SizedBox(width: 5,),
          Text("Not support extensions", style: TextStyle(fontSize: 11, color: Colors.white),)
        ],
      )
    );
  }
}