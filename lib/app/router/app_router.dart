// Author: Rakka Purnama

import 'package:flutter/material.dart';
import 'package:semarewards/features/video_clipping/presentation/screens/video_editor_screen.dart';
import 'package:semarewards/features/video_clipping/presentation/screens/video_home_screen.dart';
import 'package:semarewards/features/video_clipping/presentation/screens/video_result_screen.dart';

abstract final class AppRouter {
  static const home = '/';
  static const editor = '/editor';
  static const result = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      editor => MaterialPageRoute(builder: (_) => const VideoEditorScreen()),
      result => MaterialPageRoute(builder: (_) => const VideoResultScreen()),
      _ => MaterialPageRoute(builder: (_) => const VideoHomeScreen()),
    };
  }
}
