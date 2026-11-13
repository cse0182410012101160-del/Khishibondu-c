import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('bn'));
  }

  bool get isBangla => locale.languageCode == 'bn';

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appName': 'Agro-Bridge',
      'tagline': 'Farmer-to-Buyer Marketplace & Microfinance',
      'farmer': 'Farmer (Seller)',
      'buyer': 'Buyer (Wholesaler)',
      'ngo': 'Microfinance Partner (BRAC/Grameen)',
      'admin': 'Platform Admin',
      'login': 'Sign In',
      'phoneAuth': 'Phone Number Verification',
      'phoneHint': 'e.g. 01711223344',
      'sendOtp': 'Send OTP',
      'verifyOtp': 'Verify OTP',
      'otpSentMsg': '6-digit OTP code sent to your phone.',
      'enterOtp': 'Enter 6-Digit OTP',
      'quickDemoLogin': 'Quick Role Switch (Demo)',
      'marketplace': 'Marketplace',
      'myCrops': 'My Harvests',
      'orders': 'Orders',
      'escrow': 'Escrow Vault',
      'creditAndLoans': 'Credit & Loans',
      'weather': 'Weather Advisory',
      'traceability': 'QR Traceability',
      'analytics': 'Analytics',
      'plugins': 'Feature Plugins',
      'chat': 'Negotiations',
      'disputes': 'Dispute Tickets',
      'logout': 'Sign Out',
      'searchCrops': 'Search crops, grains, divisions...',
      'allDivisions': 'All Divisions',
      'allCategories': 'All Categories',
      'pricePerUnit': 'Price per Unit',
      'quantity': 'Quantity',
      'maund': 'Maund',
      'bdt': 'BDT',
      'taka': 'Tk',
      'harvestDate': 'Harvest Date',
      'organic': 'Organic Certified',
      'bulkLotBidding': 'Bulk Lot Bidding',
      'placeBid': 'Place Harvest Lot Bid',
      'offeredPrice': 'Offered Price (BDT)',
      'submitBid': 'Submit Offer to Farmer',
      'bidsReceived': 'Bids Received',
      'acceptBid': 'Accept Offer',
      'rejectBid': 'Decline',
      'counterBid': 'Counter Offer',
      'creditScoreTitle': 'Agro-Bridge Credit Score',
      'creditTier': 'Credit Tier',
      'preApprovedLoan': 'Pre-Approved Credit Limit',
      'noCollateralNotice': 'Zero Physical Collateral: Secured via Verified Sales Cashflow',
      'emiCalculator': 'EMI & Repayment Simulator',
      'calculateEmi': 'Calculate Installments',
      'applyForLoan': 'Apply for Agricultural Microloan',
      'loanTracker': 'Loan Application Tracker',
      'escrowProtected': 'Escrow Protected Payment',
      'fundsLockedInEscrow': 'Funds Locked in Escrow',
      'confirmDelivery': 'Verify & Confirm Delivery',
      'releaseEscrow': 'Release Payout to Seller',
      'raiseDispute': 'Report Issue / Raise Dispute',
      'weatherAlertTitle': 'Agricultural Weather & Cyclone Warnings',
      'floodAlert': 'Flood Advisory Active',
      'cycloneAlert': 'Cyclone Caution',
      'scanQrTrace': 'Scan Crop Batch QR',
      'provenanceTitle': 'Harvest Origin & Quality Provenance',
      'verifiedFarmer': 'KYC Verified Farmer',
      'getCredit': 'Get Credit',
      'switchLanguage': 'বাংলায় দেখুন',
      'languageToggle': 'English',
      'languageName': 'English',
      'allOrders': 'All Orders',
      'escrowLocked': 'Escrow Locked',
      'delivered': 'Delivered',
      'completed': 'Completed',
      'disbursed': 'Disbursed',
      'status': 'Status',
      'loanReviews': 'Loan Reviews',
      'weatherRisk': 'Weather Risk',
      'disbursements': 'Disbursements',
      'adminOps': 'Admin Operations',
      'crops': 'Crops',
      'listHarvest': 'List Harvest',
      'activeBids': 'Active Bids',
      'lotSize': 'Lot Size',
      'minOrder': 'Min Order',
      'pluggableFeatures': 'Pluggable Features Catalog',
      'batchProvenanceScanner': 'Batch Traceability Scanner',
    },
    'bn': {
      'appName': 'কৃষিবন্ধু (Agro-Bridge)',
      'tagline': 'কৃষক-ক্রেতা সরাসরি বাজার ও জামানতবিহীন কৃষিঋণ',
      'farmer': 'কৃষক (বিক্রেতা)',
      'buyer': 'পাইকারি ক্রেতা / ব্যবসায়ী',
      'ngo': 'ক্ষুদ্রঋণ সংস্থা (ব্র্যাক / গ্রামীণ)',
      'admin': 'প্ল্যাটফর্ম অ্যাডমিন',
      'login': 'লগইন করুন',
      'phoneAuth': 'মোবাইল নম্বর দিয়ে প্রবেশ করুন',
      'phoneHint': 'যেমন: ০১৭১১২২৩৩৪৪',
      'sendOtp': 'ওটিপি কোড পাঠান',
      'verifyOtp': 'ওটিপি যাচাই করুন',
      'otpSentMsg': 'আপনার মোবাইলে ৬ সংখ্যার ওটিপি কোড পাঠানো হয়েছে।',
      'enterOtp': '৬ সংখ্যার ওটিপি কোড লিখুন',
      'quickDemoLogin': 'এক ক্লিকে ডেমো প্রোফাইলে প্রবেশ করুন',
      'marketplace': 'কৃষি বাজার',
      'myCrops': 'আমার ফসলসমূহ',
      'orders': 'অর্ডারসমূহ',
      'escrow': 'এসক্রো ওয়ালেট',
      'creditAndLoans': 'ক্রেডিট স্কোর ও কৃষিঋণ',
      'weather': 'আবহাওয়া ও পূর্বাভাস',
      'traceability': 'কিউআর ট্র্যাকিং ও সত্যতা যাচাই',
      'analytics': 'আয়-ব্যয় ও পরিসংখ্যান',
      'plugins': 'অতিরিক্ত ফিচার প্লাগিন',
      'chat': 'সরাসরি দরদাম চ্যাট',
      'disputes': 'অভিযোগ ও সালিশ নিষ্পত্তি',
      'logout': 'লগআউট করুন',
      'searchCrops': 'ফসল, বীজ বা বিভাগ খুঁজুন...',
      'allDivisions': 'সকল বিভাগ',
      'allCategories': 'সকল ক্যাটাগরি',
      'pricePerUnit': 'প্রতি এককের দর',
      'quantity': 'পরিমাণ',
      'maund': 'মন',
      'bdt': 'টাকা',
      'taka': 'টাকা',
      'harvestDate': 'ফসল তোলার তারিখ',
      'organic': 'অর্গানিক ফসল',
      'bulkLotBidding': 'পাইকারি লট নিলাম ও বিডিং',
      'placeBid': 'লট ক্রয়ের প্রস্তাব দিন',
      'offeredPrice': 'প্রস্তাবিত দর (টাকা)',
      'submitBid': 'কৃষককে প্রস্তাব পাঠান',
      'bidsReceived': 'প্রাপ্ত প্রস্তাবসমূহ',
      'acceptBid': 'প্রস্তাব গ্রহণ করুন',
      'rejectBid': 'বাতিল করুন',
      'counterBid': 'পাল্টা প্রস্তাব দিন',
      'creditScoreTitle': 'কৃষিবন্ধু অটোমেটেড ক্রেডিট স্কোর',
      'creditTier': 'ক্রেডিট গ্রেড',
      'preApprovedLoan': 'অনুমোদিত সর্বোচ্চ জামানতহীন ঋণের সীমা',
      'noCollateralNotice': 'কোনো জমির দলিল বা জামানত লাগবে না: প্ল্যাটফর্মের বিক্রির রেকর্ডের বিপরীতে সহজ ঋণ',
      'emiCalculator': 'মাসিক কিস্তি ও রিপেমেন্ট সিমুলেটর',
      'calculateEmi': 'কিস্তির হিসাব বের করুন',
      'applyForLoan': 'সহজ কৃষিঋণের জন্য আবেদন করুন',
      'loanTracker': 'ঋণ আবেদনের বর্তমান অবস্থা',
      'escrowProtected': 'এসক্রো সুরক্ষিত লেনদেন',
      'fundsLockedInEscrow': 'টাকা নিরাপদ এসক্রোতে জমা আছে',
      'confirmDelivery': 'পণ্য বুঝে পেলাম ও টাকা রিলিজ করুন',
      'releaseEscrow': 'বিক্রেতাকে টাকা পাঠিয়ে দিন',
      'raiseDispute': 'অভিযোগ বা বিরোধ দায়ের করুন',
      'weatherAlertTitle': 'কৃষি আবহাওয়া, বন্যা ও ঘূর্ণিঝড় সতর্কবার্তা',
      'floodAlert': 'বন্যা সতর্কতা সংকেত সক্রিয়',
      'cycloneAlert': 'ঘূর্ণিঝড় সতর্কতা সক্রিয়',
      'scanQrTrace': 'ফসল লটের কিউআর কোড স্ক্যান করুন',
      'provenanceTitle': 'ফসলের খামার উৎস ও কোয়ালিটি সনদ',
      'verifiedFarmer': 'এনআইডি যাচাইকৃত বিশ্বস্ত কৃষক',
      'getCredit': 'কৃষিঋণ নিন (Get Credit)',
      'switchLanguage': 'Switch to English',
      'languageToggle': 'বাংলা (Bangla)',
      'languageName': 'বাংলা',
      'allOrders': 'সকল অর্ডার',
      'escrowLocked': 'এসক্রোতে আটকানো',
      'delivered': 'পৌঁছে গেছে',
      'completed': 'সম্পন্ন হয়েছে',
      'disbursed': 'বিতরণকৃত',
      'status': 'অবস্থা',
      'loanReviews': 'ঋণ আবেদন পর্যালোচনা',
      'weatherRisk': 'আবহাওয়া ঝুঁকি',
      'disbursements': 'ঋণ বিতরণ',
      'adminOps': 'অ্যাডমিন ড্যাশবোর্ড',
      'crops': 'ফসলসমূহ',
      'listHarvest': 'নতুন ফসল যোগ করুন',
      'activeBids': 'সক্রিয় প্রস্তাব',
      'lotSize': 'লটের আকার',
      'minOrder': 'সর্বনিম্ন অর্ডার',
      'pluggableFeatures': 'প্লাগিন ফিচার ক্যাটালগ',
      'batchProvenanceScanner': 'ব্যাচ ট্রেসেবিলিটি স্ক্যানার',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['bn']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// Locale Cubit for persistent Bangla/English toggling
class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  LocaleCubit(this._prefs)
      : super(Locale(_prefs.getString(_key) ?? 'bn')); // Bangla first by default!

  void setLocale(String languageCode) {
    _prefs.setString(_key, languageCode);
    emit(Locale(languageCode));
  }

  void toggleLocale() {
    final next = state.languageCode == 'bn' ? 'en' : 'bn';
    setLocale(next);
  }
}
