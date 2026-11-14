const { v4: uuidv4 } = require("uuid");
const { SprayRecord } = require("../modules/traceability/sprayRecord");

class DatabaseStore {
  constructor() {
    this.users = [];
    this.otpRequests = new Map(); // phone -> { otp, expiresAt }
    this.crops = [];
    this.bids = [];
    this.orders = [];
    this.escrowTransactions = [];
    this.disputes = [];
    this.loanApplications = [];
    this.chatThreads = [];
    this.messages = [];
    this.plugins = [];
    this.weatherData = [];
    this.sprayRecords = [];
    this.groupLots = [];
    this.walletRecords = [];
    this.auditLogs = [];
    this.deviceTokens = [];

    this._seedData();
    this.sprayRecords = [
      new SprayRecord({
        lotId: "crop_lot_101",
        chemical: "Chlorpyrifos",
        date: "2026-03-01",
        preHarvestDays: 14,
      }),
      new SprayRecord({
        lotId: "crop_lot_102",
        chemical: "Mancozeb",
        date: "2026-02-20",
        preHarvestDays: 10,
      }),
    ];
  }

  _seedData() {
    // 1. Seed Users (Roles: farmer, buyer, ngo, admin)
    this.users = [
      {
        id: "usr_farmer_1",
        phone: "+8801711223344",
        name: "Md. Rafiqul Islam (রফিকুল ইসলাম)",
        role: "farmer",
        division: "Rajshahi",
        district: "Bogura",
        upazila: "Shibganj",
        avatar:
          "https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&fit=crop",
        mfsProvider: "bKash",
        mfsNumber: "01711223344",
        nidNumber: "19841029384756",
        rating: 4.8,
        ratingCount: 32,
        totalFulfilledOrders: 28,
        totalSalesVolumeBdt: 420000,
        createdAt: "2024-02-15T08:00:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_farmer_2",
        phone: "+8801822334455",
        name: "Abdul Malek (আব্দুল মালেক)",
        role: "farmer",
        division: "Rangpur",
        district: "Dinajpur",
        upazila: "Birganj",
        avatar:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop",
        mfsProvider: "Nagad",
        mfsNumber: "01822334455",
        nidNumber: "19912039485761",
        rating: 4.5,
        ratingCount: 19,
        totalFulfilledOrders: 18,
        totalSalesVolumeBdt: 290000,
        createdAt: "2024-05-10T09:30:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_buyer_1",
        phone: "+8801933445566",
        name: "Dhaka Agro Wholesale Ltd (ঢাকা এগ্রো হোলসেল)",
        role: "buyer",
        division: "Dhaka",
        district: "Dhaka",
        upazila: "Kawran Bazar",
        avatar:
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&fit=crop",
        companyName: "Dhaka Agro Wholesale Ltd",
        tradeLicense: "TRAD/DNCC/019283/2023",
        mfsProvider: "bKash",
        mfsNumber: "01933445566",
        rating: 4.9,
        ratingCount: 45,
        createdAt: "2024-01-10T10:00:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_buyer_2",
        phone: "+8801644556677",
        name: "Bengal Fresh Mart (বেঙ্গল ফ্রেশ মার্ট)",
        role: "buyer",
        division: "Chattogram",
        district: "Chattogram",
        upazila: "Kotwali",
        avatar:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&fit=crop",
        companyName: "Bengal Fresh Mart Ltd",
        tradeLicense: "TRAD/CCC/058291/2023",
        mfsProvider: "Rocket",
        mfsNumber: "01644556677",
        rating: 4.7,
        ratingCount: 26,
        createdAt: "2024-03-12T11:00:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_ngo_1",
        phone: "+8801755667788",
        name: "Fatema Tuz Zohra (BRAC Microfinance)",
        role: "ngo",
        organizationName: "BRAC Bangladesh - Agriculture Credit Division",
        division: "Dhaka",
        district: "Dhaka",
        upazila: "Mohakhali",
        avatar:
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&fit=crop",
        createdAt: "2024-01-01T08:00:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_ngo_2",
        phone: "+8801866778899",
        name: "Mahmud Hasan (Grameen Krishi Rin)",
        role: "ngo",
        organizationName: "Grameen Bank - Rural Microfinance",
        division: "Dhaka",
        district: "Dhaka",
        upazila: "Mirpur-2",
        avatar:
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&fit=crop",
        createdAt: "2024-01-01T08:00:00Z",
        isKycVerified: true,
      },
      {
        id: "usr_admin_1",
        phone: "+8801700000000",
        name: "Agro-Bridge System Moderator",
        role: "admin",
        division: "Dhaka",
        district: "Dhaka",
        upazila: "Agargaon",
        avatar:
          "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&fit=crop",
        createdAt: "2024-01-01T00:00:00Z",
        isKycVerified: true,
      },
    ];

    // 2. Seed Crops (Bangladeshi staples with realistic harvest metrics)
    this.crops = [
      {
        id: "crop_lot_101",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        farmerRating: 4.8,
        title: "Premium Diamond Potato (ডায়মন্ড আলু - বগুড়া)",
        titleBn: "প্রিমিয়াম ডায়মন্ড আলু (বগুড়া)",
        category: "Vegetables",
        categoryBn: "শাকসবজি",
        quantity: 250,
        unit: "Maund (মন)", // 1 Maund ≈ 40 Kg
        pricePerUnit: 1400, // BDT per Maund
        totalValue: 350000,
        minOrderQuantity: 20,
        description:
          "Cold-storage ready, export grade Diamond potato harvested from the fertile silt soils of Shibganj, Bogura. Zero disease spotting, uniform size.",
        descriptionBn:
          "বগুড়ার শিবগঞ্জের উর্বর মাটির কোল্ড-স্টোরেজ গ্রেড ডায়মন্ড আলু। কোনো দাগ নেই, সুন্দর গোল আকার।",
        division: "Rajshahi",
        district: "Bogura",
        upazila: "Shibganj",
        coordinates: { lat: 24.9747, lng: 89.3308 },
        harvestDate: "2026-03-10",
        grade: "A+",
        organicCertified: true,
        images: [
          "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&fit=crop",
          "https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=600&fit=crop",
        ],
        batchQrCode: "QR-BOG-2026-POT-101",
        status: "Listed",
        bidsCount: 3,
        createdAt: "2026-03-12T10:00:00Z",
      },
      {
        id: "crop_lot_102",
        farmerId: "usr_farmer_2",
        farmerName: "Abdul Malek",
        farmerRating: 4.5,
        title: "Kataribhog Aromatic Rice (কাটারিভোগ সুগন্ধি চাল)",
        titleBn: "কাটারিভোগ সুগন্ধি চাল (দিনাজপুর)",
        category: "Grains",
        categoryBn: "দানা শস্য",
        quantity: 180,
        unit: "Maund (মন)",
        pricePerUnit: 2800,
        totalValue: 504000,
        minOrderQuantity: 15,
        description:
          "Authentic GI-recognized Kataribhog aromatic paddy directly harvested in Birganj, Dinajpur. Sun-dried moisture level maintained at 12%.",
        descriptionBn:
          "দিনাজপুরের বীরগঞ্জের ঐতিহ্যবাহী সুগন্ধি কাটারিভোগ ধান। আর্দ্রতা ১২% নিশ্চিত করা হয়েছে।",
        division: "Rangpur",
        district: "Dinajpur",
        upazila: "Birganj",
        coordinates: { lat: 25.7656, lng: 88.6633 },
        harvestDate: "2026-02-28",
        grade: "Premium Special",
        organicCertified: false,
        images: [
          "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&fit=crop",
          "https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&fit=crop",
        ],
        batchQrCode: "QR-DIN-2026-KAT-102",
        status: "Listed",
        bidsCount: 2,
        createdAt: "2026-03-14T09:15:00Z",
      },
      {
        id: "crop_lot_103",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        farmerRating: 4.8,
        title: "Deshi Red Onion Bulk Lot (দেশীয় লাল পেঁয়াজ)",
        titleBn: "দেশীয় লাল পেঁয়াজ (পাবনা/বগুড়া জাত)",
        category: "Spices",
        categoryBn: "মসলা",
        quantity: 120,
        unit: "Maund (মন)",
        pricePerUnit: 2400,
        totalValue: 288000,
        minOrderQuantity: 10,
        description:
          "Well-cured high pungency local variety red onion with thick papery skin for enhanced shelf-life during transport.",
        descriptionBn: "উচ্চমানের দেশি লাল পেঁয়াজ, দীর্ঘদিন সংরক্ষণের উপযোগী।",
        division: "Rajshahi",
        district: "Bogura",
        upazila: "Shibganj",
        coordinates: { lat: 24.9747, lng: 89.3308 },
        harvestDate: "2026-03-20",
        grade: "A",
        organicCertified: false,
        images: [
          "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&fit=crop",
        ],
        batchQrCode: "QR-BOG-2026-ONI-103",
        status: "Negotiating",
        bidsCount: 4,
        createdAt: "2026-03-22T08:00:00Z",
      },
      {
        id: "crop_lot_104",
        farmerId: "usr_farmer_2",
        farmerName: "Abdul Malek",
        farmerRating: 4.5,
        title: "Fresh Mustard Seeds (মাঘী দেশী সরিষা)",
        titleBn: "মাঘী দেশী সরিষা (তেল উৎপাদন)",
        category: "Oilseeds",
        categoryBn: "তৈলবীজ",
        quantity: 90,
        unit: "Maund (মন)",
        pricePerUnit: 3200,
        totalValue: 288000,
        minOrderQuantity: 10,
        description:
          "High oil-content (42%) cold-pressed mustard seeds, cleaned and graded. Ideal for commercial oil mills in Dhaka/Chittagong.",
        descriptionBn: "উচ্চ তেল সমৃদ্ধ মাঘী সরিষা। কোনো ধূলিবালি নেই।",
        division: "Rangpur",
        district: "Dinajpur",
        upazila: "Birganj",
        coordinates: { lat: 25.7656, lng: 88.6633 },
        harvestDate: "2026-02-15",
        grade: "A",
        organicCertified: true,
        images: [
          "https://images.unsplash.com/photo-1508746829417-e6f548d8d6ed?w=600&fit=crop",
        ],
        batchQrCode: "QR-DIN-2026-MUS-104",
        status: "Listed",
        bidsCount: 1,
        createdAt: "2026-03-25T11:00:00Z",
      },
    ];

    // 3. Seed Bulk Lot Bids
    this.bids = [
      {
        id: "bid_201",
        cropId: "crop_lot_101",
        buyerId: "usr_buyer_1",
        buyerName: "Dhaka Agro Wholesale Ltd",
        farmerId: "usr_farmer_1",
        quantityRequested: 250,
        unit: "Maund (মন)",
        offeredPricePerUnit: 1350,
        totalOfferedAmount: 337500,
        note: "Ready to pick up entire 250 maund lot with our own freight truck from Bogura hub next Tuesday.",
        status: "pending",
        createdAt: "2026-03-13T14:20:00Z",
      },
      {
        id: "bid_202",
        cropId: "crop_lot_101",
        buyerId: "usr_buyer_2",
        buyerName: "Bengal Fresh Mart",
        farmerId: "usr_farmer_1",
        quantityRequested: 100,
        unit: "Maund (মন)",
        offeredPricePerUnit: 1380,
        totalOfferedAmount: 138000,
        note: "Require delivery to our Chittagong distribution depot.",
        status: "pending",
        createdAt: "2026-03-14T08:10:00Z",
      },
      {
        id: "bid_203",
        cropId: "crop_lot_103",
        buyerId: "usr_buyer_1",
        buyerName: "Dhaka Agro Wholesale Ltd",
        farmerId: "usr_farmer_1",
        quantityRequested: 120,
        unit: "Maund (মন)",
        offeredPricePerUnit: 2350,
        totalOfferedAmount: 282000,
        note: "Payment ready in Agro-Bridge Escrow via bKash Merchant API.",
        status: "accepted",
        createdAt: "2026-03-23T11:00:00Z",
      },
    ];

    // 4. Seed Orders (State Machine: Listed -> Negotiating -> Confirmed -> Delivered -> Paid)
    this.orders = [
      {
        id: "ord_501",
        cropId: "crop_lot_103",
        bidId: "bid_203",
        buyerId: "usr_buyer_1",
        buyerName: "Dhaka Agro Wholesale Ltd",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        cropTitle: "Deshi Red Onion Bulk Lot (দেশীয় লাল পেঁয়াজ)",
        quantity: 120,
        unit: "Maund (মন)",
        pricePerUnit: 2350,
        totalAmount: 282000,
        status: "Confirmed", // Escrow funded, awaiting farmer dispatch
        escrowStatus: "LOCKED",
        mfsPaymentMethod: "bKash",
        mfsTransactionId: "TRX_BKASH_8928374921",
        deliveryAddress: "Kawran Bazar Wholesale Shed #4, Dhaka",
        batchQrCode: "QR-BOG-2026-ONI-103",
        disputeId: null,
        timeline: [
          {
            status: "Listed",
            timestamp: "2026-03-22T08:00:00Z",
            note: "Crop lot published",
          },
          {
            status: "Negotiating",
            timestamp: "2026-03-23T11:00:00Z",
            note: "Buyer submitted bid 2,350 BDT/maund",
          },
          {
            status: "Confirmed",
            timestamp: "2026-03-23T15:30:00Z",
            note: "Escrow funded 282,000 BDT via bKash",
          },
        ],
        createdAt: "2026-03-23T15:30:00Z",
      },
      {
        id: "ord_502",
        cropId: "crop_lot_102",
        bidId: null,
        buyerId: "usr_buyer_2",
        buyerName: "Bengal Fresh Mart",
        farmerId: "usr_farmer_2",
        farmerName: "Abdul Malek",
        cropTitle: "Kataribhog Aromatic Rice (কাটারিভোগ সুগন্ধি চাল)",
        quantity: 50,
        unit: "Maund (মন)",
        pricePerUnit: 2800,
        totalAmount: 140000,
        status: "Delivered", // Delivered, waiting for buyer inspection or auto-payout
        escrowStatus: "LOCKED",
        mfsPaymentMethod: "Nagad",
        mfsTransactionId: "TRX_NAGAD_7736481920",
        deliveryAddress: "Kotwali Agrabad Access Road, Chattogram",
        batchQrCode: "QR-DIN-2026-KAT-102",
        disputeId: null,
        timeline: [
          {
            status: "Listed",
            timestamp: "2026-03-14T09:15:00Z",
            note: "Harvest published",
          },
          {
            status: "Confirmed",
            timestamp: "2026-03-15T10:00:00Z",
            note: "Escrow locked via Nagad",
          },
          {
            status: "Delivered",
            timestamp: "2026-03-18T16:00:00Z",
            note: "Truck shipment received at destination",
          },
        ],
        createdAt: "2026-03-15T10:00:00Z",
      },
      {
        id: "ord_503",
        cropId: "crop_lot_101",
        bidId: null,
        buyerId: "usr_buyer_1",
        buyerName: "Dhaka Agro Wholesale Ltd",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        cropTitle: "Diamond Potato (Previous Season Batch)",
        quantity: 100,
        unit: "Maund (মন)",
        pricePerUnit: 1300,
        totalAmount: 130000,
        status: "Paid", // Successfully completed and paid
        escrowStatus: "RELEASED",
        mfsPaymentMethod: "bKash",
        mfsTransactionId: "TRX_BKASH_1029384756",
        deliveryAddress: "Kawran Bazar, Dhaka",
        batchQrCode: "QR-BOG-2025-POT-099",
        disputeId: null,
        timeline: [
          {
            status: "Listed",
            timestamp: "2026-01-10T09:00:00Z",
            note: "Crop lot created",
          },
          {
            status: "Confirmed",
            timestamp: "2026-01-11T12:00:00Z",
            note: "Escrow funded",
          },
          {
            status: "Delivered",
            timestamp: "2026-01-14T14:00:00Z",
            note: "Inspected and confirmed",
          },
          {
            status: "Paid",
            timestamp: "2026-01-14T16:00:00Z",
            note: "130,000 BDT disbursed to Farmer bKash",
          },
        ],
        createdAt: "2026-01-11T12:00:00Z",
      },
    ];

    // 5. Seed Escrow Transactions
    this.escrowTransactions = [
      {
        id: "esc_901",
        orderId: "ord_501",
        amount: 282000,
        currency: "BDT",
        payerId: "usr_buyer_1",
        payerName: "Dhaka Agro Wholesale Ltd",
        beneficiaryId: "usr_farmer_1",
        beneficiaryName: "Md. Rafiqul Islam",
        paymentRail: "bKash",
        status: "LOCKED",
        holdStartedAt: "2026-03-23T15:30:00Z",
        releasedAt: null,
      },
      {
        id: "esc_902",
        orderId: "ord_502",
        amount: 140000,
        currency: "BDT",
        payerId: "usr_buyer_2",
        payerName: "Bengal Fresh Mart",
        beneficiaryId: "usr_farmer_2",
        beneficiaryName: "Abdul Malek",
        paymentRail: "Nagad",
        status: "LOCKED",
        holdStartedAt: "2026-03-15T10:00:00Z",
        releasedAt: null,
      },
      {
        id: "esc_903",
        orderId: "ord_503",
        amount: 130000,
        currency: "BDT",
        payerId: "usr_buyer_1",
        payerName: "Dhaka Agro Wholesale Ltd",
        beneficiaryId: "usr_farmer_1",
        beneficiaryName: "Md. Rafiqul Islam",
        paymentRail: "bKash",
        status: "RELEASED",
        holdStartedAt: "2026-01-11T12:00:00Z",
        releasedAt: "2026-01-14T16:00:00Z",
      },
    ];

    // 6. Seed Disputes (Admin Escrow resolution flow)
    this.disputes = [
      {
        id: "dsp_301",
        orderId: "ord_502",
        raisedByUserId: "usr_buyer_2",
        raisedByName: "Bengal Fresh Mart",
        againstUserId: "usr_farmer_2",
        againstByName: "Abdul Malek",
        reason:
          "Moisture content above specified 12% tolerance (measured 16%), risking storage rot.",
        status: "PENDING_REVIEW", // PENDING_REVIEW, RESOLVED_SELLER_PAID, RESOLVED_BUYER_REFUNDED, PARTIAL_SETTLEMENT
        evidencePhotos: [
          "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&fit=crop",
        ],
        adminNotes: "Contacted Dinajpur extension officer for sample check.",
        resolution: null,
        createdAt: "2026-03-19T10:30:00Z",
      },
    ];

    // 7. Seed Microfinance Loan Applications
    this.loanApplications = [
      {
        id: "loan_app_701",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        ngoId: "usr_ngo_1",
        ngoName: "BRAC Microfinance",
        programName: "BRAC Krishi Shurokkha (কৃষি সুরক্ষা ঋণ)",
        requestedAmount: 150000,
        tenureMonths: 6,
        interestRateAnnual: 9.0, // 9% agricultural concession rate in BD
        monthlyEmiBdt: 25660,
        purpose:
          "Purchasing 20 bags of zinc-enriched seed paddy, solar drip pump rental, and fertilizer for upcoming Aman season.",
        farmerCreditScoreSnapshot: 765, // Dynamic credit score
        farmerRatingSnapshot: 4.8,
        historicalSalesVolumeBdt: 420000,
        collateralType:
          "Marketplace Sales Cashflow Lien (No Physical Land Deed)",
        status: "APPROVED", // SUBMITTED, UNDER_REVIEW, APPROVED, DISBURSED, REJECTED
        approvedAmount: 150000,
        disbursedViaMfs: "bKash",
        disbursedTxnId: "MFS_DISB_BRAC_99182",
        submittedAt: "2026-02-18T10:00:00Z",
        approvedAt: "2026-02-22T14:00:00Z",
      },
      {
        id: "loan_app_702",
        farmerId: "usr_farmer_2",
        farmerName: "Abdul Malek",
        ngoId: "usr_ngo_2",
        ngoName: "Grameen Krishi Rin",
        programName: "Grameen Seasonal Harvest Credit (গ্রামীন মওসুমী ঋণ)",
        requestedAmount: 100000,
        tenureMonths: 4,
        interestRateAnnual: 8.5,
        monthlyEmiBdt: 25442,
        purpose:
          "Post-harvest grain dryer investment and jute bag bulk purchase.",
        farmerCreditScoreSnapshot: 710,
        farmerRatingSnapshot: 4.5,
        historicalSalesVolumeBdt: 290000,
        collateralType: "Marketplace Escrow Lien",
        status: "UNDER_REVIEW",
        approvedAmount: null,
        disbursedViaMfs: null,
        submittedAt: "2026-03-24T09:00:00Z",
        approvedAt: null,
      },
    ];

    // 8. Seed Chat Threads and Negotiation Messages
    this.chatThreads = [
      {
        id: "chat_th_401",
        cropId: "crop_lot_101",
        farmerId: "usr_farmer_1",
        farmerName: "Md. Rafiqul Islam",
        buyerId: "usr_buyer_1",
        buyerName: "Dhaka Agro Wholesale Ltd",
        lastMessage:
          "I have submitted an official bid of 1,350 BDT/maund for your 250 maund lot.",
        lastMessageAt: "2026-03-13T14:21:00Z",
        unreadByFarmer: 0,
        unreadByBuyer: 0,
      },
    ];

    this.messages = [
      {
        id: "msg_001",
        threadId: "chat_th_401",
        senderId: "usr_buyer_1",
        senderRole: "buyer",
        text: "Assalamu Alaikum Rafiqul Bhai, is the cold storage grade Diamond potato available for immediate pickup?",
        createdAt: "2026-03-13T14:15:00Z",
      },
      {
        id: "msg_002",
        threadId: "chat_th_401",
        senderId: "usr_farmer_1",
        senderRole: "farmer",
        text: "Waalikum Assalam. Yes, all 250 maunds are bagged in 40kg jute bags at our Shibganj shed.",
        createdAt: "2026-03-13T14:18:00Z",
      },
      {
        id: "msg_003",
        threadId: "chat_th_401",
        senderId: "usr_buyer_1",
        senderRole: "buyer",
        text: "I have submitted an official bid of 1,350 BDT/maund for your 250 maund lot.",
        createdAt: "2026-03-13T14:21:00Z",
      },
    ];

    // 9. Seed Weather & Agro-Advisory Data for BD Divisions
    this.weatherData = [
      {
        division: "Rajshahi",
        district: "Bogura",
        temperatureC: 28.5,
        humidityPct: 62,
        windSpeedKmh: 14,
        rainfallForecastMm: 2.0,
        condition: "Partly Cloudy",
        conditionBn: "আংশিক মেঘলা",
        riskLevel: "LOW", // LOW, MODERATE, HIGH, CRITICAL
        floodAlert: false,
        cycloneAlert: false,
        advisoryEn:
          "Optimal weather for harvesting potato and mustard. Dry soil conditions allow transport trucks easy access to farm fields.",
        advisoryBn:
          "আলু এবং সরিষা তোলার জন্য অনুকূল আবহাওয়া। জমি শুষ্ক থাকায় ট্রাক চলাচলে সুবিধা হবে।",
        updatedAt: new Date().toISOString(),
      },
      {
        division: "Rangpur",
        district: "Dinajpur",
        temperatureC: 27.0,
        humidityPct: 70,
        windSpeedKmh: 12,
        rainfallForecastMm: 5.5,
        condition: "Clear Sky",
        conditionBn: "পরিষ্কার আকাশ",
        riskLevel: "LOW",
        floodAlert: false,
        cycloneAlert: false,
        advisoryEn:
          "Maintain seed bed moisture for Boro paddy seedlings. No immediate pesticide spraying needed.",
        advisoryBn:
          "বোরো ধানের চারার জন্য আর্দ্রতা বজায় রাখুন। এখন কীটনাশক প্রয়োগের প্রয়োজন নেই।",
        updatedAt: new Date().toISOString(),
      },
      {
        division: "Barishal",
        district: "Patuakhali",
        temperatureC: 31.0,
        humidityPct: 84,
        windSpeedKmh: 35,
        rainfallForecastMm: 45.0,
        condition: "Squally Showers",
        conditionBn: "ঝড়ো বৃষ্টি",
        riskLevel: "HIGH",
        floodAlert: true,
        cycloneAlert: true,
        advisoryEn:
          "Warning Signal 4 in coastal belt. Secure harvested paddy in elevated silos. Clear canal blockages to prevent waterlogging.",
        advisoryBn:
          "উপকূলীয় অঞ্চলে ৪ নম্বর সতর্কতা সংকেত। কাটা ধান উঁচু স্থানে সংরক্ষণ করুন এবং ড্রেনেজ পরিষ্কার রাখুন।",
        updatedAt: new Date().toISOString(),
      },
      {
        division: "Dhaka",
        district: "Dhaka",
        temperatureC: 30.2,
        humidityPct: 65,
        windSpeedKmh: 16,
        rainfallForecastMm: 0.0,
        condition: "Sunny",
        conditionBn: "রোদেলা",
        riskLevel: "LOW",
        floodAlert: false,
        cycloneAlert: false,
        advisoryEn:
          "Stable conditions across central transport corridors. Ideal timing for bulk grain logistics.",
        advisoryBn:
          "সারা ঢাকা অঞ্চলে অনুকূল পরিবহন ব্যবস্থা। শস্য পরিবহনের উত্তম সময়।",
        updatedAt: new Date().toISOString(),
      },
    ];

    // 10. Seed Extensible Plugin / Feature-Flag Registry
    this.plugins = [
      {
        id: "ai_disease_detection",
        name: "AI Plant Disease Detection",
        nameBn: "কৃত্রিম বুদ্ধিমত্তা ফসল রোগ নির্ণয়",
        description:
          "Leaf scanning with on-device computer vision to diagnose bacterial blight, potato late blight, and blast disease with organic remedy guidance.",
        version: "1.2.0",
        author: "Agro-Bridge AI Research Lab",
        icon: "camera_enhance",
        status: "active", // active, beta, disabled
        enabledForRoles: ["farmer", "admin"],
        configSchema: {
          confidenceThreshold: 0.85,
          offlineModelCached: true,
          supportDiseasesCount: 42,
        },
      },
      {
        id: "yield_prediction_engine",
        name: "Satellite Yield Prediction",
        nameBn: "উপগ্রহভিত্তিক ফলন পূর্বাভাস",
        description:
          "Sentinel-2 NDVI satellite imagery analysis correlating seasonal rainfall with harvest yield per bigha.",
        version: "0.9.4-beta",
        author: "Bangladesh Space Research (SPARRSO) Partner API",
        icon: "analytics",
        status: "beta",
        enabledForRoles: ["farmer", "ngo", "admin"],
        configSchema: {
          satelliteSource: "Sentinel-2 L2A",
          updateCadenceDays: 5,
        },
      },
      {
        id: "subsidy_directory",
        name: "Govt. Subsidized Fertilizer Directory",
        nameBn: "সরকারি সার ও বীজ প্রণোদনা ডিরেক্টরি",
        description:
          "Direct integration with Department of Agricultural Extension (DAE) dealer depots for urea, TSP, and DAP quota verification.",
        version: "1.0.1",
        author: "Ministry of Agriculture Bangladesh Open Portal",
        icon: "account_balance",
        status: "active",
        enabledForRoles: ["farmer", "admin"],
        configSchema: {
          daePortalEndpoint: "https://dae.gov.bd/open-subsidies",
          upazilaVerificationRequired: true,
        },
      },
      {
        id: "iot_soil_telemetry",
        name: "Smart Soil NPK Sensor Telemetry",
        nameBn: "স্মার্ট মৃত্তিকা এনপিকে সেন্সর",
        description:
          "LoRaWAN and GSM gateway streaming for real-time soil nitrogen, phosphorus, moisture, and pH telemetry.",
        version: "0.5.0-experimental",
        author: "Krishi IoT Lab, BUET",
        icon: "sensors",
        status: "disabled",
        enabledForRoles: ["farmer", "admin"],
        configSchema: {
          gatewayFreq: "868MHz",
          telemetryIntervalSec: 600,
        },
      },
    ];
  }
}

// Singleton database instance
const db = new DatabaseStore();

module.exports = db;
