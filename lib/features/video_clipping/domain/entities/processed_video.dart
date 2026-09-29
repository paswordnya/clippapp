class ProcessedVideo {
  const ProcessedVideo({
    required this.path,
    required this.duration,
    required this.fileSizeBytes,
  });

  final String path;
  final Duration duration;
  final int fileSizeBytes;

  double get fileSizeMegabytes => fileSizeBytes / (1024 * 1024);
}
