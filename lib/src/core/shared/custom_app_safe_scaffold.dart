import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSafeScaffold extends StatelessWidget {
  final Widget child;
  final Color statusBarColor;
  final Brightness statusBarIconBrightness;

  const AppSafeScaffold({
    super.key,
    required this.child,
    this.statusBarColor = Colors.transparent,
    this.statusBarIconBrightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        left: false,
        right: false,
        child: child,
      ),
    );
  }
}
