class AppConstants {
  static const String appName = 'Agro-Bridge';
  static const String appNameBn = 'এগ্রো-ব্রিজ';
  static const String tagline = 'Farmer-to-Buyer Marketplace & Microfinance';
  static const String taglineBn = 'কৃষক-ক্রেতা সরাসরি বাজার ও জামানতবিহীন কৃষিঋণ';

  // Base API URL
  // In development, default to local machine address
  static const String defaultBaseUrl = 'http://10.0.2.2:5000/api/v1'; // Android emulator
  static const String localhostBaseUrl = 'http://localhost:5000/api/v1'; // Web/desktop/device

  // Supported Divisions
  static const List<String> divisions = [
    'All',
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Rangpur',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Mymensingh',
  ];

  // Crop Categories
  static const List<String> categories = [
    'All',
    'Grains',
    'Vegetables',
    'Spices',
    'Oilseeds',
    'Fruits',
    'Fisheries',
  ];

  // Mobile Financial Services (MFS)
  static const List<String> mfsProviders = ['bKash', 'Nagad', 'Rocket'];

  // Agricultural Units in Bangladesh
  static const List<String> units = [
    'Maund (মন)',
    'Kg (কেজি)',
    'Ton (টন)',
    'Bale (বেল)',
  ];
}

