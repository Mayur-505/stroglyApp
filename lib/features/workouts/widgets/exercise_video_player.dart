import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/widgets/app_image.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? posterImagePath;
  final bool isPlaying;
  final bool isMuted;
  final VoidCallback? onReady;
  final ValueChanged<bool>? onBuffering;
  final VideoPlayerController? preloadedController;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoUrl,
    this.posterImagePath,
    required this.isPlaying,
    required this.isMuted,
    this.onReady,
    this.onBuffering,
    this.preloadedController,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _ownsController = true;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _setupController();
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

  Future<void> _setupController() async {
    // If a preloaded controller was provided for this exact URL and is ready:
    if (widget.preloadedController != null &&
        widget.preloadedController!.value.isInitialized &&
        (widget.preloadedController!.dataSource == widget.videoUrl ||
            widget.preloadedController!.dataSource.contains(widget.videoUrl))) {
      final old = _controller;
      if (old != null && _ownsController) {
        old.dispose();
      }
      _controller = widget.preloadedController;
      _ownsController = false;
      _isInitialized = true;
      _attachListeners(_controller!);
      if (mounted) {
        setState(() {});
        widget.onReady?.call();
        if (widget.isPlaying) {
          _controller!.play();
        }
      }
      return;
    }

    _initController(widget.videoUrl);
  }

  void _attachListeners(VideoPlayerController controller) {
    controller.addListener(() {
      if (!mounted) return;
      final buffering = controller.value.isBuffering;
      if (buffering != _isBuffering) {
        setState(() {
          _isBuffering = buffering;
        });
        widget.onBuffering?.call(buffering);
      }
    });
  }

  Future<void> _initController(String url) async {
    final oldController = _controller;
    if (oldController != null && _ownsController) {
      await oldController.pause();
      oldController.dispose();
    }
    setState(() {
      _isInitialized = false;
      _controller = null;
      _ownsController = true;
    });

    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await newController.initialize();
      newController.setLooping(true);
      newController.setVolume(widget.isMuted ? 0.0 : 1.0);
      _attachListeners(newController);
      if (mounted) {
        setState(() {
          _controller = newController;
          _isInitialized = true;
        });
        widget.onReady?.call();
        if (widget.isPlaying) {
          newController.play();
        }
      } else {
        newController.dispose();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      // If error occurs, still fire onReady so exercise countdown doesn't get blocked
      widget.onReady?.call();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Poster image preview while video initializes
          if (widget.posterImagePath != null && widget.posterImagePath!.isNotEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: AppImage(
                  imagePath: widget.posterImagePath!,
                  fit: BoxFit.contain,
                  memCacheWidth: 600,
                  errorWidget: const Icon(Icons.fitness_center_rounded, size: 60),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

          // Only clean circular loader (no text)
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00)),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        // Only circular loader if buffering and not playing
        if (_isBuffering && !_controller!.value.isPlaying)
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00)),
              ),
            ),
          ),
      ],
    );
  }
}

