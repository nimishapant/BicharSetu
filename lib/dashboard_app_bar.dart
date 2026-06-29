import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

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
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _HeaderProfileAvatar(onTap: onProfileTap),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/bichar_logo.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  'BicharSetu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearchTap,
            icon: Icon(Icons.search_rounded, color: bichar.textPrimary, size: 26),
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
    final bichar = context.bichar;

    return StreamBuilder<UserModel?>(
      stream: AuthService().currentUserModelStream,
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.profilePhoto ?? '';
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
                color: bichar.searchFieldBackground,
                border: Border.all(
                  color: const Color(0xFFE53935),
                  width: 2,
                ),
              ),
              child: photoUrl.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      color: bichar.mutedIcon,
                      size: 26,
                    )
                  : ClipOval(
                      child: Image.network(
                        photoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person_rounded,
                            color: bichar.mutedIcon,
                            size: 26,
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
