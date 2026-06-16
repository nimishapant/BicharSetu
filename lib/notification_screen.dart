import 'package:flutter/material.dart';
import 'comment_sheet.dart';
import 'model/notification_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when the screen opens
    AuthService().markAllNotificationsRead();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationAppBar(showBackButton: widget.showBackButton),
            Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),
            Expanded(
              child: StreamBuilder<List<NotificationModel>>(
                stream: AuthService().getNotificationsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: bichar.accent,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorState(error: '${snapshot.error}');
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return const _EmptyNotificationState();
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: bichar.border.withValues(alpha: 0.45),
                    ),
                    itemBuilder: (context, index) {
                      return _NotificationTile(
                        notification: notifications[index],
                        onTap: () async {
                          // Mark individual read
                          if (!notifications[index].isRead) {
                            await AuthService().markNotificationRead(
                              notifications[index].notificationId,
                            );
                          }
                          // Open the comment sheet for the related post
                          if (context.mounted) {
                            await CommentSheet.show(
                              context,
                              notifications[index].postId,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar ────────────────────────────────────────────────────────────────

class _NotificationAppBar extends StatelessWidget {
  const _NotificationAppBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Container(
      color: bichar.cardBackground,
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: bichar.textPrimary,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: bichar.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          // "Mark all read" button
          IconButton(
            onPressed: () => AuthService().markAllNotificationsRead(),
            tooltip: 'Mark all as read',
            icon: Icon(
              Icons.done_all_rounded,
              color: bichar.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification tile ──────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFF6A3DE8),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isLike = notification.type == NotificationType.like;
    final isMention = notification.type == NotificationType.mention;
    final isUnread = !notification.isRead;

    // Badge icon + color per type
    final badgeColor = isLike
        ? Colors.redAccent
        : isMention
            ? const Color(0xFFF59E0B) // amber for mention
            : bichar.accent;
    final badgeIcon = isLike
        ? Icons.favorite_rounded
        : isMention
            ? Icons.alternate_email_rounded
            : Icons.chat_bubble_rounded;

    // Action text per type
    final actionText = isLike
        ? ' liked your post'
        : isMention
            ? ' mentioned you'
            : ' commented on your post';

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: isUnread
            ? bichar.accent.withValues(alpha: context.isDarkMode ? 0.08 : 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with type badge
            Stack(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarColor(notification.senderUsername),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: notification.senderProfilePhoto.isNotEmpty
                      ? Image.network(
                          notification.senderProfilePhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarInitial(name: notification.senderUsername),
                        )
                      : _AvatarInitial(name: notification.senderUsername),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: bichar.cardBackground, width: 2),
                    ),
                    child: Icon(badgeIcon, size: 9, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.5, color: bichar.textPrimary, height: 1.4),
                      children: [
                        TextSpan(
                          text: notification.senderUsername.isNotEmpty
                              ? notification.senderUsername[0].toUpperCase() +
                                  notification.senderUsername.substring(1)
                              : notification.senderUsername,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: actionText,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (notification.postPreview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.postPreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: bichar.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (!isLike && notification.commentText != null &&
                      notification.commentText!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bichar.searchFieldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: bichar.border.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        '"${notification.commentText}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: bichar.textPrimary, height: 1.35),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(notification.timeAgo,
                    style: TextStyle(fontSize: 12, color: bichar.textSecondary, fontWeight: FontWeight.w500)),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: bichar.accent, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

// ─── Empty / Error states ────────────────────────────────────────────────────

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bichar.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: bichar.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Caught Up',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: bichar.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone likes or comments\non your posts, it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: bichar.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 40, color: bichar.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Could not load notifications\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: bichar.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
