import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/bot_provider.dart';

class BotSettingsScreen extends StatelessWidget {
  const BotSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bots = context.watch<BotProvider>().myBots;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('My Bots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
            onPressed: () => Navigator.pushNamed(context, '/bot_creator'),
          ),
        ],
      ),
      body: bots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy_outlined, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text('No bots yet', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/bot_creator'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: const Text('Create Bot'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bots.length,
              itemBuilder: (context, index) {
                final bot = bots[index];
                return Card(
                  color: AppTheme.bgSecondary,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.smart_toy, color: Colors.white),
                    ),
                    title: Text(bot.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text('@${bot.username}', style: const TextStyle(color: AppTheme.primaryGreen)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bot.isActive ? AppTheme.success.withOpacity(0.2) : AppTheme.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bot.status.name.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: bot.isActive ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
