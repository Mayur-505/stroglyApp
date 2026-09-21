import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'app_image.dart';

/// Seamless exercise video player with automatic looping, error fallback,
/// and instant fallback to AppImage when video is loading or unavailable.
class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String imagePath;
  final bool isPlaying;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.imagePath,
    this.isPlaying = true,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      _initPlayer();
    } else if (_isInitialized && _controller != null) {
      if (widget.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!widget.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  Future<void> _initPlayer() async {
    final cleanUrl = widget.videoUrl.trim();
    if (cleanUrl.isEmpty) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
      return;
    }

    try {
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
      } else {
        _controller = VideoPlayerController.asset(cleanUrl);
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0); // Muted by default so workout voice/beeps are clear

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        if (widget.isPlaying) {
          _controller!.play();
        }
      }
    } catch (e) {
      debugPrint('[ExerciseVideoPlayer] Failed to load video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
        });
      }
    }
  }

  void _disposePlayer() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null && !_hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio > 0
                ? _controller!.value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    // Fallback to static photo / illustration
    return AppImage(
      imagePath: widget.imagePath,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorWidget: const Icon(
        Icons.fitness_center_rounded,
        size: 80,
        color: Color(0xFF141416),
      ),
    );
  }
}
