import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(backgroundColor: AppTheme.bgSecondary, elevation: 0, title: const Text('Channel')),
      body: const Center(child: Text('Channel View', style: TextStyle(color: AppTheme.textPrimary))),
    );
  }
}
