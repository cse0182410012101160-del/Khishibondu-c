const db = require("../../database/store");

function registerDevice(req, res) {
  const { token, platform } = req.body;
  if (!token)
    return res
      .status(400)
      .json({ success: false, message: "token is required." });
  const existing = db.deviceTokens.find((device) => device.token === token);
  if (existing) {
    existing.userId = req.user.id;
    existing.platform = platform || existing.platform;
  } else {
    db.deviceTokens.push({
      userId: req.user.id,
      token,
      platform: platform || "unknown",
      createdAt: new Date().toISOString(),
    });
  }
  return res.status(201).json({ success: true });
}

module.exports = { registerDevice };
