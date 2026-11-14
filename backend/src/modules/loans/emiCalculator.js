function calculateEmiSchedule(
  principal,
  annualRatePct,
  tenureMonths,
  method = "declining",
) {
  const p = Number(principal);
  const annualRate = Number(annualRatePct);
  const n = Number.parseInt(tenureMonths, 10);
  const normalizedMethod = method === "flat" ? "flat" : "declining";

  if (
    !Number.isFinite(p) ||
    p <= 0 ||
    !Number.isFinite(annualRate) ||
    annualRate < 0 ||
    !Number.isInteger(n) ||
    n <= 0
  ) {
    throw new Error(
      "Principal, annual rate, and tenure must be valid positive values.",
    );
  }

  const monthlyRate = annualRate / 100 / 12;
  let monthlyEmi;
  let totalPayable;
  let schedule = [];

  if (normalizedMethod === "flat") {
    const totalInterest = p * (annualRate / 100) * (n / 12);
    totalPayable = p + totalInterest;
    monthlyEmi = totalPayable / n;
    schedule = Array.from({ length: n }, (_, index) => ({
      month: index + 1,
      emi: monthlyEmi,
      principal: p / n,
      interest: totalInterest / n,
      remainingBalance: Math.max(0, p - ((index + 1) * p) / n),
    }));
  } else {
    monthlyEmi =
      monthlyRate === 0
        ? p / n
        : (p * monthlyRate * Math.pow(1 + monthlyRate, n)) /
          (Math.pow(1 + monthlyRate, n) - 1);
    totalPayable = monthlyEmi * n;
    let balance = p;
    schedule = Array.from({ length: n }, (_, index) => {
      const interest = balance * monthlyRate;
      const principalPart = monthlyEmi - interest;
      balance -= principalPart;
      return {
        month: index + 1,
        emi: monthlyEmi,
        principal: principalPart,
        interest,
        remainingBalance: Math.max(0, balance),
      };
    });
  }

  const totalInterest = totalPayable - p;
  const aprPct =
    normalizedMethod === "flat" ? annualRate * ((2 * n) / (n + 1)) : annualRate;
  return {
    principal: p,
    annualRatePct: annualRate,
    tenureMonths: n,
    method: normalizedMethod,
    monthlyEmi: Math.round(monthlyEmi),
    totalInterest: Math.round(totalInterest),
    totalPayable: Math.round(totalPayable),
    totalCost: Math.round(totalPayable),
    aprPct: Number(aprPct.toFixed(2)),
    warning: aprPct > 27 ? "APR is above 27%." : null,
    schedule: schedule.map((item) => ({
      ...item,
      emi: Math.round(item.emi),
      principal: Math.round(item.principal),
      interest: Math.round(item.interest),
      remainingBalance: Math.max(0, Math.round(item.remainingBalance)),
    })),
  };
}

module.exports = { calculateEmiSchedule };
