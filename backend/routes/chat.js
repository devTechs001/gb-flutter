const express = require('express');
const router = express.Router();

const chats = new Map();
const messages = new Map();

router.get('/:userId', (req, res) => {
  const userChats = Array.from(chats.values()).filter(c =>
    c.participants?.includes(req.params.userId)
  );
  userChats.sort((a, b) => (b.lastMessageTime || 0) - (a.lastMessageTime || 0));
  res.json({ chats: userChats });
});

router.post('/', (req, res) => {
  const chatData = req.body;
  const chatId = chatData.chatId || 'chat_' + Date.now();
  const chat = {
    chatId,
    ...chatData,
    lastMessageTime: null,
    unreadCount: {},
    mutedBy: {},
    pinnedBy: {},
    archivedBy: {},
    createdAt: Date.now(),
  };
  chats.set(chatId, chat);
  res.json({ chat });
});

router.get('/:chatId', (req, res) => {
  const chat = chats.get(req.params.chatId);
  if (!chat) return res.status(404).json({ error: 'Chat not found' });
  res.json({ chat });
});

router.post('/:chatId/messages', (req, res) => {
  const { chatId } = req.params;
  const msgData = req.body;
  const messageId = 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6);
  const message = {
    messageId,
    ...msgData,
    timestamp: Date.now(),
    readBy: {},
    deliveredTo: {},
    reactions: [],
  };

  if (!messages.has(chatId)) messages.set(chatId, []);
  messages.get(chatId).unshift(message);

  const chat = chats.get(chatId);
  if (chat) {
    let lastMsg = msgData.content;
    if (msgData.type === 'image') lastMsg = '📷 Photo';
    else if (msgData.type === 'video') lastMsg = '📹 Video';
    else if (msgData.type === 'audio') lastMsg = '🎵 Voice message';
    else if (msgData.type === 'document') lastMsg = '📎 ' + (msgData.fileName || 'Document');
    else if (msgData.type === 'location') lastMsg = '📍 Location';

    chat.lastMessage = lastMsg;
    chat.lastMessageSender = msgData.senderName;
    chat.lastMessageType = msgData.type;
    chat.lastMessageTime = Date.now();
  }

  res.json({ message });
});

router.get('/:chatId/messages', (req, res) => {
  const { chatId } = req.params;
  const limit = parseInt(req.query.limit) || 50;
  const chatMessages = messages.get(chatId) || [];
  res.json({ messages: chatMessages.slice(0, limit), hasMore: chatMessages.length > limit });
});

router.delete('/:chatId/messages/:messageId', (req, res) => {
  const { chatId, messageId } = req.params;
  const chatMessages = messages.get(chatId) || [];
  const idx = chatMessages.findIndex(m => m.messageId === messageId);
  if (idx !== -1) {
    chatMessages[idx].deleted = true;
    chatMessages[idx].content = 'This message was deleted';
  }
  res.json({ success: true });
});

router.patch('/:chatId/messages/:messageId', (req, res) => {
  const { chatId, messageId } = req.params;
  const chatMessages = messages.get(chatId) || [];
  const msg = chatMessages.find(m => m.messageId === messageId);
  if (msg) {
    Object.assign(msg, req.body);
    msg.editedAt = Date.now();
  }
  res.json({ success: true });
});

router.post('/:chatId/messages/:messageId/react', (req, res) => {
  const { chatId, messageId } = req.params;
  const { userId, reaction } = req.body;
  const chatMessages = messages.get(chatId) || [];
  const msg = chatMessages.find(m => m.messageId === messageId);
  if (msg) {
    msg.reactions = msg.reactions || [];
    const existing = msg.reactions.findIndex(r => r.userId === userId);
    if (existing !== -1) msg.reactions[existing].reaction = reaction;
    else msg.reactions.push({ userId, reaction });
  }
  res.json({ success: true });
});

router.patch('/:chatId/messages/:messageId/read', (req, res) => {
  const { chatId, messageId } = req.params;
  const { userId } = req.body;
  const chatMessages = messages.get(chatId) || [];
  const msg = chatMessages.find(m => m.messageId === messageId);
  if (msg) msg.readBy[userId] = true;
  res.json({ success: true });
});

router.patch('/:chatId', (req, res) => {
  const chat = chats.get(req.params.chatId);
  if (chat) Object.assign(chat, req.body);
  res.json({ success: true });
});

module.exports = router;
