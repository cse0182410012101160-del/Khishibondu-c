const fs = require("fs");
const path = require("path");
const db = require("../../database/store");

class PriceSource {
  getPrices() {
    throw new Error("PriceSource.getPrices must be implemented.");
  }
}

class CsvPriceSource extends PriceSource {
  constructor(filePath) {
    super();
    this.filePath = filePath;
  }

  getPrices({ crop, district }) {
    const [header, ...lines] = fs
      .readFileSync(this.filePath, "utf8")
      .trim()
      .split(/\r?\n/);
    const columns = header.split(",");
    return lines
      .map((line) =>
        Object.fromEntries(
          line.split(",").map((value, index) => [columns[index], value]),
        ),
      )
      .filter(
        (row) =>
          (!crop || row.crop.toLowerCase() === crop.toLowerCase()) &&
          (!district || row.district.toLowerCase() === district.toLowerCase()),
      )
      .map((row) => ({
        crop: row.crop,
        district: row.district,
        wholesale: Number(row.wholesale),
        retail: Number(row.retail),
      }));
  }
}

const priceSource = new CsvPriceSource(
  path.join(__dirname, "../../../data/prices.csv"),
);

function getPrices(req, res) {
  const { crop, district } = req.query;
  const marketPrices = priceSource.getPrices({ crop, district });
  const completedOrders = db.orders.filter((order) =>
    ["Delivered", "Paid"].includes(order.status),
  );
  const farmGateValues = completedOrders
    .filter(
      (order) =>
        (!crop ||
          (order.cropTitle || "").toLowerCase().includes(crop.toLowerCase())) &&
        (!district ||
          (order.district || "").toLowerCase() === district.toLowerCase()),
    )
    .map((order) =>
      Number(order.pricePerUnit || order.totalAmount / order.quantity),
    )
    .filter(Number.isFinite);

  return res.json({
    success: true,
    crop: crop || null,
    district: district || null,
    prices: marketPrices.map((price) => ({
      ...price,
      farmGate: farmGateValues.length
        ? farmGateValues.reduce((sum, value) => sum + value, 0) /
          farmGateValues.length
        : null,
    })),
    source: "data/prices.csv",
    farmGateSource: "completed orders",
  });
}

module.exports = { PriceSource, CsvPriceSource, getPrices };
