const jwt = require('jsonwebtoken');
const config = require('../config');
const db = require('../database/store');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required. Please sign in.'
    });
  }

  try {
    const decoded = jwt.verify(token, config.jwtSecret);
    const user = db.users.find(u => u.id === decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User belonging to this token no longer exists.'
      });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(403).json({
      success: false,
      message: 'Invalid or expired token.'
    });
  }
}

function authorizeRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Forbidden: role '${req.user ? req.user.role : 'anonymous'}' is not authorized to access this resource.`
      });
    }
    next();
  };
}

module.exports = {
  authenticateToken,
  authorizeRole
};

