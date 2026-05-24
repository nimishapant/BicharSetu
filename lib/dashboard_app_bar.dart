import 'package:flutter/material.dart';

const Color _textDark = Color(0xFF1D1A29);
const Color _accent = Color(0xFF6A3DE8);

class DashboardAppBarContent extends StatelessWidget {
  const DashboardAppBarContent({
    super.key,
    required this.onProfileTap,
    required this.onSearchTap,
    required this.onSparkleTap,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSparkleTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _HeaderProfileAvatar(onTap: onProfileTap),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/bichar_logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BicharSetu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.search_rounded, color: _textDark, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            onPressed: onSparkleTap,
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFE53935),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

class _HeaderProfileAvatar extends StatelessWidget {
  const _HeaderProfileAvatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8E8EC),
            border: Border.all(
              color: const Color(0xFFE53935),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFFB0A8B8),
            size: 26,
          ),
        ),
      ),
    );
  }
}
