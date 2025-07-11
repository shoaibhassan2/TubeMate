import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Import video_player
import 'package:tubemate/features/whatsapp_saver/data/models/whatsapp_status_model.dart';

class StatusViewerScreen extends StatefulWidget {
  final WhatsappStatusModel status;

  const StatusViewerScreen({super.key, required this.status});

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.status.type == StatusType.video) {
      _videoController = VideoPlayerController.file(widget.status.file);
      _initializeVideoPlayerFuture = _videoController?.initialize().then((_) {
        // Ensure the first frame is shown and then play the video.
        if (mounted) {
          _videoController?.setLooping(true); // Loop video for statuses
          _videoController?.play();
        }
      }).catchError((error) {
        debugPrint("Error initializing video player: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing video: ${error.toString()}')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose the video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for media viewing
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5), // Semi-transparent AppBar
        elevation: 0,
        foregroundColor: Colors.white, // White icons/text on dark AppBar
        title: Text(
          widget.status.file.path.split('/').last, // Show file name as title
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: widget.status.type == StatusType.image
            ? _buildImageViewer()
            : _buildVideoViewer(theme),
      ),
      floatingActionButton: widget.status.type == StatusType.video
          ? _buildVideoFloatingActionButton(theme)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildImageViewer() {
    return Image.file(
      widget.status.file,
      fit: BoxFit.contain, // Contain the image within the screen bounds
      errorBuilder: (context, error, stackTrace) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.broken_image, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text('Failed to load image', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildVideoViewer(ThemeData theme) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_videoController != null && _videoController!.value.isInitialized) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, size: 80, color: theme.colorScheme.error),
                const SizedBox(height: 10),
                Text('Could not load video.', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
              ],
            );
          }
        } else if (snapshot.hasError) {
           return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 80, color: theme.colorScheme.error),
                const SizedBox(height: 10),
                Text('Error: ${snapshot.error}', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
              ],
            );
        } else {
          return CircularProgressIndicator(color: theme.colorScheme.primary);
        }
      },
    );
  }

  Widget _buildVideoFloatingActionButton(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _videoController != null && _videoController!.value.isInitialized ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary.withOpacity(0.8), // Use secondary accent
        onPressed: () {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        },
        child: Icon(
          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}