import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  String _privacyLabel(PrivacySetting setting) {
    switch (setting) {
      case PrivacySetting.everyone: return 'Everyone';
      case PrivacySetting.contacts: return 'My Contacts';
      case PrivacySetting.nobody: return 'Nobody';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: [
          // Phone Number Visibility
          _buildPrivacyTile(
            context: context,
            title: 'Phone Number',
            subtitle: 'Who can see my phone number',
            currentValue: user?.phoneVisibility ?? PrivacySetting.contacts,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('phone', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Last Seen & Online',
            subtitle: 'Who can see when you were last active',
            currentValue: user?.lastSeenVisibility ?? PrivacySetting.everyone,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('lastSeen', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Profile Photo',
            subtitle: 'Who can see your profile picture',
            currentValue: user?.profilePhotoVisibility ?? PrivacySetting.everyone,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('profilePhoto', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Forwarded Messages',
            subtitle: 'Who can forward your messages with your name',
            currentValue: user?.forwardMessageVisibility ?? PrivacySetting.everyone,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('forward', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Add to Groups',
            subtitle: 'Who can add you to groups and channels',
            currentValue: user?.addToGroups ?? PrivacySetting.contacts,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('groups', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Voice Calls',
            subtitle: 'Who can call you',
            currentValue: user?.voiceCallPermission ?? PrivacySetting.contacts,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('voiceCall', v),
          ),
          _buildPrivacyTile(
            context: context,
            title: 'Video Calls',
            subtitle: 'Who can video call you',
            currentValue: user?.videoCallPermission ?? PrivacySetting.contacts,
            options: PrivacySetting.values,
            onChanged: (v) => auth.updatePrivacySetting('videoCall', v),
          ),

          const Divider(color: AppTheme.divider),

          // Discovery
          _buildSectionHeader('Discovery'),
          SwitchListTile(
            title: const Text('Find by Phone Number', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
            subtitle: Text('Allow people to find you using your phone', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
            value: user?.allowFindingByPhone ?? true,
            onChanged: (v) {},
            activeColor: AppTheme.primaryGreen,
          ),
          SwitchListTile(
            title: const Text('Find by Username', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
            subtitle: Text('Allow people to find you using @username', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
            value: user?.allowFindingByUsername ?? true,
            onChanged: (v) {},
            activeColor: AppTheme.primaryGreen,
          ),

          const Divider(color: AppTheme.divider),

          // Blocked Users
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.block, color: AppTheme.error, size: 20),
            ),
            title: const Text('Blocked Users', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
            subtitle: Text('${user?.blockedUsers.length ?? 0} blocked', style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
            onTap: () => Navigator.pushNamed(context, '/blocked_users'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textTertiary, letterSpacing: 1.2)),
    );
  }

  Widget _buildPrivacyTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required PrivacySetting currentValue,
    required List<PrivacySetting> options,
    required Function(PrivacySetting) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _privacyLabel(currentValue),
          style: const TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
        ),
      ),
      onTap: () => _showPrivacyPicker(context, title, currentValue, options, onChanged),
    );
  }

  void _showPrivacyPicker(BuildContext context, String title, PrivacySetting current, List<PrivacySetting> options, Function(PrivacySetting) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgModal,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
              title: Text(_privacyLabel(option), style: const TextStyle(color: AppTheme.textPrimary)),
              trailing: current == option
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                  : null,
              onTap: () {
                onChanged(option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
