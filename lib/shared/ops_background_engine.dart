import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OpsBackgroundEngine extends StatefulWidget {
  final String assetPath;

  const OpsBackgroundEngine({
    super.key,
    required this.assetPath,
  });

  @override
  State<OpsBackgroundEngine> createState() => _OpsBackgroundEngineState();
}

class _OpsBackgroundEngineState extends State<OpsBackgroundEngine> {
  VideoPlayerController? _videoController;
  bool _isControllerInitialized = false;

  // Helper getter — checks media type dynamically on every frame
  bool get _isVideo {
    final String path = widget.assetPath.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov');
  }

  @override
  void initState() {
    super.initState();
    _setupEngine();
  }

  // 🛰️ CRITICAL FIX: Detects when route changes pass a new assetPath
  @override
  void didUpdateWidget(covariant OpsBackgroundEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _resetEngine();
    }
  }

  void _resetEngine() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isControllerInitialized = false;
    _setupEngine();
  }

  void _setupEngine() {
    if (_isVideo) {
      _initializeHardwareVideo();
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeHardwareVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.assetPath);
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0); // Necessary for web autoplay rules
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _isControllerInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("OpsBackgroundEngine Error: Video hardware initialization failed: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Clear video pipelines out of active memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛰️ LAYER 01: THE AMBIENT ATMOSPHERE ONLY
    return IgnorePointer(
      child: Opacity(
        opacity: 0.2, // Locked at exactly 20% ambient blending
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover, // Forces edge-to-edge layout filling
            clipBehavior: Clip.hardEdge,
            child: _buildAtmosphereContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphereContent() {
    if (_isVideo) {
      // VIDEO PLAYBACK PIPELINE
      if (_videoController != null && _isControllerInitialized) {
        final Size videoSize = _videoController!.value.size;

        final double layoutWidth = videoSize.width > 0 ? videoSize.width : 16.0;
        final double layoutHeight = videoSize.height > 0 ? videoSize.height : 9.0;

        return SizedBox(
          width: layoutWidth,
          height: layoutHeight,
          child: VideoPlayer(_videoController!),
        );
      }
      return const SizedBox.shrink();
    } else {
      // HIGH-SPEED RASTERING ENGINE (WebP, GIF, PNG, JPG)
      return Image.asset(
        widget.assetPath,
        gaplessPlayback: true,
        fit: BoxFit.cover,
      );
    }
  }
}