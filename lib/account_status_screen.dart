import 'package:flutter/material.dart';
import 'model/account_status_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AccountStatusScreen(),
      ),
    );
  }

  Color _getStatusColor(AccountStanding standing) {
    switch (standing) {
      case AccountStanding.goodStanding:
        return Colors.green;
      case AccountStanding.warning:
        return Colors.orange;
      case AccountStanding.restricted:
      case AccountStanding.suspended:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AccountStanding standing) {
    switch (standing) {
      case AccountStanding.goodStanding:
        return Icons.check_circle_rounded;
      case AccountStanding.warning:
        return Icons.warning_rounded;
      case AccountStanding.restricted:
        return Icons.block_rounded;
      case AccountStanding.suspended:
        return Icons.gavel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final uid = AuthService().currentUid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: bichar.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Status',
          style: TextStyle(
            color: bichar.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<AccountStatusModel?>(
        stream: AuthService().getAccountStatusStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = snapshot.data;
          if (status == null) {
            return const Center(child: Text('No status information found.'));
          }

          final statusColor = _getStatusColor(status.standing);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Standing Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: bichar.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: bichar.border.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(status.standing),
                          color: statusColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        status.standing.label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        status.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: bichar.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Warning Count
                _InfoTile(
                  title: 'Warnings Received',
                  value: status.warningCount.toString(),
                  icon: Icons.error_outline_rounded,
                  color: status.warningCount > 0 ? Colors.orange : bichar.accent,
                ),
                
                const SizedBox(height: 32),
                
                // History Section
                Text(
                  'Recent Actions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (status.actions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: bichar.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bichar.border.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded, size: 32, color: bichar.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No history available',
                          style: TextStyle(
                            fontSize: 14,
                            color: bichar.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: status.actions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final action = status.actions.reversed.toList()[index];
                      return _ActionCard(action: action);
                    },
                  ),
                
                const SizedBox(height: 32),
                
                // Recommended Actions
                Text(
                  'Recommended Actions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _RecommendationCard(standing: status.standing),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bichar.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: bichar.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final AccountAction action;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final dateStr = '${action.timestamp.day}/${action.timestamp.month}/${action.timestamp.year}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bichar.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bichar.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  action.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: bichar.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(fontSize: 12, color: bichar.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.reason,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: bichar.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.standing});
  final AccountStanding standing;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    
    List<String> recommendations;
    switch (standing) {
      case AccountStanding.goodStanding:
        recommendations = [
          'Continue following Community Guidelines.',
          'Keep your interactions respectful.',
          'Secure your account with 2FA.'
        ];
        break;
      case AccountStanding.warning:
        recommendations = [
          'Review the Community Guidelines.',
          'Avoid repetitive violations to prevent restrictions.',
          'Consider deleting content that may be violating rules.'
        ];
        break;
      case AccountStanding.restricted:
        recommendations = [
          'Your ability to post or comment is limited.',
          'Wait for the restriction period to end.',
          'Contact support if you believe this was an error.'
        ];
        break;
      case AccountStanding.suspended:
        recommendations = [
          'Your account access is currently revoked.',
          'Appeal the suspension if you believe it is unjustified.',
          'Read our terms of service regarding permanent bans.'
        ];
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bichar.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bichar.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: recommendations.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: bichar.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  r,
                  style: TextStyle(
                    fontSize: 14,
                    color: bichar.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
