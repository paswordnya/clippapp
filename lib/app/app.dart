// Author: Rakka Purnama

import 'package:flutter/material.dart';
import 'package:semarewards/app/router/app_router.dart';
import 'package:semarewards/app/theme/app_theme.dart';

class ClippApp extends StatelessWidget {
  const ClippApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipp App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
