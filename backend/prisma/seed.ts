import {
  PrismaClient,
  UserRole,
  CropStatus,
  BidStatus,
  OrderStatus,
} from "@prisma/client";

const prisma = new PrismaClient();
const districts = ["Bogura", "Dinajpur", "Dhaka"];
const crops = ["potato", "rice", "onion"];

async function main() {
  await prisma.ledgerEntry.deleteMany();
  await prisma.escrow.deleteMany();
  await prisma.dispute.deleteMany();
  await prisma.order.deleteMany();
  await prisma.bid.deleteMany();
  await prisma.traceEvent.deleteMany();
  await prisma.cropLot.deleteMany();
  await prisma.creditEvent.deleteMany();
  await prisma.auditLog.deleteMany();
  await prisma.loan.deleteMany();
  await prisma.user.deleteMany();

  const farmers = await Promise.all(
    Array.from({ length: 20 }, (_, index) =>
      prisma.user.create({
        data: {
          phone: `+880000000${String(index + 1).padStart(3, "0")}`,
          role: UserRole.farmer,
          name: `Demo Farmer ${index + 1}`,
          district: districts[index % districts.length],
          verified: true,
        },
      }),
    ),
  );
  const buyers = await Promise.all(
    Array.from({ length: 5 }, (_, index) =>
      prisma.user.create({
        data: {
          phone: `+880000001${String(index + 1).padStart(3, "0")}`,
          role: UserRole.buyer,
          name: `Demo Buyer ${index + 1}`,
          district: districts[index % districts.length],
          verified: true,
        },
      }),
    ),
  );
  await Promise.all(
    Array.from({ length: 2 }, (_, index) =>
      prisma.user.create({
        data: {
          phone: `+880000002${String(index + 1).padStart(3, "0")}`,
          role: UserRole.ngo,
          name: `Demo MFI ${index + 1}`,
          district: "Dhaka",
          verified: true,
        },
      }),
    ),
  );

  const lots = await Promise.all(
    Array.from({ length: 60 }, (_, index) =>
      prisma.cropLot.create({
        data: {
          farmerId: farmers[index % farmers.length].id,
          cropType: crops[index % crops.length],
          title: `Demo ${crops[index % crops.length]} lot ${index + 1}`,
          quantity: 100 + index,
          unit: "kg",
          askPricePerUnit: 30 + (index % 10),
          district: districts[index % districts.length],
          harvestDate: new Date(Date.now() - index * 86400000),
          qualityGrade: ["A", "B", "C"][index % 3],
          status: CropStatus.Listed,
        },
      }),
    ),
  );
  const bids = await Promise.all(
    Array.from({ length: 40 }, (_, index) =>
      prisma.bid.create({
        data: {
          lotId: lots[index].id,
          buyerId: buyers[index % buyers.length].id,
          pricePerUnit: 32 + (index % 8),
          quantity: 20 + (index % 10),
          status: index < 20 ? BidStatus.accepted : BidStatus.pending,
          note: "Fake seed bid",
        },
      }),
    ),
  );
  await Promise.all(
    Array.from({ length: 20 }, (_, index) =>
      prisma.order.create({
        data: {
          lotId: lots[index].id,
          bidId: bids[index].id,
          farmerId: farmers[index % farmers.length].id,
          buyerId: buyers[index % buyers.length].id,
          totalAmount:
            Number(bids[index].quantity) * Number(bids[index].pricePerUnit),
          status: OrderStatus.Paid,
        },
      }),
    ),
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
