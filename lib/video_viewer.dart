library video_viewer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/ui/video_core/video_core.dart';

export 'package:video_viewer/domain/entities/styles/video_viewer.dart';
export 'package:video_viewer/domain/entities/settings_menu_item.dart';
export 'package:video_viewer/domain/entities/video_source.dart';
export 'package:video_viewer/domain/entities/subtitle.dart';
export 'package:video_viewer/domain/entities/language.dart';
export 'package:video_viewer/domain/bloc/controller.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    @required this.source,
    VideoViewerStyle style,
    this.looping = false,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
    this.onFullscreenFixLandscape = false,
    this.language = VideoViewerLanguage.en,
    this.settingsMenuItems,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  /// Once the video is initialized, it will be played
  final bool autoPlay;

  ///Sets whether or not the video should loop after playing once.
  final bool looping;

  /// It is an argument where you can change the design of almost the entire VideoViewer
  final VideoViewerStyle style;

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  /// Receive a list of all the resources to be played.
  ///
  ///SYNTAX EXAMPLE:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  ///```
  final Map<String, VideoSource> source;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool onFullscreenFixLandscape;

  ///It's the custom language can you set to the VideoViewer.
  ///
  ///**EXAMPLE:** SETTING THE SPANISH LANGUAGE TO THE VIDEOVIEWER
  ///```dart
  /// //WAY 1
  /// language: VideoViewerLanguage.es
  /// //WAY 2
  /// language: VideoViewerLanguage(quality: "Calidad", speed: "Velocidad", ...)
  /// //WAY 3
  /// language: VideoViewerLanguage.fromString("es")
  /// ```
  final VideoViewerLanguage language;

  ///ADD CUSTOM SECTIONS TO SETTINGS MENU
  final List<SettingsMenuItem> settingsMenuItems;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  VideoViewerController _controller;
  VideoMetadata _metadata;
  bool _initialized = false;

  VideoViewerController get controller => _controller;
  VideoMetadata get metadata => _metadata;

  @override
  void initState() {
    _metadata = VideoMetadata(
      style: widget.style,
      source: widget.source,
      language: widget.language,
      rewindAmount: widget.rewindAmount,
      forwardAmount: widget.forwardAmount,
      settingsMenuItems: widget.settingsMenuItems,
      defaultAspectRatio: widget.defaultAspectRatio,
      onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
    );
    _initVideoViewer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initVideoViewer() async {
    final activedSource = widget.source.keys.toList().first;
    final source = widget.source.values.toList().first;

    await source.video?.initialize();

    _controller = VideoViewerController(
      isLooping: widget.looping,
      controller: source.video,
      activeSource: activedSource,
    );

    if (source.subtitle != null) {
      final subtitle = source.subtitle.entries.toList().first;
      await subtitle.value?.initialize();
      _controller.changeSubtitle(
        subtitle: subtitle.value,
        subtitleName: subtitle.key,
      );
    }

    if (widget.autoPlay) source.video.play();
    _controller.isShowingThumbnail = widget.style.thumbnail != null;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              ChangeNotifierProvider.value(value: _metadata),
            ],
            builder: (_, __) => VideoViewerCore(),
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: widget.style.loading);
  }
}
