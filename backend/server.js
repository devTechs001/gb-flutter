require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

const authRoutes = require('./routes/auth');
const { router: chatRoutes, chats, messages: chatMessages } = require('./routes/chat');
const mediaRoutes = require('./routes/media');
const callRoutes = require('./routes/call');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

const onlineUsers = new Map();

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'short' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.set('io', io);
app.set('onlineUsers', onlineUsers);

app.use('/api/auth', authRoutes);
app.use('/api/chats', chatRoutes);
app.use('/api/media', mediaRoutes);
app.use('/api/calls', callRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0', service: 'ZENO Chat' });
});

io.use((socket, next) => {
  const { token, userId } = socket.handshake.auth || {};
  if (token && userId) {
    try {
      const jwt = require('jsonwebtoken');
      const secret = process.env.JWT_SECRET || 'gb_chat_jwt_secret_key_2024';
      const decoded = jwt.verify(token, secret);
      socket.userId = decoded.uid;
    } catch (_) {
      socket.userId = userId;
    }
  } else if (userId) {
    socket.userId = userId;
  }
  next();
});

io.on('connection', (socket) => {
  const userId = socket.userId || socket.handshake.auth.userId;
  if (userId) {
    onlineUsers.set(userId, socket.id);
    socket.join(`user:${userId}`);
    io.emit('user_status', { userId, isOnline: true });
  }

  socket.on('join_chat', ({ chatId }) => socket.join(`chat:${chatId}`));
  socket.on('leave_chat', ({ chatId }) => socket.leave(`chat:${chatId}`));

  socket.on('typing', (data) => {
    socket.to(`chat:${data.chatId}`).emit('typing', data);
  });

  socket.on('send_message', (data) => {
    const msg = data.message || data;
    io.to(`chat:${data.chatId}`).emit('new_message', msg);
    io.to(`chat:${data.chatId}`).emit('chat_updated', {
      type: 'new_message',
      chatId: data.chatId,
      lastMessage: msg.content || '',
      lastMessageSender: msg.senderName || '',
      lastMessageType: msg.type || 'text',
      lastMessageTime: Date.now(),
    });
  });

  socket.on('group_create', (data) => {
    const { currentUid, groupName, groupPhoto, groupDescription, groupParticipants } = data;
    if (!currentUid || !groupName || !groupParticipants) return;
    const chatId = 'group_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6);
    const chat = {
      chatId, type: 'group',
      participants: groupParticipants,
      groupName, groupPhoto: groupPhoto || null,
      groupDescription: groupDescription || null,
      groupAdmin: currentUid,
      lastMessage: '', lastMessageSender: null,
      lastMessageType: null, lastMessageTime: null,
      createdAt: Date.now(), unreadCount: {},
      mutedBy: {}, pinnedBy: {}, archivedBy: {},
      isBroadcast: false, broadcastName: null,
    };
    chats.set(chatId, chat);
    groupParticipants.forEach(pid => {
      socket.to(`user:${pid}`).emit('chat_updated', { type: 'group_created', chatId, chat });
    });
    socket.emit('chat_updated', { type: 'group_created', chatId, chat });
  });

  socket.on('group_add_member', ({ groupId, userId, addedBy }) => {
    const chat = chats.get(groupId);
    if (!chat || chat.groupAdmin !== addedBy) return;
    if (!chat.participants.includes(userId)) {
      chat.participants.push(userId);
      chats.set(groupId, chat);
    }
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'member_added', chatId: groupId, userId, addedBy, chat });
    });
  });

  socket.on('group_remove_member', ({ groupId, userId, removedBy }) => {
    const chat = chats.get(groupId);
    if (!chat || chat.groupAdmin !== removedBy || userId === chat.groupAdmin) return;
    chat.participants = chat.participants.filter(p => p !== userId);
    if (chat.groupAdmin === userId) chat.groupAdmin = null;
    chats.set(groupId, chat);
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'member_removed', chatId: groupId, userId, removedBy, chat });
    });
    io.to(`user:${userId}`).emit('chat_updated', { type: 'removed_from_group', chatId: groupId, chat });
  });

  socket.on('group_promote', ({ groupId, userId, promotedBy }) => {
    const chat = chats.get(groupId);
    if (!chat || chat.groupAdmin !== promotedBy) return;
    chat.groupAdmin = userId;
    chats.set(groupId, chat);
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'admin_promoted', chatId: groupId, userId, promotedBy, chat });
    });
  });

  socket.on('group_demote', ({ groupId, userId, demotedBy }) => {
    const chat = chats.get(groupId);
    if (!chat || chat.groupAdmin !== demotedBy) return;
    chat.groupAdmin = null;
    chats.set(groupId, chat);
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'admin_demoted', chatId: groupId, userId, demotedBy, chat });
    });
  });

  socket.on('group_update_info', ({ groupId, info }) => {
    const chat = chats.get(groupId);
    if (!chat || chat.groupAdmin !== socket.userId) return;
    if (info.groupName) chat.groupName = info.groupName;
    if (info.groupDescription !== undefined) chat.groupDescription = info.groupDescription;
    if (info.groupPhoto) chat.groupPhoto = info.groupPhoto;
    chats.set(groupId, chat);
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'group_info_updated', chatId: groupId, info, chat });
    });
  });

  socket.on('group_exit', ({ groupId, userId }) => {
    const chat = chats.get(groupId);
    if (!chat) return;
    chat.participants = chat.participants.filter(p => p !== userId);
    if (chat.groupAdmin === userId && chat.participants.length > 0) {
      chat.groupAdmin = chat.participants[0];
    }
    if (chat.participants.length === 0) {
      chats.delete(groupId);
    } else {
      chats.set(groupId, chat);
    }
    chat.participants.forEach(pid => {
      io.to(`user:${pid}`).emit('chat_updated', { type: 'member_exited', chatId: groupId, userId, chat });
    });
    io.to(`user:${userId}`).emit('chat_updated', { type: 'exited_group', chatId: groupId });
  });

  socket.on('initiate_call', ({ receiverId, callData }) => {
    const receiverSocket = onlineUsers.get(receiverId);
    if (receiverSocket) io.to(receiverSocket).emit('incoming_call', callData);
  });

  socket.on('accept_call', ({ callId, userId: callerId }) => {
    const callerSocket = onlineUsers.get(callerId);
    if (callerSocket) io.to(callerSocket).emit('call_accepted', { callId });
  });

  socket.on('reject_call', ({ callId, userId: callerId }) => {
    const callerSocket = onlineUsers.get(callerId);
    if (callerSocket) io.to(callerSocket).emit('call_rejected', { callId });
  });

  socket.on('end_call', ({ callId, userId: otherUserId }) => {
    const otherSocket = onlineUsers.get(otherUserId);
    if (otherSocket) io.to(otherSocket).emit('call_ended', { callId });
  });

  socket.on('disconnect', () => {
    if (socket.userId) {
      onlineUsers.delete(socket.userId);
      io.emit('user_status', { userId: socket.userId, isOnline: false });
    }
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`ZENO Chat Server running on http://0.0.0.0:${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = { app, server, io };
