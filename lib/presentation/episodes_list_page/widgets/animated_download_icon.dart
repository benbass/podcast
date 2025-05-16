import 'package:flutter/material.dart';
import 'package:podcast/main.dart';

import '../../../domain/queued_audio_download/queued_audio_download.dart';
import '../../../helpers/audio_download/audio_download_queue_manager.dart';
import '../../audio_download_queue_page/audio_download_queue_page.dart';
import '../../custom_widgets/page_transition.dart';

class AnimatedDownloadIcon extends StatefulWidget {
  final double? size;
  const AnimatedDownloadIcon({super.key, this.size});

  @override
  State<AnimatedDownloadIcon> createState() => _AnimatedDownloadIconState();
}

class _AnimatedDownloadIconState extends State<AnimatedDownloadIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late AudioDownloadQueueManager _downloadManager;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _downloadManager = AudioDownloadQueueManager();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _downloadManager.addListener(_handleDownloadManagerChange);

    _updateAnimationState();
  }

  void _handleDownloadManagerChange() {
    if (mounted) {
      _updateAnimationState();
    }
  }

  void _updateColorAnimationBasedOnTheme() {
    final targetColor =
        IconTheme.of(MyApp.navigatorKey.currentContext!).color ??
            Colors.grey.shade700;

    _colorAnimation = ColorTween(
      begin: targetColor.withValues(alpha: 0.0),
      end: targetColor,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _updateAnimationState() {
    if (!mounted) return;

    _updateColorAnimationBasedOnTheme();

    final bool shouldAnimate = _downloadManager.downloadItems.any((item) =>
        item.status == DownloadStatus.downloading ||
        item.status == DownloadStatus.pending);

    if (shouldAnimate && !_isAnimating) {
      _isAnimating = true;
      _animationController.repeat(reverse: true);
    } else if (!shouldAnimate && _isAnimating) {
      _isAnimating = false;
      _animationController.stop();

      // Set the final color after the animation stops
      _setFinalIconColor();
    } else if (!shouldAnimate && !_isAnimating) {
      _setFinalIconColor();
    }
    setState(() {});
  }

  void _setFinalIconColor() {
    if (!mounted) return;

    final targetColor =
        IconTheme.of(MyApp.navigatorKey.currentContext!).color ??
            Colors.grey.shade700;
    final bool hasAnyItems = _downloadManager.downloadItems.isNotEmpty;

    if (!hasAnyItems) {
      if (_animationController.value != 0.0) {
        _animationController.animateTo(0.0,
            duration: const Duration(milliseconds: 150));
      } else {
        // Make sure we use the correct color
        if (_colorAnimation.value != targetColor.withValues(alpha: (0.0))) {
          setState(() {
            _updateColorAnimationBasedOnTheme();
          });
        }
      }
    } else {
      if (_animationController.value != 1.0) {
        _animationController.animateTo(1.0,
            duration: const Duration(milliseconds: 150));
      } else {
        if (_colorAnimation.value != targetColor) {
          setState(() {
            _updateColorAnimationBasedOnTheme();
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // In case theme changes
    if (mounted) {
      _updateAnimationState();
    }
  }

  @override
  void dispose() {
    _downloadManager.removeListener(_handleDownloadManagerChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_downloadManager.downloadItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        Navigator.of(context)
            .push(SlideBottomRoute(page: const AudioDownloadQueuePage()));
      },
      icon: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Icon(
            Icons.download_rounded,
            size: widget.size ?? 30,
            color: _colorAnimation.value,
          );
        },
      ),
    );
  }
}
