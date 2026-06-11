const express = require('express');
const router = express.Router();

// In-memory user store
const users = new Map();

router.post('/send-otp', (req, res) => {
  const { phoneNumber } = req.body;
  const verificationId = Math.random().toString(36).substring(2, 10);
  res.json({ success: true, verificationId, message: 'OTP sent (dev mode: use any 6-digit code)' });
});

router.post('/verify-otp', (req, res) => {
  const { verificationId, smsCode } = req.body;
  const token = 'jwt_' + Math.random().toString(36).substring(2);
  res.json({ success: true, token, message: 'Verified successfully' });
});

router.post('/register', (req, res) => {
  const { uid, displayName, phoneNumber, photoURL, status } = req.body;
  const user = {
    uid,
    displayName,
    phoneNumber,
    photoURL: photoURL || null,
    status: status || 'Hey there! I am using GB Chat',
    isOnline: true,
    lastSeen: Date.now(),
    createdAt: Date.now(),
    contacts: [],
    blockedUsers: [],
  };
  users.set(uid, user);
  res.json({ success: true, message: 'User registered', user });
});

router.get('/user/:uid', (req, res) => {
  const user = users.get(req.params.uid);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json({ user });
});

router.put('/user/:uid', (req, res) => {
  const existing = users.get(req.params.uid);
  if (!existing) return res.status(404).json({ error: 'User not found' });
  const updates = req.body;
  delete updates.uid;
  delete updates.phoneNumber;
  Object.assign(existing, updates);
  users.set(req.params.uid, existing);
  res.json({ success: true, user: existing });
});

router.get('/users', (req, res) => {
  const { q } = req.query;
  const allUsers = Array.from(users.values());
  if (q) {
    const filtered = allUsers.filter(u =>
      u.displayName?.toLowerCase().includes(q.toLowerCase()) ||
      u.phoneNumber?.includes(q)
    );
    return res.json({ users: filtered });
  }
  res.json({ users: allUsers });
});

router.get('/contacts', (req, res) => {
  const { phones } = req.query;
  if (!phones) return res.json({ contacts: [] });
  const phoneList = phones.split(',');
  const contacts = Array.from(users.values()).filter(u => phoneList.includes(u.phoneNumber));
  res.json({ contacts });
});

module.exports = router;
