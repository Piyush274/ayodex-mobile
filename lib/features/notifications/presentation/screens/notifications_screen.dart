import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/features/notifications/data/models/notification_model.dart';
import 'package:ayodex/features/notifications/data/repositories/notification_repository.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications(refresh: true);
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    final page = refresh ? 1 : _page;
    setState(() => _isLoading = true);

    try {
      final paginated = await ref.read(notificationRepositoryProvider).getNotifications(page: page);
      setState(() {
        _notifications = refresh ? paginated.data : [..._notifications, ...paginated.data];
        _hasMore = paginated.hasMorePages;
        _page = page + 1;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onNotificationTapped(NotificationModel item) {
    if (!item.userRead) {
      ref.read(notificationRepositoryProvider).markAsRead(item.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: item.id,
            userId: item.userId,
            title: item.title,
            message: item.message,
            userRead: true,
            createdAt: item.createdAt,
          );
        }
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTextTheme.headingMedium.copyWith(fontSize: 18),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 8),
            if (item.createdAt != null)
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt!),
                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
              ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(item.message, style: AppTextTheme.bodyMedium),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _isLoading && _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        const Text('No notifications', style: AppTextTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('You are all caught up!', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () => _loadNotifications(),
                            child: const Text('Load More'),
                          ),
                        );
                      }

                      final item = _notifications[index];
                      final dateStr = item.createdAt != null
                          ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt!)
                          : '';

                      return CustomCard(
                        onTap: () => _onNotificationTapped(item),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: item.userRead
                                  ? AppColors.surfaceSubtle
                                  : AppColors.base.withOpacity(0.12),
                              child: Icon(
                                Icons.notifications,
                                size: 18,
                                color: item.userRead ? AppColors.textMuted : AppColors.base,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: AppTextTheme.bodyMedium.copyWith(
                                            fontWeight: item.userRead ? FontWeight.normal : FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!item.userRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.base,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: AppTextTheme.caption.copyWith(color: AppColors.body),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateStr,
                                    style: AppTextTheme.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
