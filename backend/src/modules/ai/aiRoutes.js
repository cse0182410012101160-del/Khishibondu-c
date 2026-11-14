const express = require("express");
const router = express.Router();
const controller = require("./aiController");
const { authenticateToken } = require("../../middleware/auth");

router.post("/assist", authenticateToken, controller.assist);
router.post("/crop-quality", authenticateToken, controller.verifyCropPhoto);
router.post("/grade-photo", authenticateToken, controller.gradePhoto);

module.exports = router;
