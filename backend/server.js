require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

const authRoutes = require('./routes/auth');
const chatRoutes = require('./routes/chat');
const mediaRoutes = require('./routes/media');
const callRoutes = require('./routes/call');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: { origin: '*', methods: ['GET', 'POST'], credentials: true },
});

const onlineUsers = new Map();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.set('io', io);
app.set('onlineUsers', onlineUsers);

app.use('/api/auth', authRoutes);
app.use('/api/chats', chatRoutes);
app.use('/api/media', mediaRoutes);
app.use('/api/calls', callRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0', service: 'GB Chat' });
});

// Socket.IO
io.on('connection', (socket) => {
  const { userId } = socket.handshake.auth || {};
  if (userId) {
    onlineUsers.set(userId, socket.id);
    socket.userId = userId;
    socket.join(`user:${userId}`);
    io.emit('user_status', { userId, isOnline: true });
  }

  socket.on('join_chat', ({ chatId }) => socket.join(`chat:${chatId}`));
  socket.on('leave_chat', ({ chatId }) => socket.leave(`chat:${chatId}`));

  socket.on('typing', (data) => {
    socket.to(`chat:${data.chatId}`).emit('typing', data);
  });

  socket.on('send_message', (data) => {
    io.to(`chat:${data.chatId}`).emit('new_message', data.message || data);
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
  console.log(`GB Chat Server running on http://0.0.0.0:${PORT}`);
});

module.exports = { app, server, io };
