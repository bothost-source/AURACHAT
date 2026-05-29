import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(backgroundColor: AppTheme.bgSecondary, elevation: 0, title: const Text('Invite Friends')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
              child: const Icon(Icons.share, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Invite Friends to TARRIFIC', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Text('Share your invite link and earn rewards', style: TextStyle(color: AppTheme.textTertiary)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.bgSecondary, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('tarrific.chat/invite/user123', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  IconButton(icon: const Icon(Icons.copy, color: AppTheme.textTertiary, size: 18), onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
