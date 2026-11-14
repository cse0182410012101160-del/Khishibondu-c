const express = require("express");
const { authenticateToken, authorizeRole } = require("../../middleware/auth");
const controller = require("./mfiPortfolioController");

const router = express.Router();
router.get(
  "/portfolio",
  authenticateToken,
  authorizeRole("ngo", "admin"),
  controller.getPortfolio,
);

module.exports = router;
