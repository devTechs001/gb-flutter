const express = require('express');
const router = express.Router();

const calls = [];

router.post('/log', (req, res) => {
  const callData = req.body;
  const call = {
    ...callData,
    callId: 'call_' + Date.now(),
    timestamp: Date.now(),
    participants: [callData.callerId, callData.receiverId],
  };
  calls.unshift(call);
  res.json({ call });
});

router.get('/:userId', (req, res) => {
  const userCalls = calls.filter(c =>
    c.participants?.includes(req.params.userId)
  );
  res.json({ calls: userCalls.slice(0, 50) });
});

router.patch('/:callId', (req, res) => {
  const call = calls.find(c => c.callId === req.params.callId);
  if (call) {
    call.duration = req.body.duration;
    call.status = 'ended';
  }
  res.json({ success: true });
});

module.exports = router;
