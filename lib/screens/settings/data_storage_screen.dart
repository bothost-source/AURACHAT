import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../themes/app_theme.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  bool _isLoading = true;
  StorageBreakdown _storage = StorageBreakdown.empty();
  bool _photosAutoDownload = true;
  bool _videosAutoDownload = false;
  bool _documentsAutoDownload = true;

  @override
  void initState() {
    super.initState();
    _loadRealStorage();
  }

  Future<void> _loadRealStorage() async {
    final storage = await RealStorageTracker.getStorageBreakdown();
    if (mounted) {
      setState(() {
        _storage = storage;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Clear Cache?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'This will free up ${_formatBytes(_storage.cache)}. Your messages and media will not be deleted.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await RealStorageTracker.clearCache();
      await _loadRealStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully'), backgroundColor: AppTheme.primaryGreen),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Delete All Data?', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'This will permanently delete ALL messages, media, and app data. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Everything', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await RealStorageTracker.clearAllData();
      await _loadRealStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength ~/ 10).clamp(0, suffixes.length - 1);
    if (i >= suffixes.length) i = suffixes.length - 1;
    final size = bytes / (1 << (i * 10));
    return '${size.toStringAsFixed(size < 10 ? 2 : 1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final totalUsed = _storage.totalUsed;
    final deviceTotal = _storage.deviceTotal > 0 ? _storage.deviceTotal : (totalUsed * 2.5).toInt();
    final usagePercent = (totalUsed / deviceTotal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        title: const Text('Data and Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: _isLoading ? null : _loadRealStorage,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadRealStorage,
              color: AppTheme.primaryGreen,
              backgroundColor: AppTheme.bgSecondary,
              child: ListView(
                children: [
                  // === STORAGE USAGE SECTION ===
                  _buildSectionHeader('Storage Usage'),

                  // Total storage card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Storage Used',
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                            ),
                            Text(
                              _formatBytes(totalUsed),
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatBytes(deviceTotal - totalUsed)} free of ${_formatBytes(deviceTotal)}',
                          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: usagePercent,
                            minHeight: 8,
                            backgroundColor: AppTheme.bgElevated,
                            valueColor: AlwaysStoppedAnimation(
                              usagePercent > 0.9
                                  ? Colors.redAccent
                                  : usagePercent > 0.75
                                      ? Colors.orangeAccent
                                      : AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Breakdown rows
                        _buildBreakdownRow('Media (photos & videos)', _storage.media, AppTheme.accentPurple),
                        _buildBreakdownRow('Messages & chats', _storage.messages, AppTheme.primaryGreen),
                        _buildBreakdownRow('App data', _storage.app, Colors.blueAccent),
                        _buildBreakdownRow('Cache', _storage.cache, Colors.orangeAccent),
                        _buildBreakdownRow('Temporary files', _storage.temp, AppTheme.textTertiary),
                      ],
                    ),
                  ),

                  // Storage actions
                  ListTile(
                    leading: const Icon(Icons.cleaning_services, color: Colors.orangeAccent),
                    title: const Text('Clear Cache', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: Text(
                      'Free up ${_formatBytes(_storage.cache)} now',
                      style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
                    onTap: _storage.cache > 0 ? _clearCache : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    title: const Text('Delete All Data', style: TextStyle(color: Colors.redAccent)),
                    subtitle: const Text(
                      'Remove everything permanently',
                      style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
                    onTap: totalUsed > 0 ? _clearAllData : null,
                  ),

                  const Divider(color: AppTheme.bgElevated, height: 32),

                  // === AUTO-DOWNLOAD SECTION ===
                  _buildSectionHeader('Auto-Download'),
                  SwitchListTile(
                    title: const Text('Photos', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Automatically download photos', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                    value: _photosAutoDownload,
                    onChanged: (v) => setState(() => _photosAutoDownload = v),
                    activeColor: AppTheme.primaryGreen,
                    secondary: const Icon(Icons.photo, color: AppTheme.accentPurple),
                  ),
                  SwitchListTile(
                    title: const Text('Videos', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Automatically download videos (uses more data)', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                    value: _videosAutoDownload,
                    onChanged: (v) => setState(() => _videosAutoDownload = v),
                    activeColor: AppTheme.primaryGreen,
                    secondary: const Icon(Icons.videocam, color: Colors.redAccent),
                  ),
                  SwitchListTile(
                    title: const Text('Documents', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Automatically download PDFs and files', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                    value: _documentsAutoDownload,
                    onChanged: (v) => setState(() => _documentsAutoDownload = v),
                    activeColor: AppTheme.primaryGreen,
                    secondary: const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                  ),

                  const Divider(color: AppTheme.bgElevated, height: 32),

                  // === NETWORK SECTION ===
                  _buildSectionHeader('Network'),
                  ListTile(
                    leading: const Icon(Icons.data_usage, color: AppTheme.primaryGreen),
                    title: const Text('Data Usage Stats', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: Text(
                      'Sent: ${_formatBytes(_storage.networkSent)} · Received: ${_formatBytes(_storage.networkReceived)}',
                      style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
                    onTap: () {}, // Navigate to detailed stats if you build it later
                  ),
                  ListTile(
                    leading: const Icon(Icons.network_check, color: AppTheme.accentPurple),
                    title: const Text('Proxy Settings', style: TextStyle(color: AppTheme.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.wifi_tethering, color: Colors.blueAccent),
                    title: const Text('Use Less Data', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Lower quality media on mobile data', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBreakdownRow(String label, int bytes, Color color) {
    if (bytes <= 0) return const SizedBox.shrink();
    final percent = _storage.totalUsed > 0 ? (bytes / _storage.totalUsed) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            _formatBytes(bytes),
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${(percent * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textTertiary,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// === REAL STORAGE TRACKER ===
class StorageBreakdown {
  final int media;
  final int messages;
  final int app;
  final int cache;
  final int temp;
  final int networkSent;
  final int networkReceived;
  final int deviceTotal;

  const StorageBreakdown({
    required this.media,
    required this.messages,
    required this.app,
    required this.cache,
    required this.temp,
    required this.networkSent,
    required this.networkReceived,
    required this.deviceTotal,
  });

  int get totalUsed => media + messages + app + cache + temp;

  factory StorageBreakdown.empty() => const StorageBreakdown(
        media: 0,
        messages: 0,
        app: 0,
        cache: 0,
        temp: 0,
        networkSent: 0,
        networkReceived: 0,
        deviceTotal: 0,
      );
}

class RealStorageTracker {
  static Future<StorageBreakdown> getStorageBreakdown() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getApplicationCacheDirectory();
      final tempDir = await getTemporaryDirectory();

      // Media: photos, videos, voice notes, documents
      final mediaDir = Directory('${appDir.path}/media');
      final mediaSize = await _getDirSize(mediaDir);

      // Messages: chat databases, json files, etc.
      final messagesDir = Directory('${appDir.path}/messages');
      final messagesSize = await _getDirSize(messagesDir);

      // App data: databases, preferences, configs
      final appSize = await _getAppDataSize(appDir, exclude: [mediaDir.path, messagesDir.path, cacheDir.path, tempDir.path]);

      // Cache
      final cacheSize = await _getDirSize(cacheDir);

      // Temp files
      final tempSize = await _getDirSize(tempDir);

      // Network stats (from SharedPreferences or your own tracking)
      final networkStats = await _getNetworkStats();

      // Device total storage (best effort)
      final deviceTotal = await _getDeviceTotalStorage();

      return StorageBreakdown(
        media: mediaSize,
        messages: messagesSize,
        app: appSize,
        cache: cacheSize,
        temp: tempSize,
        networkSent: networkStats['sent'] ?? 0,
        networkReceived: networkStats['received'] ?? 0,
        deviceTotal: deviceTotal,
      );
    } catch (e) {
      // Fallback if permissions fail
      return StorageBreakdown.empty();
    }
  }

  static Future<int> _getDirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {
            // Skip files we can't read
          }
        }
      }
    } catch (_) {
      // Directory might be restricted
    }
    return total;
  }

  static Future<int> _getAppDataSize(Directory appDir, {required List<String> exclude}) async {
    int total = 0;
    try {
      await for (final entity in appDir.list(recursive: false)) {
        if (exclude.contains(entity.path)) continue;
        if (entity is Directory) {
          total += await _getDirSize(entity);
        } else if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  static Future<Map<String, int>> _getNetworkStats() async {
    // TODO: Integrate with your actual network tracking
    // For now, returns 0 — replace with SharedPreferences or your tracker
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // return {
    //   'sent': prefs.getInt('network_sent') ?? 0,
    //   'received': prefs.getInt('network_received') ?? 0,
    // };
    return {'sent': 0, 'received': 0};
  }

  static Future<int> _getDeviceTotalStorage() async {
    try {
      // Try to get from app directory's statfs equivalent
      final result = await Process.run('df', ['-k', '/']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        if (lines.length > 1) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            // Total blocks * 1024 bytes
            return (int.tryParse(parts[1]) ?? 0) * 1024;
          }
        }
      }
    } catch (_) {
      // df might not work on all devices
    }
    return 0; // Will fall back to estimate in UI
  }

  static Future<void> clearCache() async {
    final cacheDir = await getApplicationCacheDirectory();
    if (await cacheDir.exists()) {
      await _deleteContents(cacheDir);
    }
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await _deleteContents(tempDir);
    }
  }

  static Future<void> clearAllData() async {
    final appDir = await getApplicationDocumentsDirectory();
    if (await appDir.exists()) {
      await _deleteContents(appDir);
    }
    await clearCache();
  }

  static Future<void> _deleteContents(Directory dir) async {
    await for (final entity in dir.list()) {
      try {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      } catch (_) {
        // Skip files we can't delete
      }
    }
  }
}
