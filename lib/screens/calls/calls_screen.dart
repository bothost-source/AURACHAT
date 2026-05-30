import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_theme.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<Map<String, dynamic>> _calls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  // NEW: Load real calls from storage
  Future<void> _loadCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final callsData = prefs.getStringList('call_history') ?? [];
    
    setState(() {
      _calls = callsData.map((call) {
        // Parse call data
        final parts = call.split('|');
        return {
          'name': parts[0],
          'type': parts[1],
          'time': parts[2],
          'answered': parts[3] == 'true',
          'isVideo': parts[4] == 'true',
        };
      }).toList();
      _isLoading = false;
    });
  }

  // NEW: Save a call to history
  Future<void> _saveCall(String name, String type, bool answered, bool isVideo) async {
    final prefs = await SharedPreferences.getInstance();
    final callsData = prefs.getStringList('call_history') ?? [];
    
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    callsData.insert(0, '$name|$type|$timeStr|$answered|$isVideo');
    
    // Keep only last 100 calls
    if (callsData.length > 100) {
      callsData.removeLast();
    }
    
    await prefs.setStringList('call_history', callsData);
    await _loadCalls();
  }

  // NEW: Show add contact dialog
  void _showAddContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('New Call', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contact Name',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person, color: AppTheme.textTertiary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.phone, color: AppTheme.textTertiary),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      Navigator.pop(context);
                      _makeCall(nameController.text, false); // Voice call
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Voice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      Navigator.pop(context);
                      _makeCall(nameController.text, true); // Video call
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // NEW: Make a real call
  void _makeCall(String name, bool isVideo) {
    // TODO: Integrate with WebRTC or call API for real calls
    // For now, show call screen and save to history
    
    _saveCall(name, 'outgoing', true, isVideo);
    
    // Show call UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CallDialog(
        name: name,
        isVideo: isVideo,
        onEndCall: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _calls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 80,
                        color: AppTheme.textTertiary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No calls yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button below to make a call',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _calls.length,
                  itemBuilder: (context, index) {
                    final call = _calls[index];
                    return _buildCallTile(
                      call['name'],
                      call['type'],
                      call['time'],
                      call['answered'],
                      call['isVideo'],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContact,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }

  Widget _buildCallTile(String name, String type, String time, bool answered, bool isVideo) {
    IconData icon;
    Color color;
    
    if (type == 'missed') {
      icon = Icons.call_missed;
      color = AppTheme.error;
    } else if (type == 'outgoing') {
      icon = Icons.call_made;
      color = AppTheme.primaryGreen;
    } else {
      icon = Icons.call_received;
      color = AppTheme.primaryGreen;
    }

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          if (isVideo)
            const Icon(Icons.videocam, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppTheme.primaryGreen),
            onPressed: () => _makeCall(name, true),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: AppTheme.primaryGreen),
            onPressed: () => _makeCall(name, false),
          ),
        ],
      ),
    );
  }
}

// NEW: Call Dialog UI
class _CallDialog extends StatefulWidget {
  final String name;
  final bool isVideo;
  final VoidCallback onEndCall;

  const _CallDialog({
    required this.name,
    required this.isVideo,
    required this.onEndCall,
  });

  @override
  State<_CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<_CallDialog> {
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Spacer(),
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isVideo ? 'Video call...' : 'Calling...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            // Call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(
                  _isMuted ? Icons.mic_off : Icons.mic,
                  _isMuted ? AppTheme.error : AppTheme.bgElevated,
                  () => setState(() => _isMuted = !_isMuted),
                ),
                _buildCallButton(
                  Icons.call_end,
                  AppTheme.error,
                  widget.onEndCall,
                  size: 64,
                ),
                _buildCallButton(
                  _isSpeaker ? Icons.volume_up : Icons.volume_down,
                  _isSpeaker ? AppTheme.primaryGreen : AppTheme.bgElevated,
                  () => setState(() => _isSpeaker = !_isSpeaker),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color color, VoidCallback onTap, {double size = 56}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size == 64 ? 32 : 24,
        ),
      ),
    );
  }
}
