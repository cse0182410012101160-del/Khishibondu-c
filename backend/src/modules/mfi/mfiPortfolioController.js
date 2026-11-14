const { PrismaClient } = require("@prisma/client");
const db = require("../../database/store");

let prisma;
function getPrisma() {
  if (!prisma) prisma = new PrismaClient();
  return prisma;
}

async function getPortfolio(req, res) {
  if (process.env.DATABASE_URL) {
    const client = getPrisma();
    const [districtRows, scoreRows, repaymentRows] = await Promise.all([
      client.$queryRaw`SELECT COALESCE(u.district, 'Unknown') AS district, COUNT(DISTINCT l."farmerId")::int AS applicants FROM "Loan" l JOIN "User" u ON u.id = l."farmerId" GROUP BY u.district ORDER BY applicants DESC`,
      client.$queryRaw`WITH latest AS (SELECT DISTINCT ON ("farmerId") "farmerId", score FROM "CreditEvent" ORDER BY "farmerId", "computedAt" DESC) SELECT CASE WHEN score BETWEEN 300 AND 499 THEN '300-499' WHEN score BETWEEN 500 AND 649 THEN '500-649' WHEN score BETWEEN 650 AND 749 THEN '650-749' ELSE '750-850' END AS bucket, COUNT(*)::int AS applicants FROM latest GROUP BY bucket ORDER BY bucket`,
      client.$queryRaw`SELECT COUNT(*)::int AS total, COUNT(*) FILTER (WHERE status IN ('REPAID', 'PAID', 'COMPLETED'))::int AS repaid FROM "Loan"`,
    ]);
    const total = Number(repaymentRows[0]?.total || 0);
    const repaid = Number(repaymentRows[0]?.repaid || 0);
    return res.json({
      success: true,
      portfolio: {
        applicantsByDistrict: districtRows,
        scoreBuckets: scoreRows,
        repaymentRate: total ? repaid / total : 0,
      },
    });
  }

  const applications = db.loanApplications;
  const applicantsByDistrict = Object.values(
    applications.reduce((groups, application) => {
      const farmer = db.users.find((user) => user.id === application.farmerId);
      const district = farmer?.district || "Unknown";
      groups[district] = groups[district] || { district, applicants: 0 };
      groups[district].applicants += 1;
      return groups;
    }, {}),
  );
  return res.json({
    success: true,
    portfolio: { applicantsByDistrict, scoreBuckets: [], repaymentRate: 0 },
  });
}

module.exports = { getPortfolio };
