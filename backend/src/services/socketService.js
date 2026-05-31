const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const { moderationService } = require('./aiModerationService');

const connectedUsers = new Map();
const userSockets = new Map();

function setupSocketHandlers(io) {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.query.token;
      if (!token) return next(new Error('Authentication required'));

      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'tarrific-secret-key');
      socket.userId = decoded.userId;
      socket.username = decoded.username;
      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.userId;
    console.log(`User connected: ${userId} (${socket.id})`);

    connectedUsers.set(userId, { socketId: socket.id, status: 'online', lastSeen: new Date() });
    userSockets.set(socket.id, userId);

    socket.broadcast.emit('user_status', { userId, status: 'online', timestamp: new Date().toISOString() });

    socket.on('join_chat', (chatId) => socket.join(chatId));
    socket.on('leave_chat', (chatId) => socket.leave(chatId));

    socket.on('send_message', async (data) => {
      try {
        const { chatId, content, type = 'text', replyTo, metadata } = data;

        const moderationResult = moderationService.analyzeContent(content, userId);

        const message = {
          id: `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
          chatId,
          senderId: userId,
          senderName: socket.username,
          type,
          content,
          replyTo,
          metadata,
          moderationResult,
          status: moderationResult.isRestricted ? 'restricted' : 'sent',
          createdAt: new Date().toISOString(),
        };

        if (moderationResult.isRestricted) {
          socket.emit('message_restricted', { message, reason: moderationResult.restrictionReason });

          if (moderationService.shouldBanUser(userId)) {
            socket.emit('account_banned', {
              reason: 'Multiple violations of community guidelines',
              strikes: moderationService.getUserStrikeCount(userId),
            });
            socket.disconnect(true);
            return;
          }
          return;
        }

        // Broadcast to chat room
        io.to(chatId).emit('new_message', message);

        socket.emit('message_sent', { messageId: message.id, chatId, timestamp: message.createdAt });

        setTimeout(() => {
          socket.emit('message_read', { messageId: message.id, chatId, readBy: [userId] });
        }, 2000);

        // ==================== PUSH NOTIFICATION ====================
        // Send push to offline users in this chat
        sendPushToChatParticipants(chatId, userId, socket.username, content, type);

      } catch (error) {
        console.error('Error handling message:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    socket.on('typing', (data) => {
      const { chatId, isTyping } = data;
      socket.to(chatId).emit('user_typing', { userId, username: socket.username, chatId, isTyping });
    });

    socket.on('add_reaction', (data) => {
      const { messageId, chatId, reaction } = data;
      io.to(chatId).emit('message_reaction', { messageId, userId, reaction, timestamp: new Date().toISOString() });
    });

    socket.on('mark_read', (data) => {
      const { chatId, messageIds } = data;
      io.to(chatId).emit('messages_read', { userId, messageIds, timestamp: new Date().toISOString() });
    });

    socket.on('disconnect', () => {
      console.log(`User disconnected: ${userId} (${socket.id})`);
      connectedUsers.set(userId, { ...connectedUsers.get(userId), status: 'offline', lastSeen: new Date() });
      userSockets.delete(socket.id);

      setTimeout(() => {
        if (!userSockets.has(socket.id)) {
          socket.broadcast.emit('user_status', { userId, status: 'offline', lastSeen: new Date().toISOString() });
        }
      }, 5000);
    });
  });
}

// ==================== PUSH NOTIFICATION FUNCTION ====================
async function sendPushToChatParticipants(chatId, senderId, senderName, content, type) {
  try {
    const db = admin.firestore();

    // Get chat participants
    const chatDoc = await db.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) return;

    const participants = chatDoc.data().participants || [];
    const recipients = participants.filter(id => id !== senderId);

    for (const userId of recipients) {
      // Skip if user is online (they already got it via Socket.IO)
      if (connectedUsers.has(userId) && connectedUsers.get(userId).status === 'online') continue;

      // Get user's FCM token
      const userDoc = await db.collection('users').doc(userId).get();
      const token = userDoc.data()?.fcmToken;
      if (!token) continue;

      // Check if chat is muted
      const settingsDoc = await db.collection('user_settings').doc(userId).get();
      const mutedChats = settingsDoc.data()?.mutedChats || [];
      if (mutedChats.includes(chatId)) continue;

      // Format body
      let body = content;
      if (type === 'image') body = '📷 Photo';
      else if (type === 'video') body = '🎥 Video';
      else if (type === 'voice') body = '🎙️ Voice message';
      else if (content.length > 100) body = content.substring(0, 100) + '...';

      // Send push
      await admin.messaging().send({
        token: token,
        notification: {
          title: senderName,
          body: body,
        },
        data: {
          chatId: chatId,
          senderId: senderId,
          type: type,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'tarrific_chat_channel',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      console.log(`Push sent to ${userId}`);
    }
  } catch (error) {
    console.error('Push notification error:', error.message);
  }
}

function getConnectedUsers() {
  return Array.from(connectedUsers.entries()).map(([userId, data]) => ({ userId, ...data }));
}

function getUserStatus(userId) {
  return connectedUsers.get(userId);
}

module.exports = { setupSocketHandlers, getConnectedUsers, getUserStatus };
