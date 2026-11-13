const { createClient } = require('@supabase/supabase-js');
const { v4: uuidv4 } = require('uuid');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const bucket = process.env.SUPABASE_STORAGE_BUCKET;

async function uploadCropPhoto(req, res) {
  if (!supabaseUrl || !supabaseKey || !bucket) {
    return res.status(503).json({
      success: false,
      code: 'STORAGE_NOT_CONFIGURED',
      message: 'Supabase Storage is not configured.',
      details: {}
    });
  }

  if (!req.file || !['image/jpeg', 'image/png'].includes(req.file.mimetype)) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_FILE',
      message: 'Only JPEG and PNG files are supported.',
      details: {}
    });
  }

  const supabase = createClient(supabaseUrl, supabaseKey);
  const extension = req.file.mimetype === 'image/png' ? 'png' : 'jpg';
  const path = `crop-photos/${uuidv4()}.${extension}`;
  const { error } = await supabase.storage.from(bucket).upload(path, req.file.buffer, {
    contentType: req.file.mimetype,
    upsert: false
  });

  if (error) {
    throw error;
  }

  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return res.status(201).json({ success: true, url: data.publicUrl });
}

module.exports = { uploadCropPhoto };
