import 'package:flutter/widgets.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class SywlVideoPlayer extends StatefulWidget {
  SywlVideoPlayer({Key key, this.width = 3, this.height = 2}) : super(key: key);

  final double width;

  final double height;

  @override
  State<StatefulWidget> createState() => _SywlVideoPlayerState();
}

class _SywlVideoPlayerState extends State<SywlVideoPlayer> {

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(
        'http://vfx.mtime.cn/Video/2019/03/14/mp4/190314102306987969.mp4');
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: widget.width / widget.height,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: chewieController,
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }
}
