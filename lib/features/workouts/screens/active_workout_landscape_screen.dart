import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../models/exercise_detail_models.dart';
import '../widgets/exercise_video_player.dart';

enum ActiveWorkoutStep {
  exercising,
  paused,
  resting,
  encouragement,
  whyQuit,
}

class ActiveWorkoutLandscapeScreen extends StatefulWidget {
  final int dayNumber;
  final String workoutTitle;
  final int initialExerciseIndex;
  final List<ExerciseDetailItem>? exercises;
  final VoidCallback? onComplete;

  const ActiveWorkoutLandscapeScreen({
    super.key,
    this.dayNumber = 1,
    this.workoutTitle = 'Full Body Burn',
    this.initialExerciseIndex = 0,
    this.exercises,
    this.onComplete,
  });

  @override
  State<ActiveWorkoutLandscapeScreen> createState() =>
      _ActiveWorkoutLandscapeScreenState();
}

class _ActiveWorkoutLandscapeScreenState
    extends State<ActiveWorkoutLandscapeScreen>
    with SingleTickerProviderStateMixin {
  late List<ExerciseDetailItem> _exercises;
  late int _currentIndex;
  ActiveWorkoutStep _currentStep = ActiveWorkoutStep.exercising;

  // Timers & Counters
  int _exerciseSecondsRemaining = 30;
  int _restSecondsRemaining = 20;
  int _overallElapsedSeconds = 37;
  Timer? _tickerTimer;

  // Video readiness & preloading
  bool _isVideoReady = false;
  VideoPlayerController? _preloadedNextController;
  String? _preloadedNextUrl;

  // Audio/Sound state
  bool _isMuted = false;

  // Animation controller for character jumping micro-animation
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Enable immersive full-screen mode (hides status bar & navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Lock to horizontal/landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (widget.exercises != null && widget.exercises!.isNotEmpty) {
      _exercises = List<ExerciseDetailItem>.from(widget.exercises!);
    } else {
      _exercises = [];
    }
    _currentIndex = (widget.initialExerciseIndex >= 0 &&
            widget.initialExerciseIndex < _exercises.length)
        ? widget.initialExerciseIndex
        : 0;

    _exerciseSecondsRemaining = _exercises.isNotEmpty
        ? _parseDuration(_exercises[_currentIndex].duration)
        : 30;

    final initialEx = _exercises.isNotEmpty ? _exercises[_currentIndex] : null;
    _isVideoReady = initialEx == null ||
        initialEx.videoUrl == null ||
        initialEx.videoUrl!.isEmpty;

    // Setup micro-bounce animation for active exercise character
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startTicker();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _preloadedNextController?.dispose();
    _animController.dispose();

    // Restore system UI mode and portrait orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  int _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
      }
    } catch (_) {}
    return 30;
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_currentStep == ActiveWorkoutStep.exercising) {
        final currentEx = _exercises.isNotEmpty ? _exercises[_currentIndex] : null;
        final hasVideo = currentEx?.videoUrl != null && currentEx!.videoUrl!.isNotEmpty;
        if (hasVideo && !_isVideoReady) {
          // Wait for video to initialize and be ready before counting down!
          return;
        }

        setState(() {
          _overallElapsedSeconds++;
          if (_exerciseSecondsRemaining > 0) {
            _exerciseSecondsRemaining--;
          } else {
            _onExerciseCompleted();
          }
        });
      } else if (_currentStep == ActiveWorkoutStep.resting) {
        setState(() {
          _overallElapsedSeconds++;
          if (_restSecondsRemaining > 0) {
            _restSecondsRemaining--;
          } else {
            _advanceToNextExercise();
          }
        });
      }
    });
  }

  void _onExerciseCompleted() {
    // Check if we reached milestone (e.g. 5 exercises completed)
    if (_currentIndex == 4 &&
        _currentStep != ActiveWorkoutStep.encouragement) {
      setState(() {
        _currentStep = ActiveWorkoutStep.encouragement;
      });
      return;
    }

    if (_currentIndex >= _exercises.length - 1) {
      // Finished all exercises
      widget.onComplete?.call();
      _exitToPortrait();
    } else {
      // Transition to Rest / Next screen
      setState(() {
        _currentStep = ActiveWorkoutStep.resting;
        _restSecondsRemaining = 20;
      });
      _preloadNextVideo();
    }
  }

  void _preloadNextVideo() {
    if (_currentIndex + 1 < _exercises.length) {
      final nextEx = _exercises[_currentIndex + 1];
      final nextUrl = nextEx.videoUrl;
      if (nextUrl != null && nextUrl.isNotEmpty && nextUrl != _preloadedNextUrl) {
        _preloadedNextController?.dispose();
        _preloadedNextUrl = nextUrl;
        _preloadedNextController =
            VideoPlayerController.networkUrl(Uri.parse(nextUrl));
        _preloadedNextController!.initialize().then((_) {
          if (mounted) {
            _preloadedNextController!.setLooping(true);
            _preloadedNextController!.setVolume(_isMuted ? 0.0 : 1.0);
          }
        }).catchError((e) {
          debugPrint('Preload video error: $e');
        });
      }
    }
  }

  void _advanceToNextExercise() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _exerciseSecondsRemaining =
            _parseDuration(_exercises[_currentIndex].duration);
        _currentStep = ActiveWorkoutStep.exercising;
        final cur = _exercises[_currentIndex];
        _isVideoReady = cur.videoUrl == null ||
            cur.videoUrl!.isEmpty ||
            (_preloadedNextController != null &&
                _preloadedNextController!.value.isInitialized &&
                _preloadedNextUrl == cur.videoUrl);
      });
    } else {
      widget.onComplete?.call();
      _exitToPortrait();
    }
  }

  void _previousExercise() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _exerciseSecondsRemaining =
            _parseDuration(_exercises[_currentIndex].duration);
        _currentStep = ActiveWorkoutStep.exercising;
        final cur = _exercises[_currentIndex];
        _isVideoReady = cur.videoUrl == null || cur.videoUrl!.isEmpty;
      });
    }
  }

  void _skipCurrentExercise() {
    _onExerciseCompleted();
  }

  void _restartCurrentExercise() {
    setState(() {
      _exerciseSecondsRemaining =
          _parseDuration(_exercises[_currentIndex].duration);
      _currentStep = ActiveWorkoutStep.exercising;
      final cur = _exercises[_currentIndex];
      _isVideoReady = cur.videoUrl == null || cur.videoUrl!.isEmpty;
    });
  }

  void _exitToPortrait() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Screen 1: Active Exercise (White canvas with character & controls)
            _buildActiveExerciseScreen(),

            // Screen 3: Rest / Next Screen (Split Landscape layout)
            if (_currentStep == ActiveWorkoutStep.resting)
              _buildRestNextScreen(),

            // Screen 4: 5 Exercises Done Encouragement Overlay
            if (_currentStep == ActiveWorkoutStep.encouragement)
              _buildEncouragementScreen(),

            // Screen 2: Pause Overlay
            if (_currentStep == ActiveWorkoutStep.paused)
              _buildPauseOverlay(),

            // Screen 5: Why Quit Confirmation Survey
            if (_currentStep == ActiveWorkoutStep.whyQuit)
              _buildWhyQuitOverlay(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. ACTIVE EXERCISE SCREEN (Figma Screen 1)
  // ==========================================
  Widget _buildActiveExerciseScreen() {
    final currentExercise = _exercises[_currentIndex];
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20.0 + viewPadding.left,
        right: 20.0 + viewPadding.right,
        top: 14.0 + viewPadding.top,
        bottom: 14.0 + viewPadding.bottom,
      ),
      child: Stack(
        children: [
          // Background watermark removed as requested

          // Center Animated Character Illustration or Video Player
          Center(
            child: currentExercise.videoUrl != null &&
                    currentExercise.videoUrl!.isNotEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ExerciseVideoPlayer(
                      videoUrl: currentExercise.videoUrl!,
                      posterImagePath: currentExercise.imagePath,
                      preloadedController: (_preloadedNextUrl == currentExercise.videoUrl)
                          ? _preloadedNextController
                          : null,
                      isPlaying: _currentStep == ActiveWorkoutStep.exercising &&
                          _isVideoReady,
                      isMuted: _isMuted,
                      onReady: () {
                        if (mounted && !_isVideoReady) {
                          setState(() {
                            _isVideoReady = true;
                          });
                        }
                      },
                      onBuffering: (isBuffering) {
                        if (mounted) {
                          setState(() {
                            _isVideoReady = !isBuffering;
                          });
                        }
                      },
                    ),
                  )
                : ScaleTransition(
                    scale: _bounceAnimation,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AppImage(
                          imagePath: currentExercise.imagePath,
                          fit: BoxFit.contain,
                          errorWidget:
                              const Icon(Icons.fitness_center_rounded, size: 80),
                        ),
                      ),
                    ),
                  ),
          ),

          // Top Row: Exercise X/13, Sound Toggle, Elapsed Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Exercise counter & back button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = ActiveWorkoutStep.paused;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF141416),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Exercise ${_currentIndex + 1}/${_exercises.length}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141416),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Sound Toggle Icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: const Color(0xFF141416),
                    size: 16,
                  ),
                ),
              ),

              const Spacer(),

              // Overall elapsed time (e.g. 00:37)
              Text(
                _formatTime(_overallElapsedSeconds),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF141416),
                ),
              ),
            ],
          ),

          // Bottom Left: Exercise Title, Countdown Timer, Previous / Skip
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentExercise.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141416),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(_exerciseSecondsRemaining),
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF141416),
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _currentIndex > 0 ? _previousExercise : null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.skip_previous_rounded,
                            size: 16,
                            color: _currentIndex > 0
                                ? const Color(0xFF141416)
                                : Colors.black26,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Previous',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _currentIndex > 0
                                  ? const Color(0xFF141416)
                                  : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '|',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _skipCurrentExercise,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.skip_next_rounded,
                            size: 16,
                            color: Color(0xFF141416),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Skip',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF141416),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side Action Buttons: Pause (top) and Complete (bottom)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pause Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStep = ActiveWorkoutStep.paused;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF182215),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppColors.primaryLime,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Checkmark / Complete Button
                GestureDetector(
                  onTap: _onExerciseCompleted,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF182215),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryLime,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. PAUSE OVERLAY (Figma Screen 2)
  // ==========================================
  Widget _buildPauseOverlay() {
    return Container(
      color: const Color(0xFF000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pause',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryLime,
            ),
          ),
          const SizedBox(height: 24),

          // 3 Pill Buttons Container
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C20),
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Restart this exercise (Bright Lime Filled)
                GestureDetector(
                  onTap: _restartCurrentExercise,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Restart this exercise',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF141416),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Quit
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStep = ActiveWorkoutStep.whyQuit;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C32),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Quit',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Resume
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStep = ActiveWorkoutStep.exercising;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C32),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Resume',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. REST / NEXT SCREEN (Figma Screen 3)
  // ==========================================
  Widget _buildRestNextScreen() {
    final nextIndex = (_currentIndex + 1 < _exercises.length)
        ? _currentIndex + 1
        : _currentIndex;
    final nextExercise = _exercises[nextIndex];
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        left: viewPadding.left,
        right: viewPadding.right,
        top: viewPadding.top,
        bottom: viewPadding.bottom,
      ),
      child: Row(
        children: [
          // Left Card (White Background with Next Exercise Details & Illustration)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                  // Watermark removed as requested

                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next ${nextIndex + 1}/${_exercises.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            nextExercise.title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF141416),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                      Text(
                        nextExercise.duration,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF141416),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: AppImage(
                              imagePath: nextExercise.imagePath,
                              fit: BoxFit.contain,
                              errorWidget: const Icon(
                                Icons.fitness_center_rounded,
                                size: 64,
                                color: Color(0xFF141416),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right Card (Dark Charcoal Rest Card)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C20),
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rest',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(_restSecondsRemaining),
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // +20s Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _restSecondsRemaining += 20;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B32),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        '+20s',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bright Lime Skip Button
                  GestureDetector(
                    onTap: _advanceToNextExercise,
                    child: Container(
                      width: 130,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLime,
                        borderRadius: BorderRadius.circular(22.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF141416),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. ENCOURAGEMENT SCREEN (Figma Screen 4)
  // ==========================================
  Widget _buildEncouragementScreen() {
    return Container(
      color: const Color(0xFF000000).withValues(alpha: 0.94),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '5 exercises done!',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryLime,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You’re on the right track. Keep going!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Keep exercising button
          GestureDetector(
            onTap: () {
              setState(() {
                _currentStep = ActiveWorkoutStep.resting;
                _restSecondsRemaining = 20;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 36.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLime,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Text(
                'Keep exercising',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF141416),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Do it later
          GestureDetector(
            onTap: _exitToPortrait,
            child: Text(
              'Do it later',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. WHY QUIT? OVERLAY (Figma Screen 5)
  // ==========================================
  Widget _buildWhyQuitOverlay() {
    return Container(
      color: const Color(0xFF000000),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Why quit?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryLime,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              'Every challenge is a chance to grow. Stay focused, keep moving forward, and remember why you started this journey.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // 3 Pill Feedback Buttons
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C20),
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Just take a look (Selected Lime)
                GestureDetector(
                  onTap: _exitToPortrait,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Just take a look',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF141416),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Too hard
                GestureDetector(
                  onTap: _exitToPortrait,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C32),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Too hard',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Too easy
                GestureDetector(
                  onTap: _exitToPortrait,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C32),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Text(
                      'Too easy',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
