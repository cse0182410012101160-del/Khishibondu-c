const express = require("express");
const { authenticateToken } = require("../../middleware/auth");
const controller = require("./deviceController");

const router = express.Router();
router.post("/", authenticateToken, controller.registerDevice);

module.exports = router;
