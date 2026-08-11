import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../controller/services/notification_inbox.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final profile = context.watch<ProfileCubit>().state.profile;
    final name = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName.split(' ').first
        : AppStrings.t('helloThere', locale);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF334154), fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: AppStrings.t('hello', locale)),
                      TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _NotificationBell(),
          const SizedBox(width: 8),
          Material(
            color: AppTheme.softGreen,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/home/profile'),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C6D48)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final MenuController _menuController = MenuController();
  List<AppNotification> _items = const [];
  bool _loading = false;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshBadge());
  }

  Future<void> _refreshBadge() async {
    final count = await NotificationInbox.unreadCount();
    if (!mounted) return;
    setState(() => _unread = count);
  }

  Future<void> _openMenu() async {
    setState(() => _loading = true);
    final items = await NotificationInbox.list();
    await NotificationInbox.markAllRead();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      _unread = 0;
    });
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  String _relativeTime(DateTime when, String locale) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return AppStrings.t('notificationJustNow', locale);
    if (diff.inHours < 1) return AppStrings.tn('notificationMinutesAgo', locale, diff.inMinutes);
    if (diff.inDays < 1) return AppStrings.tn('notificationHoursAgo', locale, diff.inHours);
    return AppStrings.tn('notificationDaysAgo', locale, diff.inDays.clamp(1, 30));
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(-220, 8),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(8),
        shadowColor: WidgetStateProperty.all(Colors.black26),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        maximumSize: WidgetStateProperty.all(const Size(300, 360)),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Text(
            AppStrings.t('notifications', locale),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        const Divider(height: 1),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Row(
              children: [
                Icon(Icons.notifications_off_outlined, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.t('noNotifications', locale),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        else
          ..._items.take(8).map((item) {
            return MenuItemButton(
              onPressed: () => _menuController.close(),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              ),
              child: SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, height: 1.35, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _relativeTime(item.createdAt, locale),
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
      builder: (context, controller, child) {
        return Badge(
          isLabelVisible: _unread > 0,
          smallSize: 8,
          backgroundColor: AppTheme.primary,
          child: IconButton(
            tooltip: AppStrings.t('notifications', locale),
            onPressed: _openMenu,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8E4)),
              fixedSize: const Size(40, 40),
            ),
            icon: Icon(
              _unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
              size: 20,
              color: const Color(0xFF334154),
            ),
          ),
        );
      },
    );
  }
}
