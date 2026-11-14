const { enqueue, processJob } = require("../../shared/queue");
const { PrismaClient } = require("@prisma/client");
const {
  computeScore,
  createPrismaCreditRepository,
} = require("./creditService");

const JOB_NAME = "credit-score-recompute";

async function enqueueCreditScoreJob(farmerId) {
  if (!process.env.DATABASE_URL || process.env.NODE_ENV === "test") return null;
  return enqueue(JOB_NAME, { farmerId });
}

async function startCreditScoreWorker() {
  if (!process.env.DATABASE_URL) return null;
  const prisma = new PrismaClient();
  return processJob(JOB_NAME, async (job) => {
    try {
      return await computeScore(
        job.data.farmerId,
        createPrismaCreditRepository(prisma),
      );
    } finally {
      await prisma.$disconnect();
    }
  });
}

module.exports = { JOB_NAME, enqueueCreditScoreJob, startCreditScoreWorker };
