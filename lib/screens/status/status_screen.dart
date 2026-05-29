import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Status'),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.bgModal,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'privacy', child: Text('Status Privacy', style: TextStyle(color: AppTheme.textPrimary))),
              const PopupMenuItem(value: 'settings', child: Text('Settings', style: TextStyle(color: AppTheme.textPrimary))),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: AppTheme.bgElevated, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
                  child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            subtitle: const Text('Tap to add status update', style: TextStyle(color: AppTheme.textTertiary)),
            onTap: () {},
          ),
          const Divider(color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('RECENT UPDATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 1)),
          ),
          _buildStatusTile('DANNY', '2m ago', true),
          _buildStatusTile('NICKY TECH', '10m ago', true),
          _buildStatusTile('ZEUS', '1h ago', false),
          _buildStatusTile('GUI - VII', '3h ago', false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusTile(String name, String time, bool hasUpdate) {
    return ListTile(
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: hasUpdate ? AppTheme.primaryGreen : AppTheme.divider, width: hasUpdate ? 2.5 : 1),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: AppTheme.bgElevated, shape: BoxShape.circle),
          child: Center(child: Text(name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen))),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      subtitle: Text(time, style: const TextStyle(color: AppTheme.textTertiary)),
      onTap: () {},
    );
  }
}
