const express = require("express");
const controller = require("./pricesController");

const router = express.Router();
router.get("/", controller.getPrices);

module.exports = router;
