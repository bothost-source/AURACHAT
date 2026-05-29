const jwt = require('jsonwebtoken');
const { moderationService } = require('./aiModerationService');

const connectedUsers = new Map(); // userId -> { socketId, status }
const userSockets = new Map(); // socketId -> userId

function setupSocketHandlers(io) {
  // Authentication middleware for Socket.IO
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.query.token;
      if (!token) {
        return next(new Error('Authentication required'));
      }

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

    // Track connected user
    connectedUsers.set(userId, {
      socketId: socket.id,
      status: 'online',
      lastSeen: new Date(),
    });
    userSockets.set(socket.id, userId);

    // Broadcast user online status
    socket.broadcast.emit('user_status', {
      userId,
      status: 'online',
      timestamp: new Date().toISOString(),
    });

    // Join user's rooms (chats, channels)
    socket.on('join_chat', (chatId) => {
      socket.join(chatId);
      console.log(`User ${userId} joined chat: ${chatId}`);
    });

    socket.on('leave_chat', (chatId) => {
      socket.leave(chatId);
      console.log(`User ${userId} left chat: ${chatId}`);
    });

    // Handle messages
    socket.on('send_message', async (data) => {
      try {
        const { chatId, content, type = 'text', replyTo, metadata } = data;

        // AI Moderation check
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

        // If restricted, only send to sender
        if (moderationResult.isRestricted) {
          socket.emit('message_restricted', {
            message,
            reason: moderationResult.restrictionReason,
          });

          // Check if user should be banned
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

        // Send delivery receipt to sender
        socket.emit('message_sent', {
          messageId: message.id,
          chatId,
          timestamp: message.createdAt,
        });

        // Simulate read receipt after delay
        setTimeout(() => {
          socket.emit('message_read', {
            messageId: message.id,
            chatId,
            readBy: [userId],
          });
        }, 2000);

      } catch (error) {
        console.error('Error handling message:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Typing indicators
    socket.on('typing', (data) => {
      const { chatId, isTyping } = data;
      socket.to(chatId).emit('user_typing', {
        userId,
        username: socket.username,
        chatId,
        isTyping,
      });
    });

    // Message reactions
    socket.on('add_reaction', (data) => {
      const { messageId, chatId, reaction } = data;
      io.to(chatId).emit('message_reaction', {
        messageId,
        userId,
        reaction,
        timestamp: new Date().toISOString(),
      });
    });

    // Read receipts
    socket.on('mark_read', (data) => {
      const { chatId, messageIds } = data;
      io.to(chatId).emit('messages_read', {
        userId,
        messageIds,
        timestamp: new Date().toISOString(),
      });
    });

    // Disconnect handler
    socket.on('disconnect', () => {
      console.log(`User disconnected: ${userId} (${socket.id})`);

      connectedUsers.set(userId, {
        ...connectedUsers.get(userId),
        status: 'offline',
        lastSeen: new Date(),
      });
      userSockets.delete(socket.id);

      // Broadcast offline status after delay
      setTimeout(() => {
        if (!userSockets.has(socket.id)) {
          socket.broadcast.emit('user_status', {
            userId,
            status: 'offline',
            lastSeen: new Date().toISOString(),
          });
        }
      }, 5000);
    });
  });
}

function getConnectedUsers() {
  return Array.from(connectedUsers.entries()).map(([userId, data]) => ({
    userId,
    ...data,
  }));
}

function getUserStatus(userId) {
  return connectedUsers.get(userId);
}

module.exports = { 
  setupSocketHandlers, 
  getConnectedUsers, 
  getUserStatus 
};
