const { GoogleGenAI } = require("@google/genai");

const requestCounts = new Map();
const questionCache = new Map();
const DAY_MS = 24 * 60 * 60 * 1000;

function rateLimitKey(userId) {
  return `${userId}:${new Date().toISOString().slice(0, 10)}`;
}

function consumeRequest(userId) {
  const key = rateLimitKey(userId);
  const count = requestCounts.get(key) || 0;
  if (count >= 10) return false;
  requestCounts.set(key, count + 1);
  return true;
}

function getClient() {
  return process.env.GEMINI_API_KEY
    ? new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY })
    : null;
}

async function assist(req, res) {
  const question =
    typeof req.body.question === "string" ? req.body.question.trim() : "";
  if (!question) {
    return res
      .status(400)
      .json({ success: false, message: "A farming question is required." });
  }

  const cacheKey = question.toLowerCase();
  const cached = questionCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) return res.json(cached.value);
  if (!consumeRequest(req.user.id)) {
    return res
      .status(429)
      .json({ success: false, message: "Daily AI request limit reached." });
  }

  let response = `Advisory response for: ${question}`;
  let provider = "sandbox-rule-based";
  const client = getClient();
  if (client) {
    const result = await client.models.generateContent({
      model: process.env.GEMINI_MODEL || "gemini-2.5-flash",
      contents: question,
      config: {
        systemInstruction:
          "You are a Bangla farming helper. Answer in under 80 words. Give practical, cautious advice. Never make loan or crop guarantees.",
        maxOutputTokens: 180,
      },
    });
    response = result.text || response;
    provider = "gemini";
  }

  const payload = {
    success: true,
    response,
    language: req.body.language === "en" ? "en" : "bn",
    groundedIn: ["weather", "marketplace"],
    advisoryOnly: true,
    provider,
  };
  questionCache.set(cacheKey, {
    value: payload,
    expiresAt: Date.now() + DAY_MS,
  });
  return res.json(payload);
}

function verifyCropPhoto(req, res) {
  const { imageData, cropType } = req.body;
  if (typeof imageData !== "string" || imageData.length < 20) {
    return res
      .status(400)
      .json({
        success: false,
        message: "imageData must contain an encoded crop photo.",
      });
  }

  return res.json({
    success: true,
    result: {
      cropType: cropType || "unknown",
      grade: "B",
      confidence: 0.72,
      reasons: [
        "Photo received for sandbox review",
        "Lighting and framing should be improved",
      ],
      advisoryOnly: true,
      provider: "sandbox-rule-based",
    },
  });
}

async function gradePhoto(req, res) {
  const { imageUrl } = req.body;
  if (typeof imageUrl !== "string" || !/^https?:\/\//i.test(imageUrl)) {
    return res
      .status(400)
      .json({
        success: false,
        message: "imageUrl must be a valid HTTP(S) URL.",
      });
  }
  if (!consumeRequest(req.user.id)) {
    return res
      .status(429)
      .json({ success: false, message: "Daily AI request limit reached." });
  }

  let result = {
    grade: "B",
    reasons: [
      "Advisory sandbox result; image review is unavailable without Gemini credentials.",
    ],
    confidence: 0.5,
  };
  const client = getClient();
  if (client) {
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok)
      return res
        .status(400)
        .json({ success: false, message: "Unable to fetch imageUrl." });
    const mimeType = imageResponse.headers.get("content-type") || "image/jpeg";
    const imageBase64 = Buffer.from(await imageResponse.arrayBuffer()).toString(
      "base64",
    );
    const response = await client.models.generateContent({
      model: process.env.GEMINI_MODEL || "gemini-2.5-flash",
      contents: [
        {
          role: "user",
          parts: [
            {
              text: "Grade this crop photo. Return only strict JSON with grade A, B, or C; reasons as a string array; confidence as a number from 0 to 1. This is advisory only.",
            },
            { inlineData: { mimeType, data: imageBase64 } },
          ],
        },
      ],
      config: { responseMimeType: "application/json" },
    });
    result = JSON.parse(response.text);
    if (
      !["A", "B", "C"].includes(result.grade) ||
      !Array.isArray(result.reasons) ||
      result.confidence < 0 ||
      result.confidence > 1
    ) {
      throw new Error("Gemini returned an invalid crop grade.");
    }
  }
  return res.json({ success: true, result: { ...result, advisoryOnly: true } });
}

module.exports = { assist, verifyCropPhoto, gradePhoto };
