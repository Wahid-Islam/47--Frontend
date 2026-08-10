import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;

  static const double desktop = 1024;

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
