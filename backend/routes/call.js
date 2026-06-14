const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();

const calls = [];

router.use(authMiddleware);

router.post('/log', (req, res) => {
  const { callerId, callerName, callerPhoto, receiverId, receiverName, receiverPhoto, type, status, direction } = req.body;

  if (callerId !== req.userId && receiverId !== req.userId) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }

  const call = {
    callId: 'call_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6),
    callerId,
    callerName,
    callerPhoto: callerPhoto || null,
    receiverId,
    receiverName,
    receiverPhoto: receiverPhoto || null,
    type: type || 'audio',
    status: status || 'missed',
    direction: direction || 'outgoing',
    duration: 0,
    timestamp: Date.now(),
  };

  calls.push(call);
  if (calls.length > 500) calls.shift();

  res.json({ success: true, call });
});

router.get('/:userId', (req, res) => {
  if (req.params.userId !== req.userId) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }

  const userCalls = calls.filter(c =>
    c.callerId === req.userId || c.receiverId === req.userId
  ).slice(-100).reverse();

  res.json({ success: true, calls: userCalls });
});

router.patch('/:callId', (req, res) => {
  const call = calls.find(c => c.callId === req.params.callId);
  if (call) {
    call.duration = req.body.duration || call.duration;
    call.status = req.body.status || call.status;
  }
  res.json({ success: true });
});

module.exports = router;
