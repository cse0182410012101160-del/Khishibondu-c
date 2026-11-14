const express = require("express");
const { authenticateToken, authorizeRole } = require("../../middleware/auth");
const controller = require("./agentController");

const router = express.Router();
router.use(authenticateToken, authorizeRole("agent"));
router.post("/farmers", controller.createFarmer);
router.post("/lots", controller.createLot);

module.exports = router;
