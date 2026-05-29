import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Calls'),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add_call, color: AppTheme.textPrimary), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildCallTile('DANNY', 'incoming', 'Today, 10:30 AM', true),
          _buildCallTile('NICKY TECH', 'outgoing', 'Today, 9:15 AM', true),
          _buildCallTile('ZEUS', 'missed', 'Yesterday, 8:45 PM', false),
          _buildCallTile('GUI - VII', 'incoming', 'Yesterday, 3:20 PM', true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }

  Widget _buildCallTile(String name, String type, String time, bool answered) {
    IconData icon;
    Color color;
    if (type == 'missed') { icon = Icons.call_missed; color = AppTheme.error; }
    else if (type == 'outgoing') { icon = Icons.call_made; color = AppTheme.primaryGreen; }
    else { icon = Icons.call_received; color = AppTheme.primaryGreen; }

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: AppTheme.bgElevated, shape: BoxShape.circle),
        child: Center(child: Text(name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen))),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      subtitle: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(time, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.videocam, color: AppTheme.primaryGreen), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call, color: AppTheme.primaryGreen), onPressed: () {}),
        ],
      ),
    );
  }
}
