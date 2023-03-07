import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chatapp_firebase/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

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

class _AudioMessageState extends ConsumerState<AudioMessage> {
  late PlayerController controller;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    initPlayerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initPlayerController() async {
    final duration = await player.setUrl(widget.message);
    await player.play();
  }

  void startAndStopAudio() async {
    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      topRight: !widget.isMe ? const Radius.circular(18) : widget.isFirst ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: !widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6),
      bottomLeft: widget.isMe ? const Radius.circular(18) : widget.isLast ? const Radius.circular(18) : const Radius.circular(6)
    );

    return Container(
      color: Colors.red,
      // child: AudioFileWaveforms(
      //   size: Size(240, 30),
      //   playerController: controller,
      //   playerWaveStyle: const PlayerWaveStyle(
      //     scaleFactor: 0.8,
      //     fixedWaveColor: Colors.white30,
      //     liveWaveColor: Colors.white,
      //     waveCap: StrokeCap.butt,
      //   ),
      // ),
    );

    return Stack(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: widget.bgColor.withOpacity(0.7),
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: InkWell(
            onTap: startAndStopAudio,
            child: AudioFileWaveforms(
              size: Size(240, 30),
              playerController: controller,
              playerWaveStyle: const PlayerWaveStyle(
                scaleFactor: 0.8,
                fixedWaveColor: Colors.white30,
                liveWaveColor: Colors.white,
                waveCap: StrokeCap.butt,
              ),
            )
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