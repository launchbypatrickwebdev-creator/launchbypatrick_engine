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
  late final bool _isVideo;

  @override
  void initState() {
    super.initState();
    // 🛰️ RUNTIME ANALYSIS: Automatically match media types to the correct engine
    final String path = widget.assetPath.toLowerCase();
    _isVideo = path.endsWith('.mp4') || path.endsWith('.mov');

    if (_isVideo) {
      _initializeHardwareVideo();
    }
  }

  Future<void> _initializeHardwareVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.assetPath);
      if (_videoController != null) {
        await _videoController!.initialize();
        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0); // Necessary for web autoplay rules
        await _videoController!.play();

        if (mounted) {
          setState(() {
            _isControllerInitialized = true;
          });
        }
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
    // Explicitly wrapped in IgnorePointer so clicks instantly drop through to foreground elements
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

        // 🛰️ DEFENSE PROTOCOL: If the web engine initializes at 0x0,
        // use a baseline 16:9 aspect ratio box to prevent rendering collapse.
        final double layoutWidth = videoSize.width > 0 ? videoSize.width : 16.0;
        final double layoutHeight = videoSize.height > 0 ? videoSize.height : 9.0;

        return SizedBox(
          width: layoutWidth,
          height: layoutHeight,
          child: VideoPlayer(_videoController!),
        );
      }
      // Collapses safely to 0x0 size while video hardware warms up
      return const SizedBox.shrink();
    } else {
      // HIGH-SPEED RASTERING ENGINE (WebP, GIF, PNG, JPG)
      return Image.asset(
        widget.assetPath,
        gaplessPlayback: true,
      );
    }
  }
}