function assertCanRaiseDispute({ user, order }) {
  if (
    !user ||
    !["buyer", "farmer"].includes(user.role) ||
    ![order.buyerId, order.farmerId].includes(user.id)
  ) {
    throw new Error(
      "Only the ordering buyer or farmer may raise a dispute by role.",
    );
  }
  if (
    !["IN_TRANSIT", "DELIVERED"].includes(String(order.status).toUpperCase())
  ) {
    throw new Error(
      "Dispute is only allowed while the order is in transit or delivered state.",
    );
  }
}

module.exports = { assertCanRaiseDispute };
