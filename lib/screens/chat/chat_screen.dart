import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final chat = chatProvider.selectedChat;
    final messages = chatProvider.messages;

    if (chat == null) {
      return const Scaffold(body: Center(child: Text('No chat selected')));
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: _buildChatAppBar(chat),
      body: Column(
        children: [
          // AI Moderation Banner (if any message is flagged)
          if (messages.any((m) => m.isFlaggedByAI))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.warning.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppTheme.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Moderation is active. Some messages may be restricted.',
                      style: TextStyle(fontSize: 12, color: AppTheme.warning, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message.senderId == 'me';
                final showAvatar = !isMe && (index == messages.length - 1 || messages[messages.length - index].senderId != message.senderId);
                return _buildMessageBubble(message, isMe, showAvatar);
              },
            ),
          ),

          // Input Area
          _buildInputArea(chatProvider),
        ],
      ),
    );
  }

  AppBar _buildChatAppBar(ChatModel chat) {
    final participant = chat.participants.isNotEmpty ? chat.participants.first : null;
    final isOnline = participant?.status == UserStatus.online;

    return AppBar(
      backgroundColor: AppTheme.bgSecondary,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: () => Navigator.pushNamed(context, '/public_profile'),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
              child: chat.isSelfChat
                  ? const Icon(Icons.bookmark, color: AppTheme.primaryGreen, size: 20)
                  : Center(
                      child: Text(
                        chat.displayName.isNotEmpty ? chat.displayName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          chat.displayName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (participant?.isVerified ?? false) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(color: AppTheme.verifiedBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                  if (chat.isSelfChat)
                    const Text('Your personal space', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary))
                  else if (isOnline)
                    const Text('online', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen))
                  else if (participant?.lastSeen != null)
                    Text('last seen ${participant!.lastSeen!.hour}:${participant.lastSeen!.minute.toString().padLeft(2, '0')}', 
                      style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary))
                  else
                    const Text('offline', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam, color: AppTheme.textPrimary), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call, color: AppTheme.textPrimary), onPressed: () {}),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
          color: AppTheme.bgModal,
          itemBuilder: (context) => [
            _buildMenuItem('view_contact', 'View Contact', Icons.person),
            _buildMenuItem('media', 'Media, Links, Docs', Icons.folder),
            _buildMenuItem('search', 'Search', Icons.search),
            _buildMenuItem('mute', 'Mute Notifications', Icons.notifications_off),
            _buildMenuItem('disappearing', 'Disappearing Messages', Icons.timer),
            _buildMenuItem('wallpaper', 'Wallpaper', Icons.wallpaper),
            _buildMenuItem('report', 'Report', Icons.report, color: AppTheme.error),
            _buildMenuItem('block', 'Block', Icons.block, color: AppTheme.error),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon, {Color? color}) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 14)),
      ]),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, bool showAvatar) {
    final isRestricted = message.isRestricted || message.contentFlag != ContentFlag.none;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 4,
          right: isMe ? 4 : 60,
          bottom: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar)
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    message.senderName?.isNotEmpty == true ? message.senderName![0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
              )
            else if (!isMe)
              const SizedBox(width: 34),

            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isRestricted
                      ? AppTheme.warning.withOpacity(0.1)
                      : isMe
                          ? AppTheme.sentMessage
                          : AppTheme.receivedMessage,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isRestricted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber, size: 12, color: AppTheme.warning),
                            const SizedBox(width: 4),
                            Text(
                              message.restrictionNote ?? 'Restricted by AI',
                              style: TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                    if (message.isReply && message.replyToMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(left: BorderSide(color: AppTheme.primaryGreen, width: 3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.replyToMessage!.senderName ?? 'Unknown',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message.replyToMessage!.content,
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                    if (message.isForwarded)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forward, size: 12, color: AppTheme.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              'Forwarded from ${message.forwardFromName ?? 'Unknown'}',
                              style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                            ),
                          ],
                        ),
                      ),

                    Text(
                      isRestricted ? '⚠️ This content has been restricted' : message.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isRestricted ? AppTheme.warning : AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.formattedTime,
                          style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text('edited', style: TextStyle(fontSize: 10, color: AppTheme.textTertiary, fontStyle: FontStyle.italic)),
                        ],
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == MessageStatus.read ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.status == MessageStatus.read ? AppTheme.accentCyan : AppTheme.textTertiary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(_showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined, color: AppTheme.textTertiary),
              onPressed: () => setState(() => _showEmoji = !_showEmoji),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppTheme.textTertiary),
                      onPressed: () => _showAttachmentMenu(),
                    ),
                    if (_messageController.text.isEmpty)
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: AppTheme.textTertiary),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  chatProvider.sendMessage(_messageController.text.trim());
                  _messageController.clear();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _messageController.text.isEmpty ? Icons.mic : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu() {
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
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAttachmentItem(Icons.image, 'Gallery', AppTheme.accentPurple),
                _buildAttachmentItem(Icons.camera_alt, 'Camera', AppTheme.error),
                _buildAttachmentItem(Icons.insert_drive_file, 'Document', AppTheme.accentBlue),
                _buildAttachmentItem(Icons.location_on, 'Location', AppTheme.success),
                _buildAttachmentItem(Icons.person, 'Contact', AppTheme.warning),
                _buildAttachmentItem(Icons.poll, 'Poll', AppTheme.accentPink),
                _buildAttachmentItem(Icons.gif, 'GIF', AppTheme.accentCyan),
                _buildAttachmentItem(Icons.mic, 'Audio', AppTheme.primaryGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
