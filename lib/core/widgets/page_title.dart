import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Sets the document title for a route.
///
/// Flutter's [Title] widget writes through to `document.title` on web, so
/// every deep-linkable route gets a meaningful name in the browser tab,
/// history list and bookmarks instead of one app-wide title.
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, required this.child});

  /// Page name, shown as "<title> · mysihat".
  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(title: '$title · mysihat', color: AppTheme.primary, child: child);
  }
}
