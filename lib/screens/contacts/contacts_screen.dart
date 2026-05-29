import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('New Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_add, color: AppTheme.textPrimary), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildActionTile(Icons.group, 'New Group', AppTheme.accentBlue),
          _buildActionTile(Icons.campaign, 'New Channel', AppTheme.warning),
          const Divider(color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('CONTACTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 1)),
          ),
          _buildContactTile('DANNY', '@danny_dev', true),
          _buildContactTile('NICKY TECH', '@nicky_tech', true),
          _buildContactTile('ZEUS', '@zeus_ai', false),
          _buildContactTile('GUI - VII', '@gui_vii', true),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      onTap: () {},
    );
  }

  Widget _buildContactTile(String name, String username, bool isOnline) {
    return ListTile(
      leading: Stack(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.bgElevated, shape: BoxShape.circle), child: Center(child: Text(name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)))),
          if (isOnline)
            Positioned(bottom: 1, right: 1, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.online, shape: BoxShape.circle, border: Border.all(color: AppTheme.bgPrimary, width: 2)))),
        ],
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      subtitle: Text(username, style: const TextStyle(color: AppTheme.textTertiary)),
      onTap: () {},
    );
  }
}
