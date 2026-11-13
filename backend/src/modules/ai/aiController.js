function assist(req, res) {
  const question = typeof req.body.question === 'string' ? req.body.question.trim() : '';
  if (!question) {
    return res.status(400).json({ success: false, message: 'A farming question is required.' });
  }

  return res.json({
    success: true,
    response: `Advisory response for: ${question}`,
    language: req.body.language === 'en' ? 'en' : 'bn',
    groundedIn: ['weather', 'marketplace'],
    advisoryOnly: true,
    provider: 'sandbox-rule-based'
  });
}

function verifyCropPhoto(req, res) {
  const { imageData, cropType } = req.body;
  if (typeof imageData !== 'string' || imageData.length < 20) {
    return res.status(400).json({ success: false, message: 'imageData must contain an encoded crop photo.' });
  }

  return res.json({
    success: true,
    result: {
      cropType: cropType || 'unknown',
      grade: 'B',
      confidence: 0.72,
      reasons: ['Photo received for sandbox review', 'Lighting and framing should be improved'],
      advisoryOnly: true,
      provider: 'sandbox-rule-based'
    }
  });
}

module.exports = { assist, verifyCropPhoto };
