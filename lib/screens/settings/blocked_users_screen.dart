import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blocked = context.watch<AuthProvider>().currentUser?.blockedUsers ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(backgroundColor: AppTheme.bgSecondary, elevation: 0, title: const Text('Blocked Users')),
      body: blocked.isEmpty
          ? Center(child: Text('No blocked users', style: TextStyle(color: AppTheme.textTertiary)))
          : ListView.builder(
              itemCount: blocked.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('User ${blocked[index]}', style: const TextStyle(color: AppTheme.textPrimary)),
                trailing: TextButton(
                  onPressed: () => context.read<AuthProvider>().unblockUser(blocked[index]),
                  child: const Text('Unblock', style: TextStyle(color: AppTheme.primaryGreen)),
                ),
              ),
            ),
    );
  }
}
