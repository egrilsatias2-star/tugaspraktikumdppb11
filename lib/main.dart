import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide PlayerState;

void main() {
  runApp(const PlayWaveApp());
}

const _background = Color(0xFF081217);
const _surface = Color(0xFF122128);
const _surfaceRaised = Color(0xFF192B33);
const _mint = Color(0xFF66E3C4);
const _muted = Color(0xFF94A8AE);

class PlayWaveApp extends StatelessWidget {
  const PlayWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayWave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _mint,
          brightness: Brightness.dark,
          surface: _surface,
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: _mint.withValues(alpha: 0.16),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected) ? _mint : _muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }),
        ),
      ),
      home: const PlayWaveHome(),
    );
  }
}

class PlayWaveHome extends StatefulWidget {
  const PlayWaveHome({super.key});

  @override
  State<PlayWaveHome> createState() => _PlayWaveHomeState();
}

class _PlayWaveHomeState extends State<PlayWaveHome> {
  int _selectedTab = 0;
  final List<bool> _visitedTabs = [true, false, false];

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
      _visitedTabs[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _visitedTabs[0]
                      ? const GalleryPage()
                      : const SizedBox.shrink(),
                  _visitedTabs[1] ? const AudioPage() : const SizedBox.shrink(),
                  _visitedTabs[2] ? const VideoPage() : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_outlined),
            selectedIcon: Icon(Icons.photo),
            label: 'Foto',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_outlined),
            selectedIcon: Icon(Icons.graphic_eq),
            label: 'Audio',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_display_outlined),
            selectedIcon: Icon(Icons.smart_display),
            label: 'Video',
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _mint.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.graphic_eq, color: _mint, size: 25),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAYWAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'MEDIA STUDIO',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Icon(Icons.tune_rounded, color: _muted, size: 19),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: _mint,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          description,
          style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isPicking = false;

  Future<void> _pickImage() async {
    setState(() => _isPicking = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage('Foto tidak dapat dibuka: ${error.message ?? error.code}');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            eyebrow: '01 / Image picker',
            title: 'Pilih foto,\nceritakan momen.',
            description:
                'Ambil gambar dari galeri dan lihat hasilnya langsung di sini.',
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              gradient: _imageBytes == null
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_surfaceRaised, _surface, _background],
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: _imageBytes == null
                ? const _EmptyPhotoPreview()
                : Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const _EmptyPhotoPreview(
                        message: 'Gambar tidak dapat ditampilkan.',
                      );
                    },
                  ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _isPicking ? null : _pickImage,
            icon: _isPicking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              _imageBytes == null ? 'Pilih dari galeri' : 'Ganti foto',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _mint,
              foregroundColor: _background,
              minimumSize: const Size.fromHeight(54),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _HintCard(
            icon: Icons.lock_outline_rounded,
            title: 'Foto tetap milikmu',
            subtitle: 'Gambar dipilih dari perangkat dan tidak diunggah.',
          ),
        ],
      ),
    );
  }
}

