import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class AppealScreen extends StatefulWidget {
  const AppealScreen({super.key});

  @override
  State<AppealScreen> createState() => _AppealScreenState();
}

class _AppealScreenState extends State<AppealScreen> {
  final _appealController = TextEditingController();
  bool _isSubmitting = false;

  void _submitAppeal() async {
    if (_appealController.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appeal submitted. We will review within 24-48 hours.'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Appeal Restriction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: AppTheme.warning, size: 20),
                      const SizedBox(width: 10),
                      const Text('Appeal Process', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem('Our team reviews appeals within 24-48 hours'),
                  _buildInfoItem('You may be asked for additional evidence'),
                  _buildInfoItem('Multiple false appeals may extend restrictions'),
                  _buildInfoItem('Decision is final and cannot be appealed again'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your Appeal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Explain why you believe this restriction was applied in error. Be specific and provide any relevant context.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appealController,
              maxLines: 8,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'I believe this restriction was applied in error because...',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAppeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.bgElevated,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Appeal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6), width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.warning, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4))),
        ],
      ),
    );
  }
}
