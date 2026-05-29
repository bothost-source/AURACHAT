import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(backgroundColor: AppTheme.bgSecondary, elevation: 0, title: const Text('Notifications')),
      body: ListView(
        children: [
          _buildSectionHeader('Messages'),
          SwitchListTile(title: const Text('Message Tones', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          SwitchListTile(title: const Text('Group Notifications', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          SwitchListTile(title: const Text('Channel Notifications', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          _buildSectionHeader('Calls'),
          SwitchListTile(title: const Text('Voice Calls', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          SwitchListTile(title: const Text('Video Calls', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          _buildSectionHeader('Other'),
          SwitchListTile(title: const Text('In-App Sounds', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          SwitchListTile(title: const Text('In-App Vibrate', style: TextStyle(color: AppTheme.textPrimary)), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
          SwitchListTile(title: const Text('Show Preview', style: TextStyle(color: AppTheme.textPrimary)), subtitle: const Text('Show message content in notifications'), value: true, onChanged: (v) {}, activeColor: AppTheme.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 1)));
}
