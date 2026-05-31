import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../themes/app_theme.dart';

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final StatusType type;
  final String content; // Text or file path
  final DateTime createdAt;
  final StatusDuration duration;
  final List<String> viewedBy;

  StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.content,
    required this.createdAt,
    this.duration = StatusDuration.hours24,
    this.viewedBy = const [],
  });

  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    switch (duration) {
      case StatusDuration.hours24:
        return diff.inHours >= 24;
      case StatusDuration.hours48:
        return diff.inHours >= 48;
      case StatusDuration.days3:
        return diff.inDays >= 3;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

enum StatusType { text, photo, video, voice }
enum StatusDuration { hours24, hours48, days3 }

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<StatusModel> _statuses = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  bool _isPremium = false; // TODO: Check from user subscription

  @override
  void initState() {
    super.initState();
    _loadStatuses();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isPremium = prefs.getBool('is_premium') ?? false);
  }

  // Load statuses from storage
  Future<void> _loadStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final statusData = prefs.getStringList('my_statuses') ?? [];
    
    final loaded = statusData.map((s) {
      final parts = s.split('|');
      return StatusModel(
        id: parts[0],
        userId: parts[1],
        userName: parts[2],
        type: StatusType.values[int.parse(parts[3])],
        content: parts[4],
        createdAt: DateTime.parse(parts[5]),
        duration: StatusDuration.values[int.parse(parts[6])],
        viewedBy: parts[7].isEmpty ? [] : parts[7].split(','),
      );
    }).where((s) => !s.isExpired).toList();

    setState(() {
      _statuses = loaded;
      _isLoading = false;
    });
  }

  // Save status to storage
  Future<void> _saveStatus(StatusModel status) async {
    final prefs = await SharedPreferences.getInstance();
    final statusData = prefs.getStringList('my_statuses') ?? [];
    
    // Format: id|userId|userName|typeIndex|content|createdAt|durationIndex|viewedBy
    final data = '${status.id}|${status.userId}|${status.userName}|${status.type.index}|${status.content}|${status.createdAt}|${status.duration.index}|${status.viewedBy.join(',')}';
    statusData.add(data);
    
    await prefs.setStringList('my_statuses', statusData);
    await _loadStatuses();
  }

  // Show status options
  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              Icons.text_fields,
              'Text',
              AppTheme.accentBlue,
              () {
                Navigator.pop(context);
                _showTextStatusDialog();
              },
            ),
            _buildOptionTile(
              Icons.camera_alt,
              'Camera',
              AppTheme.error,
              () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            _buildOptionTile(
              Icons.photo_library,
              'Gallery',
              AppTheme.accentPurple,
              () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            _buildOptionTile(
              Icons.videocam,
              'Video',
              AppTheme.warning,
              () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            _buildOptionTile(
              Icons.mic,
              'Voice',
              AppTheme.primaryGreen,
              () {
                Navigator.pop(context);
                _recordVoice();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  // Text Status
  void _showTextStatusDialog() {
    final controller = TextEditingController();
    Color selectedColor = AppTheme.primaryGreen;
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.accentBlue,
      AppTheme.accentPurple,
      AppTheme.accentPink,
      AppTheme.warning,
      AppTheme.error,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.bgModal,
          title: const Text('Text Status', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type a status...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors.map((color) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty) return;
                Navigator.pop(context);
                _postStatus(
                  StatusType.text,
                  controller.text,
                  backgroundColor: selectedColor,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _showDurationPicker(StatusType.photo, photo.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Pick from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
      if (media != null) {
        _showDurationPicker(StatusType.photo, media.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Record video
  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        _showDurationPicker(StatusType.video, video.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Record voice
  void _recordVoice() {
    bool isRecording = false;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                isRecording ? 'Recording...' : 'Hold to record',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onLongPressStart: (_) => setModalState(() => isRecording = true),
                onLongPressEnd: (_) {
                  setModalState(() => isRecording = false);
                  Navigator.pop(context);
                  // TODO: Save voice recording and post
                  _postStatus(StatusType.voice, 'voice_path_${DateTime.now().millisecondsSinceEpoch}');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isRecording ? 100 : 80,
                  height: isRecording ? 100 : 80,
                  decoration: BoxDecoration(
                    color: isRecording ? AppTheme.error : AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRecording ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Show duration picker (24h free, 48h/3days premium)
  void _showDurationPicker(StatusType type, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status Duration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDurationOption(
              '24 Hours',
              'Free',
              StatusDuration.hours24,
              true,
              type,
              content,
            ),
            _buildDurationOption(
              '48 Hours',
              'Premium',
              StatusDuration.hours48,
              _isPremium,
              type,
              content,
            ),
            _buildDurationOption(
              '3 Days',
              'Premium',
              StatusDuration.days3,
              _isPremium,
              type,
              content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(
    String title,
    String badge,
    StatusDuration duration,
    bool enabled,
    StatusType type,
    String content,
  ) {
    return ListTile(
      leading: Icon(
        Icons.timer,
        color: enabled ? AppTheme.primaryGreen : AppTheme.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primaryGreen.withOpacity(0.2) : AppTheme.textMuted.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? AppTheme.primaryGreen : AppTheme.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              _postStatus(type, content, duration: duration);
            }
          : () {
              // Show premium upgrade dialog
              _showPremiumDialog();
            },
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgModal,
        title: const Text('Premium Feature', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Upgrade to Premium to unlock 48-hour and 3-day status durations, plus exclusive wallpapers and stickers!',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to premium purchase
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Upgrade \$4.99'),
          ),
        ],
      ),
    );
  }

  // Post the status
  Future<void> _postStatus(
    StatusType type,
    String content, {
    StatusDuration duration = StatusDuration.hours24,
    Color? backgroundColor,
  }) async {
    final status = StatusModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'me',
      userName: 'You',
      type: type,
      content: content,
      createdAt: DateTime.now(),
      duration: duration,
    );

    await _saveStatus(status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status posted! Expires in ${_getDurationText(duration)}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  String _getDurationText(StatusDuration duration) {
    switch (duration) {
      case StatusDuration.hours24:
        return '24 hours';
      case StatusDuration.hours48:
        return '48 hours';
      case StatusDuration.days3:
        return '3 days';
    }
  }

  // View status
  void _viewStatus(StatusModel status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StatusViewerScreen(status: status),
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
        title: const Text('Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.bgModal,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'privacy',
                child: Text('Status Privacy', style: TextStyle(color: AppTheme.textPrimary)),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings', style: TextStyle(color: AppTheme.textPrimary)),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // My Status
                ListTile(
                  leading: Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.bgElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _statuses.isNotEmpty ? AppTheme.primaryGreen : AppTheme.divider,
                            width: _statuses.isNotEmpty ? 2.5 : 1,
                          ),
                        ),
                        child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  title: const Text(
                    'My Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _statuses.isNotEmpty
                        ? '${_statuses.length} status${_statuses.length > 1 ? 'es' : ''} • Tap to view'
                        : 'Tap to add status update',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                  onTap: _statuses.isNotEmpty ? () => _viewStatus(_statuses.last) : _showStatusOptions,
                ),
                const Divider(color: AppTheme.divider),

                // Recent Updates (Real statuses only - no demo)
                if (_statuses.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'MY STATUSES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textTertiary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  ..._statuses.map((status) => _buildMyStatusTile(status)),
                ],

                // Empty state
                if (_statuses.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: AppTheme.textTertiary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No statuses yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share photos, videos, text, or voice updates',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStatusOptions,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildMyStatusTile(StatusModel status) {
    IconData icon;
    Color color;
    
    switch (status.type) {
      case StatusType.text:
        icon = Icons.text_fields;
        color = AppTheme.accentBlue;
        break;
      case StatusType.photo:
        icon = Icons.image;
        color = AppTheme.accentPurple;
        break;
      case StatusType.video:
        icon = Icons.videocam;
        color = AppTheme.warning;
        break;
      case StatusType.voice:
        icon = Icons.mic;
        color = AppTheme.primaryGreen;
        break;
    }

    return ListTile(
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryGreen, width: 2.5),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
      ),
      title: Text(
        _getStatusTypeName(status.type),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            status.timeAgo,
            style: const TextStyle(color: AppTheme.textTertiary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: status.duration == StatusDuration.hours24
                  ? AppTheme.primaryGreen.withOpacity(0.2)
                  : AppTheme.accentPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getDurationLabel(status.duration),
              style: TextStyle(
                fontSize: 10,
                color: status.duration == StatusDuration.hours24
                    ? AppTheme.primaryGreen
                    : AppTheme.accentPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${status.viewedBy.length} views',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textTertiary),
        ],
      ),
      onTap: () => _viewStatus(status),
    );
  }

  String _getStatusTypeName(StatusType type) {
    switch (type) {
      case StatusType.text:
        return 'Text Status';
      case StatusType.photo:
        return 'Photo';
      case StatusType.video:
        return 'Video';
      case StatusType.voice:
        return 'Voice Note';
    }
  }

  String _getDurationLabel(StatusDuration duration) {
    switch (duration) {
      case StatusDuration.hours24:
        return '24H';
      case StatusDuration.hours48:
        return '48H';
      case StatusDuration.days3:
        return '3D';
    }
  }
}

// Status Viewer Screen
class _StatusViewerScreen extends StatefulWidget {
  final StatusModel status;

  const _StatusViewerScreen({required this.status});

  @override
  State<_StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<_StatusViewerScreen> {
  double _progress = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || _isPaused) return;
      setState(() => _progress += 0.01);
      if (_progress < 1) {
        _startProgress();
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: GestureDetector(
        onTapDown: (_) => setState(() => _isPaused = true),
        onTapUp: (_) => setState(() => _isPaused = false),
        child: Stack(
          children: [
            // Status Content
            Center(
              child: widget.status.type == StatusType.text
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      color: widget.status.content.startsWith('#')
                          ? Color(int.parse(widget.status.content.split('|')[1]))
                          : AppTheme.primaryGreen,
                      child: Center(
                        child: Text(
                          widget.status.content.split('|')[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : widget.status.type == StatusType.photo
                      ? Image.file(
                          File(widget.status.content),
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.image, size: 100, color: AppTheme.textTertiary),
            ),

            // Progress Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            // User Info
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.bgElevated,
                    child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.status.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.status.timeAgo,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Close Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
