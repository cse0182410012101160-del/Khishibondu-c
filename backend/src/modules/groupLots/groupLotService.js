const { v4: uuidv4 } = require("uuid");

function splitPayout(total, members) {
  const totalPaisa = Math.round(Number(total) * 100);
  const totalKg = members.reduce((sum, member) => sum + Number(member.kg), 0);
  if (
    !Number.isInteger(totalPaisa) ||
    totalPaisa < 0 ||
    !members.length ||
    totalKg <= 0
  ) {
    throw new Error("Total payout and member weights must be valid.");
  }

  let allocated = 0;
  const payout = members.map((member) => {
    const amountPaisa = Math.floor((totalPaisa * Number(member.kg)) / totalKg);
    allocated += amountPaisa;
    return {
      memberId: member.memberId,
      amountPaisa,
      amount: amountPaisa / 100,
    };
  });
  if (allocated < totalPaisa) {
    payout[0].amountPaisa += totalPaisa - allocated;
    payout[0].amount = payout[0].amountPaisa / 100;
  }
  return payout;
}

function createGroupLot({ groupId, leaderId, members }) {
  if (!groupId || !leaderId || !Array.isArray(members) || members.length === 0)
    throw new Error("groupId, leaderId, and members are required.");
  return {
    id: `group_lot_${uuidv4().slice(0, 8)}`,
    groupId,
    leaderId,
    members: members.map((member) => ({
      memberId: member.memberId,
      kg: Number(member.kg),
    })),
    status: "OPEN",
  };
}

function releaseGroupLot(db, groupLot, total) {
  const payouts = splitPayout(total, groupLot.members);
  groupLot.status = "RELEASED";
  for (const payout of payouts) {
    db.walletRecords.push({
      id: `wallet_${uuidv4().slice(0, 8)}`,
      groupLotId: groupLot.id,
      memberId: payout.memberId,
      amountPaisa: payout.amountPaisa,
      amount: payout.amount,
      createdAt: new Date().toISOString(),
    });
  }
  return payouts;
}

module.exports = { splitPayout, createGroupLot, releaseGroupLot };
