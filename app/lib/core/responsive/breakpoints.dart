import 'package:flutter/widgets.dart';

/// Responsive breakpoints for mobile / tablet / desktop layouts.
enum DeviceType { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();

  /// Below this width the layout is treated as a phone.
  static const double tablet = 600;

  /// Above this width the layout is treated as a desktop / large tablet.
  static const double desktop = 1024;

  /// Widest comfortable measure for a single column of reading content.
  /// Beyond this the shell centres content instead of stretching it, so
  /// text lines stay readable on 1440px+ monitors.
  static const double contentMaxWidth = 1080;

  static DeviceType of(double width) {
    if (width >= desktop) return DeviceType.desktop;
    if (width >= tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(double width) => of(width) == DeviceType.mobile;
  static bool isTablet(double width) => of(width) == DeviceType.tablet;
  static bool isDesktop(double width) => of(width) == DeviceType.desktop;
}

/// Chooses a builder based on the current [LayoutBuilder] width, falling
/// back to the next-smaller breakpoint when a builder isn't provided.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.mobile, this.tablet, this.desktop});

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (Breakpoints.of(constraints.maxWidth)) {
          case DeviceType.desktop:
            return (desktop ?? tablet ?? mobile)(context);
          case DeviceType.tablet:
            return (tablet ?? mobile)(context);
          case DeviceType.mobile:
            return mobile(context);
        }
      },
    );
  }
}
