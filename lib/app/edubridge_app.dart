import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/root/edubridge_root_screen.dart';

class EduBridgeApp extends StatelessWidget {
  const EduBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBridge',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const EduBridgeRootScreen(),
    );
  }
}
