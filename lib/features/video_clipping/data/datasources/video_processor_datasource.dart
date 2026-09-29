import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_video/session.dart';
import 'package:ffmpeg_kit_flutter_new_video/statistics.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:semarewards/core/constants/app_constants.dart';
import 'package:semarewards/core/error/app_exception.dart';
import 'package:semarewards/features/video_clipping/data/models/processed_video_model.dart';
import 'package:semarewards/features/video_clipping/domain/entities/caption_style.dart';

abstract interface class VideoProcessorDataSource {
  Future<ProcessedVideoModel> process({
    required String inputPath,
    required int sourceWidth,
    required int sourceHeight,
    required Duration start,
    required Duration end,
    required double cropOffset,
    required String caption,
    required CaptionStyle captionStyle,
    void Function(double progress)? onProgress,
  });

  Future<void> cancel();
}

class VideoProcessorDataSourceImpl implements VideoProcessorDataSource {
  static const _fontAssets = <CaptionFont, String>{
    CaptionFont.sans: 'assets/fonts/InstrumentSans-Bold.ttf',
    CaptionFont.serif: 'assets/fonts/InstrumentSerif-Italic.ttf',
    CaptionFont.mono: 'assets/fonts/JetBrainsMono-SemiBold.ttf',
    CaptionFont.display: 'assets/fonts/Anton-Regular.ttf',
  };

  static const _colors = <CaptionColor, String>{
    CaptionColor.white: 'white',
    CaptionColor.black: '0x141412',
    CaptionColor.purple: '0x5D17EB',
    CaptionColor.coral: '0xFF7A66',
    CaptionColor.sky: '0x5AC8F5',
  };

  static const _sizeMultipliers = <CaptionSize, double>{
    CaptionSize.small: 0.8,
    CaptionSize.medium: 1.0,
    CaptionSize.large: 1.3,
  };

  static const _positionFractions = <CaptionPosition, double>{
    CaptionPosition.top: 0.16,
    CaptionPosition.middle: 0.5,
    CaptionPosition.bottom: 0.82,
  };

  final _fontPathCache = <CaptionFont, String>{};
  bool _cancelRequested = false;

  @override
  Future<void> cancel() async {
    _cancelRequested = true;
    await FFmpegKit.cancel();
  }

