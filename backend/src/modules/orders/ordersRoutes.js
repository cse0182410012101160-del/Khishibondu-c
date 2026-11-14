const express = require("express");
const router = express.Router();
const ordersController = require("./ordersController");
const { authenticateToken, authorizeRole } = require("../../middleware/auth");

router.get("/", authenticateToken, ordersController.getOrders);
router.put(
  "/disputes/:id/resolve",
  authenticateToken,
  authorizeRole("admin"),
  ordersController.resolveOrderDispute,
);
router.post(
  "/:id/dispute",
  authenticateToken,
  authorizeRole("buyer", "farmer"),
  ordersController.createDispute,
);
router.get("/:id", authenticateToken, ordersController.getOrderById);
router.put(
  "/:id/status",
  authenticateToken,
  ordersController.updateOrderStatus,
);
router.put(
  "/:id/confirm-delivery",
  authenticateToken,
  ordersController.confirmDelivery,
);

module.exports = router;
