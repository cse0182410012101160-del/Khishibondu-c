const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");
const config = require("../../config");
const sharedConfig = require("../../shared/config");
const smsProvider = require("./smsProvider");
const db = require("../../database/store");

// Request OTP (+880 BD mobile format)
async function requestOtp(req, res) {
  const { phone } = req.body;
  if (!phone) {
    return res
      .status(400)
      .json({ success: false, message: "Phone number is required." });
  }

  // Normalize phone number to +880
  let normalizedPhone = phone.trim();
  if (normalizedPhone.startsWith("01")) {
    normalizedPhone = "+880" + normalizedPhone.substring(1);
  } else if (normalizedPhone.startsWith("8801")) {
    normalizedPhone = "+" + normalizedPhone;
  }

  // BD mobile validation regex: +8801[3-9]\d{8}
  const bdRegex = /^\+8801[3-9]\d{8}$/;
  if (!bdRegex.test(normalizedPhone)) {
    return res.status(400).json({
      success: false,
      message:
        "Invalid Bangladeshi phone number. Must match format +8801XXXXXXXXX.",
    });
  }

  const otp = "123456";
  const expiresAt = Date.now() + config.otpExpiryMinutes * 60 * 1000;
  if (sharedConfig.OTP_MODE === "live") {
    await smsProvider.sendOtp(normalizedPhone, otp);
  } else {
    console.log(`[OTP] ${normalizedPhone}: ${otp}`);
  }
  db.otpRequests.set(normalizedPhone, { otp, expiresAt });

  return res.json({
    success: true,
    message: `OTP sent successfully to ${normalizedPhone}.`,
    phone: normalizedPhone,
    ...(sharedConfig.OTP_MODE === "dev" ? { mockOtp: otp } : {}),
    expiresInMinutes: config.otpExpiryMinutes,
  });
}

// Verify OTP & Issue Token
function verifyOtp(req, res) {
  const { phone, otp } = req.body;
  if (!phone || !otp) {
    return res
      .status(400)
      .json({ success: false, message: "Phone and OTP are required." });
  }

  let normalizedPhone = phone.trim();
  if (normalizedPhone.startsWith("01")) {
    normalizedPhone = "+880" + normalizedPhone.substring(1);
  } else if (normalizedPhone.startsWith("8801")) {
    normalizedPhone = "+" + normalizedPhone;
  }

  const storedRecord = db.otpRequests.get(normalizedPhone);
  const isValidOtp =
    storedRecord &&
    storedRecord.otp === otp &&
    Date.now() <= storedRecord.expiresAt;

  if (!isValidOtp) {
    return res
      .status(400)
      .json({ success: false, message: "Invalid or expired OTP." });
  }

  db.otpRequests.delete(normalizedPhone);

  // Check if user exists
  let user = db.users.find((u) => u.phone === normalizedPhone);
  const isNewUser = !user;

  if (isNewUser) {
    // Return flag so client can navigate to role registration
    return res.json({
      success: true,
      isNewUser: true,
      phone: normalizedPhone,
      message:
        "OTP verified. Please complete your registration and select your role.",
    });
  }

  // Generate JWT token
  const token = jwt.sign(
    { id: user.id, phone: user.phone, role: user.role, name: user.name },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );

  return res.json({
    success: true,
    isNewUser: false,
    token,
    user,
  });
}

// Register user with explicit role and profile
function registerUser(req, res) {
  const {
    phone,
    name,
    role,
    division,
    district,
    upazila,
    mfsProvider,
    mfsNumber,
    nidNumber,
    companyName,
    tradeLicense,
    organizationName,
  } = req.body;

  if (!phone || !name || !role) {
    return res.status(400).json({
      success: false,
      message: "Phone, full name, and role are mandatory.",
    });
  }

  const validRoles = ["farmer", "buyer", "ngo", "agent", "admin"];
  if (!validRoles.includes(role)) {
    return res.status(400).json({
      success: false,
      message: `Invalid role. Must be one of: ${validRoles.join(", ")}`,
    });
  }

  let normalizedPhone = phone.trim();
  if (normalizedPhone.startsWith("01")) {
    normalizedPhone = "+880" + normalizedPhone.substring(1);
  }

  const existing = db.users.find((u) => u.phone === normalizedPhone);
  if (existing) {
    return res.status(409).json({
      success: false,
      message: "User already exists with this phone number. Please login.",
    });
  }

  const newUser = {
    id: `usr_${role}_${uuidv4().substring(0, 8)}`,
    phone: normalizedPhone,
    name,
    role,
    division: division || "Rajshahi",
    district: district || "Bogura",
    upazila: upazila || "Sadar",
    avatar:
      "https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&fit=crop",
    mfsProvider: mfsProvider || "bKash",
    mfsNumber: mfsNumber || normalizedPhone,
    nidNumber: nidNumber || null,
    companyName: companyName || null,
    tradeLicense: tradeLicense || null,
    organizationName: organizationName || null,
    rating: 5.0,
    ratingCount: 0,
    totalFulfilledOrders: 0,
    totalSalesVolumeBdt: 0,
    isKycVerified: true,
    createdAt: new Date().toISOString(),
  };

  db.users.push(newUser);

  const token = jwt.sign(
    {
      id: newUser.id,
      phone: newUser.phone,
      role: newUser.role,
      name: newUser.name,
    },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );

  return res.status(201).json({
    success: true,
    message: "User registration successful.",
    token,
    user: newUser,
  });
}

// Quick switch / demo login for testing all 4 roles effortlessly
function demoLogin(req, res) {
  if (process.env.NODE_ENV === "production") {
    return res
      .status(404)
      .json({ success: false, message: "Resource not found." });
  }
  const { role } = req.body;
  const user = db.users.find((u) => u.role === role);
  if (!user) {
    return res
      .status(404)
      .json({
        success: false,
        message: `Demo user for role ${role} not found.`,
      });
  }

  const token = jwt.sign(
    { id: user.id, phone: user.phone, role: user.role, name: user.name },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );

  return res.json({
    success: true,
    message: `Signed in as demo ${user.role} (${user.name})`,
    token,
    user,
  });
}

// Get current profile
function getMe(req, res) {
  return res.json({
    success: true,
    user: req.user,
  });
}

// List demo accounts
function getDemoAccounts(req, res) {
  return res.json({
    success: true,
    accounts: db.users.map((u) => ({
      id: u.id,
      name: u.name,
      role: u.role,
      phone: u.phone,
      division: u.division,
      district: u.district,
      organization:
        u.organizationName || u.companyName || "Independent Producer",
    })),
  });
}

module.exports = {
  requestOtp,
  verifyOtp,
  registerUser,
  demoLogin,
  getMe,
  getDemoAccounts,
};
