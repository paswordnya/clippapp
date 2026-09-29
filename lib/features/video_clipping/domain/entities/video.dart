class Video {
  const Video({
    required this.path,
    required this.duration,
    required this.width,
    required this.height,
  });

  final String path;
  final Duration duration;
  final int width;
  final int height;

  bool get isLandscape => width > height;
}
