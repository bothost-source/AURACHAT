import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/bot_provider.dart';

class BotCreatorScreen extends StatefulWidget {
  const BotCreatorScreen({super.key});

  @override
  State<BotCreatorScreen> createState() => _BotCreatorScreenState();
}

class _BotCreatorScreenState extends State<BotCreatorScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _aiPowered = false;
  String _selectedModel = 'GPT-4o';
  bool _isLoading = false;

  final List<String> _aiModels = ['GPT-4o', 'GPT-4o Mini', 'Claude 3.5', 'Gemini Pro'];

  void _createBot() async {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await context.read<BotProvider>().createBot(
      name: _nameController.text,
      username: _usernameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      about: _aboutController.text.isEmpty ? null : _aboutController.text,
      aiPowered: _aiPowered,
      aiModel: _aiPowered ? _selectedModel : null,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bot created successfully!'), backgroundColor: AppTheme.success),
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
        title: const Text('Create Bot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.smart_toy, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Bot Name', _nameController, 'What users will see'),
            const SizedBox(height: 16),
            _buildTextField('Username', _usernameController, 'Unique @username for your bot', prefix: const Text('@', style: TextStyle(color: AppTheme.textTertiary, fontSize: 16))),
            const SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, 'Short description (max 120 chars)', maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('About', _aboutController, 'Detailed information about your bot', maxLines: 4),
            const SizedBox(height: 24),

            // AI Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _aiPowered ? AppTheme.primaryGreen : AppTheme.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('AI-Powered Bot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    subtitle: const Text('Enable GPT-4o intelligence for your bot', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                    value: _aiPowered,
                    onChanged: (v) => setState(() => _aiPowered = v),
                    activeColor: AppTheme.primaryGreen,
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                  ),
                  if (_aiPowered) ...[
                    const Divider(color: AppTheme.divider),
                    const SizedBox(height: 8),
                    const Text('Select AI Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _aiModels.map((model) => ChoiceChip(
                        label: Text(model),
                        selected: _selectedModel == model,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedModel = model);
                        },
                        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedModel == model ? AppTheme.primaryGreen : AppTheme.textSecondary,
                          fontWeight: _selectedModel == model ? FontWeight.w600 : FontWeight.normal,
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createBot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.bgElevated,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Bot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, Widget? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textTertiary),
            prefixIcon: prefix,
            filled: true,
            fillColor: AppTheme.bgInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
