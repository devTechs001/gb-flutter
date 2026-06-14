const express = require('express');
const jwt = require('jsonwebtoken');
const { authMiddleware, JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

const users = new Map();
const otpStore = new Map();

function generateToken(uid) {
  return jwt.sign(
    { uid, iat: Date.now() },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
}

function sanitizeUser(user) {
  if (!user) return null;
  return {
    uid: user.uid,
    phoneNumber: user.phoneNumber,
    displayName: user.displayName,
    photoURL: user.photoURL,
    status: user.status,
    about: user.about,
    isOnline: user.isOnline || false,
    lastSeen: user.lastSeen,
    createdAt: user.createdAt,
  };
}

router.post('/send-otp', (req, res) => {
  const { phoneNumber } = req.body;
  if (!phoneNumber) {
    return res.status(400).json({ success: false, error: 'Phone number required' });
  }

  const verificationId = Math.random().toString(36).substring(2, 8).toUpperCase();
  otpStore.set(verificationId, { phoneNumber, code: '123456', expiresAt: Date.now() + 300000 });

  console.log(`[DEV] OTP for ${phoneNumber}: ${verificationId} -> 123456`);

  res.json({ success: true, verificationId });
});

router.post('/verify-otp', (req, res) => {
  const { verificationId, smsCode } = req.body;
  if (!verificationId || !smsCode) {
    return res.status(400).json({ success: false, error: 'Verification ID and code required' });
  }

  const stored = otpStore.get(verificationId);
  if (!stored) {
    return res.status(400).json({ success: false, error: 'Invalid verification ID' });
  }

  if (Date.now() > stored.expiresAt) {
    otpStore.delete(verificationId);
    return res.status(400).json({ success: false, error: 'OTP expired' });
  }

  if (stored.code !== smsCode) {
    return res.status(400).json({ success: false, error: 'Invalid OTP' });
  }

  otpStore.delete(verificationId);

  const uid = 'user_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6);
  const token = generateToken(uid);

  const user = {
    uid,
    phoneNumber: stored.phoneNumber,
    displayName: '',
    photoURL: null,
    status: 'Hey there! I am using ZENO',
    about: '',
    isOnline: true,
    lastSeen: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  };
  users.set(uid, user);

  res.json({ success: true, token, uid, phone: stored.phoneNumber });
});

router.post('/register', (req, res) => {
  const { uid, displayName, phoneNumber, photoURL, status } = req.body;
  if (!uid || !displayName) {
    return res.status(400).json({ success: false, error: 'UID and display name required' });
  }

  const existing = users.get(uid);
  if (existing) {
    existing.displayName = displayName || existing.displayName;
    existing.photoURL = photoURL || existing.photoURL;
    existing.status = status || existing.status;
    users.set(uid, existing);
  } else {
    const user = {
      uid,
      phoneNumber: phoneNumber || '',
      displayName,
      photoURL: photoURL || null,
      status: status || 'Hey there! I am using ZENO',
      about: '',
      isOnline: true,
      lastSeen: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
    users.set(uid, user);
  }

  res.json({ success: true, uid });
});

router.get('/user/:uid', authMiddleware, (req, res) => {
  const user = users.get(req.params.uid);
  if (!user) {
    return res.status(404).json({ success: false, error: 'User not found' });
  }
  res.json({ success: true, user: sanitizeUser(user) });
});

router.put('/user/:uid', authMiddleware, (req, res) => {
  if (req.params.uid !== req.userId) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }

  const user = users.get(req.params.uid);
  if (!user) {
    return res.status(404).json({ success: false, error: 'User not found' });
  }

  const { displayName, photoURL, status, about } = req.body;
  if (displayName) user.displayName = displayName;
  if (photoURL) user.photoURL = photoURL;
  if (status) user.status = status;
  if (about) user.about = about;

  users.set(req.params.uid, user);
  res.json({ success: true, user: sanitizeUser(user) });
});

router.get('/users', authMiddleware, (req, res) => {
  const { q } = req.query;
  const allUsers = Array.from(users.values());

  if (q) {
    const query = q.toLowerCase();
    const filtered = allUsers.filter(u =>
      u.displayName.toLowerCase().includes(query) ||
      u.phoneNumber.includes(query)
    );
    return res.json({ success: true, users: filtered.map(sanitizeUser).slice(0, 20) });
  }

  res.json({ success: true, users: allUsers.map(sanitizeUser).slice(0, 50) });
});

router.get('/contacts', authMiddleware, (req, res) => {
  const { phones } = req.query;
  if (!phones) return res.json({ success: true, contacts: [] });

  const phoneList = phones.split(',').map(p => p.trim());
  const registered = phoneList.map(phone => {
    const user = Array.from(users.values()).find(u => u.phoneNumber === phone);
    return user ? { phone, isRegistered: true, ...sanitizeUser(user) } : { phone, isRegistered: false };
  });

  res.json({ success: true, contacts: registered });
});

router.post('/signout', authMiddleware, (req, res) => {
  const user = users.get(req.userId);
  if (user) {
    user.isOnline = false;
    user.lastSeen = new Date().toISOString();
    users.set(req.userId, user);
  }
  res.json({ success: true });
});

module.exports = router;
