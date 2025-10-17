import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaCarouselViewer extends StatefulWidget {
  const MediaCarouselViewer(
      {super.key, required this.urls, this.initialIndex = 0});
  final List<String> urls;
  final int initialIndex;

  @override
  State<MediaCarouselViewer> createState() => _MediaCarouselViewerState();
}

class _MediaCarouselViewerState extends State<MediaCarouselViewer> {
  late final PageController _pageCtrl =
      PageController(initialPage: widget.initialIndex);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: widget.urls.length,
              itemBuilder: (_, i) => _MediaPage(url: widget.urls[i]),
            ),
            // Close
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Counter
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_index + 1} / ${widget.urls.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPage extends StatelessWidget {
  const _MediaPage({required this.url});
  final String url;

  bool _isVideoUrl(String u) {
    final s = u.toLowerCase();
    return s.endsWith('.mp4') ||
        s.endsWith('.mov') ||
        s.endsWith('.mkv') ||
        s.endsWith('.webm') ||
        s.endsWith('.avi');
  }

  bool get _isVideo => _isVideoUrl(url);

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      return _VideoView(url: url);
    }
    // Image with pinch-zoom
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.network(url, fit: BoxFit.contain),
      ),
    );
  }
}

class _VideoView extends StatefulWidget {
  const _VideoView({required this.url});
  final String url;

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView>
    with AutomaticKeepAliveClientMixin {
  late final VideoPlayerController _controller;
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _init = _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setLooping(true);
      await _controller.play(); // ← start automatically
      setState(() {}); // refresh for correct aspect ratio
    }).catchError((e) {
      // Optional: log/track
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<void>(
      future: _init,
      builder: (_, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(
              'Failed to load video',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (snap.connectionState != ConnectionState.done ||
            !_controller.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final v = _controller.value;
        final ratio = (v.aspectRatio == 0) ? (16 / 9) : v.aspectRatio;

        return GestureDetector(
          onTap: () {
            if (v.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
            setState(() {});
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: ratio,
                  child: VideoPlayer(_controller),
                ),
              ),
              // buffering spinner
              if (v.isBuffering)
                const Center(child: CircularProgressIndicator()),
              // big play icon when paused
              if (!v.isPlaying && !v.isBuffering)
                const Icon(Icons.play_circle_fill,
                    size: 72, color: Colors.white),
              // scrubber
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
