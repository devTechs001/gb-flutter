const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');

const upload = multer({ dest: 'uploads/' });

router.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  res.json({
    success: true,
    url: `/uploads/${req.file.filename}`,
    fileName: req.file.originalname,
    size: req.file.size,
  });
});

router.post('/upload-multiple', upload.array('files', 10), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: 'No files uploaded' });
  }
  const files = req.files.map(f => ({
    url: `/uploads/${f.filename}`,
    fileName: f.originalname,
    size: f.size,
  }));
  res.json({ success: true, files });
});

router.delete('/delete', (req, res) => {
  const { url } = req.body;
  res.json({ success: true, message: 'File deleted' });
});

module.exports = router;
