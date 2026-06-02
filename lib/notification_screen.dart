import 'package:flutter/material.dart';

const Color _bg = Color(0xFFF7F7FB);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _pinkBar = Color(0xFFFFF0F0);
const Color _accentRed = Color(0xFFE53935);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NotificationTopBar(showBackButton: showBackButton),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _pinkBar,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: _bg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/no_notification.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return const _NotificationFallbackArt();
                            },
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 36,
                          child: const _NotificationOverlayContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTopBar extends StatelessWidget {
  const _NotificationTopBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 4),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _textDark,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: _textDark, size: 26),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: _accentRed,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationOverlayContent extends StatelessWidget {
  const _NotificationOverlayContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8E8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_off_rounded,
            color: _accentRed,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'All Caught Up',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'No Notifications Yet',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _textMid,
          ),
        ),
      ],
    );
  }
}

class _NotificationFallbackArt extends StatelessWidget {
  const _NotificationFallbackArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8E8),
      child: const Center(
        child: Icon(
          Icons.notifications_off_rounded,
          size: 120,
          color: Color(0xFFFFB300),
        ),
      ),
    );
  }
}
