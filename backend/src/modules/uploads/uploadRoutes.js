const express = require('express');
const multer = require('multer');
const controller = require('./uploadController');

const router = express.Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 1024 * 1024 },
  fileFilter: (req, file, callback) => {
    callback(null, ['image/jpeg', 'image/png'].includes(file.mimetype));
  }
});

router.post('/crop-photo', upload.single('photo'), controller.uploadCropPhoto);

module.exports = router;
