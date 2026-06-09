import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'profile_layout.dart';

/// Premium verified upsell card — subtle gradient, badge icon, tap feedback.
class ProfileBannerCard extends StatefulWidget {
  const ProfileBannerCard({
    super.key,
    this.onTap,
    this.sponsorLabel = 'SPONSORED • BICHAR SETU',
    this.title = 'Be a Verified BicharSetu',
    this.subtitle = 'Get the exclusive verified badge and stand out.',
  });

  final VoidCallback? onTap;
  final String sponsorLabel;
  final String title;
  final String subtitle;

  @override
  State<ProfileBannerCard> createState() => _ProfileBannerCardState();
}

class _ProfileBannerCardState extends State<ProfileBannerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  bool _hovered = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.sponsorLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: bichar.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTap: widget.onTap,
                  child: AnimatedScale(
                    scale: _pressed ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ProfileLayout.cardRadius),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  bichar.accent.withValues(alpha: 0.55),
                                  bichar.accentLight.withValues(alpha: 0.35),
                                ]
                              : [
                                  bichar.accent.withValues(alpha: 0.92),
                                  bichar.accentLight.withValues(alpha: 0.78),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: bichar.accent.withValues(
                              alpha: _hovered ? 0.28 : 0.18,
                            ),
                            blurRadius: _hovered ? 22 : 16,
                            offset: Offset(0, _hovered ? 8 : 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(ProfileLayout.cardRadius),
                        child: InkWell(
                          onTap: widget.onTap,
                          borderRadius:
                              BorderRadius.circular(ProfileLayout.cardRadius),
                          splashColor: Colors.white.withValues(alpha: 0.12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.subtitle,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          fontSize: 12.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