  @override
  Future<ProcessedVideoModel> process({
    required String inputPath,
    required int sourceWidth,
    required int sourceHeight,
    required Duration start,
    required Duration end,
    required double cropOffset,
    required String caption,
    required CaptionStyle captionStyle,
    void Function(double progress)? onProgress,
  }) async {
    _cancelRequested = false;
    final clipDuration = end - start;
    final outputPath = await _prepareOutputPath();
    final filterChain = await _buildFilterChain(
      cropOffset,
      caption,
      captionStyle,
      sourceWidth,
      sourceHeight,
    );

    final command = _buildCommand(
      inputPath: inputPath,
      startSeconds: start.inMilliseconds / 1000,
      durationSeconds: clipDuration.inMilliseconds / 1000,
      filterChain: filterChain,
      outputPath: outputPath,
    );

    final session = await _run(
      command,
      totalDurationMs: clipDuration.inMilliseconds,
      onProgress: onProgress,
    );

    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      if (_cancelRequested || ReturnCode.isCancel(returnCode)) {
        throw const VideoProcessingException('Export cancelled.');
      }
      final logs = await session.getAllLogsAsString();
      throw VideoProcessingException(
        'Export failed (code $returnCode).\n${logs ?? ''}'.trim(),
      );
    }

    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      throw const VideoProcessingException('Export finished but produced no file.');
    }

    return ProcessedVideoModel(
      path: outputPath,
      durationMs: clipDuration.inMilliseconds,
      fileSizeBytes: await outputFile.length(),
    );
  }

  Future<Session> _run(
    List<String> command, {
    required int totalDurationMs,
    void Function(double progress)? onProgress,
  }) {
    final completer = Completer<Session>();
    FFmpegKit.executeWithArgumentsAsync(
      command,
      (session) async => completer.complete(session),
      null,
      (Statistics stats) {
        if (onProgress == null || totalDurationMs <= 0) return;
        final progress = (stats.getTime() / totalDurationMs).clamp(0.0, 1.0);
        onProgress(progress);
      },
    );
    return completer.future;
  }

  List<String> _buildCommand({
    required String inputPath,
    required double startSeconds,
    required double durationSeconds,
    required String filterChain,
    required String outputPath,
  }) {
    return [
      '-y',
      '-i', inputPath,
      '-ss', startSeconds.toStringAsFixed(3),
      '-t', durationSeconds.toStringAsFixed(3),
      '-vf', filterChain,
      '-c:v', 'mpeg4',
      '-pix_fmt', 'yuv420p',
      '-q:v', '4',
      '-c:a', 'aac',
      '-b:a', '128k',
      outputPath,
    ];
  }

  Future<String> _buildFilterChain(
    double cropOffset,
    String caption,
    CaptionStyle style,
    int sourceWidth,
    int sourceHeight,
  ) async {
    final crop = _buildCropFilter(cropOffset, sourceWidth, sourceHeight);
    final scale = 'scale=${AppConstants.outputWidth}:${AppConstants.outputHeight}';
    if (caption.isEmpty) {
      return '$crop,$scale';
    }

    final drawtext = await _buildDrawtext(caption, style);
    return '$crop,$scale,$drawtext';
  }

  String _buildCropFilter(double cropOffset, int sourceWidth, int sourceHeight) {
    final sourceAspect = sourceWidth / sourceHeight;
    final offset = cropOffset.toStringAsFixed(3);
    if (sourceAspect >= AppConstants.outputAspectRatio) {
      const widthExpr = 'ih*${AppConstants.outputAspectRatio}';
      final xExpr = '(iw-$widthExpr)*$offset';
      return 'crop=$widthExpr:ih:x=$xExpr:y=0';
    }
    const heightExpr = 'iw/${AppConstants.outputAspectRatio}';
    final yExpr = '(ih-$heightExpr)*$offset';
    return 'crop=iw:$heightExpr:x=0:y=$yExpr';
  }

  Future<String> _buildDrawtext(String caption, CaptionStyle style) async {
    final fontPath = await _fontPath(style.font);
    final fontSize = (AppConstants.outputWidth * AppConstants.captionFontRatio * _sizeMultipliers[style.size]!)
        .round();
    final color = _colors[style.color]!;
    final darkText = style.color == CaptionColor.black;
    final yFraction = _positionFractions[style.position]!;
    final y = '(h*$yFraction)-(th/2)';

    final styling = switch (style.background) {
      CaptionBackground.none => '',
      CaptionBackground.box =>
        ':box=1:boxcolor=${darkText ? 'white@0.92' : 'black@0.8'}:boxborderw=14',
      CaptionBackground.glow =>
        ':borderw=6:bordercolor=${darkText ? 'white@0.85' : 'black@0.7'}',
    };

    return "drawtext=fontfile='$fontPath':text='${_escapeDrawtext(caption)}':"
        'fontsize=$fontSize:fontcolor=$color:'
        'x=(w-text_w)/2:y=$y$styling';
  }

  Future<String> _fontPath(CaptionFont font) async {
    final cached = _fontPathCache[font];
    if (cached != null && await File(cached).exists()) {
      return cached;
    }

    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/caption_font_${font.name}.ttf');
    if (!await file.exists()) {
      final bytes = await rootBundle.load(_fontAssets[font]!);
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }
    _fontPathCache[font] = file.path;
    return file.path;
  }

  Future<String> _prepareOutputPath() async {
    final dir = await getApplicationSupportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/clip_$timestamp.mp4';
  }

  String _escapeDrawtext(String caption) {
    return caption
        .replaceAll('\\', r'\\')
        .replaceAll(':', r'\:')
        .replaceAll("'", r"\'")
        .replaceAll('%', r'\%')
        .replaceAll('\n', ' ');
  }
}
