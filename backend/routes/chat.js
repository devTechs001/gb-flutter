const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();

const chats = new Map();
const messages = new Map();

router.use(authMiddleware);

router.get('/:userId', (req, res) => {
  if (req.params.userId !== req.userId) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }

  const userChats = Array.from(chats.values()).filter(c =>
    c.participants.includes(req.userId)
  ).sort((a, b) => (b.lastMessageTime || 0) - (a.lastMessageTime || 0));

  res.json({ success: true, chats: userChats.slice(0, 100) });
});

router.post('/', (req, res) => {
  const { currentUid, otherUid, type, groupName, groupPhoto, groupDescription, groupParticipants } = req.body;

  if (currentUid !== req.userId) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }

  const chatId = type === 'group'
    ? 'group_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6)
    : [currentUid, otherUid].sort().join('_');

  if (chats.has(chatId)) {
    return res.json({ success: true, chatId });
  }

  const chat = {
    chatId,
    type: type || 'individual',
    participants: groupParticipants || [currentUid, otherUid],
    groupName: groupName || null,
    groupPhoto: groupPhoto || null,
    groupDescription: groupDescription || null,
    groupAdmin: type === 'group' ? currentUid : null,
    lastMessage: '',
    lastMessageSender: null,
    lastMessageType: null,
    lastMessageTime: null,
    createdAt: Date.now(),
    unreadCount: {},
    mutedBy: {},
    pinnedBy: {},
    archivedBy: {},
    isBroadcast: false,
    broadcastName: null,
  };

  chats.set(chatId, chat);
  res.json({ success: true, chatId });
});

router.get('/:chatId/messages', (req, res) => {
  const chatMessages = messages.get(req.params.chatId) || [];
  const limit = Math.min(parseInt(req.query.limit) || 50, 100);
  const before = req.query.before ? parseInt(req.query.before) : Date.now();
  const page = req.query.page ? parseInt(req.query.page) : 1;

  const filtered = chatMessages
    .filter(m => m.timestamp < before)
    .sort((a, b) => b.timestamp - a.timestamp)
    .slice((page - 1) * limit, page * limit);

  res.json({ success: true, messages: filtered, hasMore: chatMessages.length > page * limit });
});

router.post('/:chatId/messages', (req, res) => {
  const { senderId, senderName, type, content, mediaURL, thumbnailURL, fileName, fileSize, duration, latitude, longitude, replyTo, isForwarded } = req.body;
  const messageId = 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 8);

  if (!chats.has(req.params.chatId)) {
    return res.status(404).json({ success: false, error: 'Chat not found' });
  }

  const message = {
    messageId,
    chatId: req.params.chatId,
    senderId,
    senderName,
    type: type || 'text',
    content: content || '',
    mediaURL: mediaURL || null,
    thumbnailURL: thumbnailURL || null,
    fileName: fileName || null,
    fileSize: fileSize || null,
    duration: duration || null,
    latitude: latitude || null,
    longitude: longitude || null,
    replyTo: replyTo || null,
    edited: false,
    deleted: false,
    timestamp: Date.now(),
    editedAt: null,
    readBy: {},
    deliveredTo: {},
    reactions: [],
    isForwarded: isForwarded || false,
    forwardedFrom: null,
  };

  if (!messages.has(req.params.chatId)) {
    messages.set(req.params.chatId, []);
  }
  messages.get(req.params.chatId).push(message);

  const chat = chats.get(req.params.chatId);
  chat.lastMessage = content || (type === 'image' ? '📷 Photo' : type === 'video' ? '🎥 Video' : type === 'audio' ? '🎵 Audio' : type === 'document' ? '📄 Document' : type === 'location' ? '📍 Location' : '');
  chat.lastMessageSender = senderName;
  chat.lastMessageType = type;
  chat.lastMessageTime = Date.now();
  chats.set(req.params.chatId, chat);

  const io = req.app.get('io');
  if (io) {
    chat.participants.forEach(pid => {
      if (pid !== senderId) {
        io.to(pid).emit('new_message', message);
      }
    });
  }

  res.json({ success: true, message });
});

router.delete('/:chatId/messages/:messageId', (req, res) => {
  const chatMessages = messages.get(req.params.chatId) || [];
  const msg = chatMessages.find(m => m.messageId === req.params.messageId);
  if (msg) {
    msg.deleted = true;
    msg.content = 'This message was deleted';
  }
  res.json({ success: true });
});

router.patch('/:chatId/messages/:messageId', (req, res) => {
  const chatMessages = messages.get(req.params.chatId) || [];
  const msg = chatMessages.find(m => m.messageId === req.params.messageId);
  if (msg) {
    msg.content = req.body.content || msg.content;
    msg.edited = true;
    msg.editedAt = Date.now();
  }
  res.json({ success: true });
});

router.post('/:chatId/messages/:messageId/react', (req, res) => {
  const chatMessages = messages.get(req.params.chatId) || [];
  const msg = chatMessages.find(m => m.messageId === req.params.messageId);
  if (msg) {
    const existing = msg.reactions.findIndex(r => r.userId === req.userId && r.reaction === req.body.reaction);
    if (existing >= 0) {
      msg.reactions.splice(existing, 1);
    } else {
      msg.reactions.push({ userId: req.userId, reaction: req.body.reaction });
    }
  }
  res.json({ success: true });
});

router.patch('/:chatId/messages/:messageId/read', (req, res) => {
  const chatMessages = messages.get(req.params.chatId) || [];
  const msg = chatMessages.find(m => m.messageId === req.params.messageId);
  if (msg) {
    msg.readBy[req.userId] = true;
  }
  res.json({ success: true });
});

router.patch('/:chatId', (req, res) => {
  const chat = chats.get(req.params.chatId);
  if (!chat) return res.status(404).json({ success: false });
  Object.assign(chat, req.body);
  res.json({ success: true });
});

module.exports = { router, chats, messages };
