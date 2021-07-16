import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_viewer/data/repositories/video.dart';

class VideoCoreOrientation extends StatelessWidget {
  const VideoCoreOrientation({Key? key, required this.builder})
      : super(key: key);

  final Widget Function(bool) builder;

  void _setPreferredOrientation(BuildContext context) {
    final video = VideoQuery().video(context, listen: false);
    if (video.isFullScreen) {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    } else {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext _) {
    return OrientationBuilder(builder: (context, Orientation orientation) {
      final video = VideoQuery().video(context, listen: false);
      debugPrint('isVideoFullScreen: ${video.isFullScreen}');
      debugPrint('Orientation: $orientation');
      _setPreferredOrientation(context);
      
      return builder(
        video.isFullScreen && orientation == Orientation.landscape,
      );
    });
  }
}
