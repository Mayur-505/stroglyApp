import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;
  final bool isMuted;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.isPlaying,
    required this.isMuted,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initController(widget.videoUrl);
    } else {
      if (_isInitialized && _controller != null) {
        _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
        if (widget.isPlaying && !_controller!.value.isPlaying) {
          _controller!.play();
        } else if (!widget.isPlaying && _controller!.value.isPlaying) {
          _controller!.pause();
        }
      }
    }
  }

  Future<void> _initController(String url) async {
    final oldController = _controller;
    if (oldController != null) {
      await oldController.pause();
      oldController.dispose();
    }
    setState(() {
      _isInitialized = false;
      _controller = null;
    });

    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await newController.initialize();
      newController.setLooping(true);
      newController.setVolume(widget.isMuted ? 0.0 : 1.0);
      if (mounted) {
        setState(() {
          _controller = newController;
          _isInitialized = true;
        });
        if (widget.isPlaying) {
          newController.play();
        }
      } else {
        newController.dispose();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