class _EmptyPhotoPreview extends StatelessWidget {
  const _EmptyPhotoPreview({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: _mint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: _mint,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Belum ada foto dipilih',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Foto pilihanmu akan muncul di sini',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  static const _audioUrl =
      'https://samplelib.com/lib/preview/mp3/sample-60s.mp3';

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _completeSubscription;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackRate = 1;
  bool _isPlaying = false;
  bool _sourceReady = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    setState(() => _isLoading = true);
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (!_sourceReady) {
          await _player.setSourceUrl(_audioUrl);
          _sourceReady = true;
        } else if (_duration > Duration.zero && _position >= _duration) {
          await _player.seek(Duration.zero);
        }
        await _player.resume();
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(
          'Audio tidak dapat diputar: ${error.message ?? error.code}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seekTo(double seconds) async {
    try {
      await _player.seek(Duration(milliseconds: (seconds * 1000).round()));
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(
          'Posisi audio tidak dapat diubah: ${error.message ?? error.code}',
        );
      }
    }
  }

  Future<void> _setRate(double rate) async {
    try {
      await _player.setPlaybackRate(rate);
      if (mounted) setState(() => _playbackRate = rate);
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(
          'Kecepatan tidak dapat diubah: ${error.message ?? error.code}',
        );
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    unawaited(_stateSubscription?.cancel());
    unawaited(_positionSubscription?.cancel());
    unawaited(_durationSubscription?.cancel());
    unawaited(_completeSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _duration.inMilliseconds / 1000;
    final currentSeconds = (_position.inMilliseconds / 1000)
        .clamp(0, totalSeconds > 0 ? totalSeconds : 1)
        .toDouble();

    return _PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            eyebrow: '02 / Audio streaming',
            title: 'Putar ritmemu.',
            description: 'Dengarkan audio online, atur posisi, lalu pilih kecepatan yang nyaman.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3D40), _surface, _surface],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _mint.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: _mint,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audio demo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'DEMO AUDIO STREAM',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 9,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<double>(
                      tooltip: 'Kecepatan audio',
                      initialValue: _playbackRate,
                      onSelected: _setRate,
                      color: _surfaceRaised,
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 0.75, child: Text('0,75×')),
                        PopupMenuItem(value: 1, child: Text('1,0×')),
                        PopupMenuItem(value: 1.25, child: Text('1,25×')),
                        PopupMenuItem(value: 1.5, child: Text('1,5×')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _background.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              color: _mint,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_playbackRate.toStringAsFixed(1)}×',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                const _Waveform(),
                const SizedBox(height: 10),
                Slider(
                  value: currentSeconds,
                  min: 0,
                  max: totalSeconds > 0 ? totalSeconds : 1,
                  onChanged: totalSeconds > 0
                      ? (value) => setState(
                          () => _position = Duration(
                            milliseconds: (value * 1000).round(),
                          ),
                        )
                      : null,
                  onChangeEnd: totalSeconds > 0 ? _seekTo : null,
                  activeColor: _mint,
                  inactiveColor: Colors.white.withValues(alpha: 0.12),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Mundur 10 detik',
                      onPressed: _duration > Duration.zero
                          ? () => _seekTo(
                              (_position.inSeconds - 10)
                                  .clamp(0, _duration.inSeconds)
                                  .toDouble(),
                            )
                          : null,
                      icon: const Icon(Icons.replay_10_rounded),
                      iconSize: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _togglePlayback,
                        style: FilledButton.styleFrom(
                          backgroundColor: _mint,
                          foregroundColor: _background,
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _background,
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 34,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      tooltip: 'Maju 10 detik',
                      onPressed: _duration > Duration.zero
                          ? () => _seekTo(
                              (_position.inSeconds + 10)
                                  .clamp(0, _duration.inSeconds)
                                  .toDouble(),
                            )
                          : null,
                      icon: const Icon(Icons.forward_10_rounded),
                      iconSize: 30,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _HintCard(
            icon: Icons.wifi_rounded,
            title: 'Streaming audio',
            subtitle: 'Koneksi internet dibutuhkan untuk memutar demo.',
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  static const _heights = [
    14.0,
    24.0,
    18.0,
    32.0,
    22.0,
    40.0,
    28.0,
    18.0,
    34.0,
    24.0,
    44.0,
    30.0,
    20.0,
    36.0,
    25.0,
    16.0,
    31.0,
    42.0,
    24.0,
    34.0,
    18.0,
    28.0,
    38.0,
    20.0,
    32.0,
    14.0,
    26.0,
    40.0,
    22.0,
    34.0,
    16.0,
    28.0,
    42.0,
    24.0,
    36.0,
    18.0,
    30.0,
    20.0,
    38.0,
    16.0,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var index = 0; index < _heights.length; index++)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 3,
                  height: _heights[index],
                  decoration: BoxDecoration(
                    color: index < 17
                        ? _mint.withValues(alpha: 0.88)
                        : _mint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'Ljef-LLe6Wk',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_controller.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            eyebrow: '03 / YouTube video',
            title: 'Belajar sambil menonton.',
            description: 'Video tutorial media Flutter yang menjadi inspirasi aplikasi ini.',
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
              autoFullScreen: false,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: _mint, size: 21),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media dalam satu aplikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Pilih foto, streaming audio, dan kendalikan video YouTube dari tab di bawah.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
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

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _mint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: _muted, size: 16),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
