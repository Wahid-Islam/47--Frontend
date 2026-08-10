import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, required this.child});

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(title: '$title · MySihat', color: AppTheme.primary, child: child);
  }
}
