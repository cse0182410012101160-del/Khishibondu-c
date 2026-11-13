class ApiEndpoints {
  static const String cropPhotoUpload = '/uploads/crop-photo';
  // Auth
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String demoLogin = '/auth/demo-login';
  static const String demoAccounts = '/auth/demo-accounts';
  static const String me = '/auth/me';

  // Marketplace
  static const String crops = '/marketplace/crops';
  static String cropDetail(String id) => '/marketplace/crops/$id';
  static String submitBid(String cropId) => '/marketplace/crops/$cropId/bids';
  static String updateBidStatus(String bidId) => '/marketplace/bids/$bidId/status';

  // Orders
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static String updateOrderStatus(String id) => '/orders/$id/status';
  static String confirmDelivery(String id) => '/orders/$id/confirm-delivery';

  // Escrow & Disputes
  static const String fundEscrow = '/escrow/fund';
  static String releaseEscrow(String id) => '/escrow/release/$id';
  static const String raiseDispute = '/escrow/dispute';
  static const String disputes = '/escrow/disputes';
  static String resolveDispute(String id) => '/escrow/disputes/$id/resolve';

  // Phase 2 sandbox capabilities
  static const String aiAssist = '/ai/assist';
  static const String cropQualityCheck = '/ai/crop-quality';
  static const String procurement = '/procurement';
  static const String ngoAnalytics = '/analytics/ngo';

  // Stretch feature sandbox capabilities
  static const String inputShop = '/future/input-shop';
  static const String bnplApplication = '/future/input-shop/bnpl';
  static const String soilSensors = '/future/sensors';
  static const String exportMatches = '/future/export-matches';
  static const String exportInquiries = '/future/export-inquiries';

  // Microfinance
  static String creditScore(String? farmerId) => farmerId != null ? '/microfinance/credit-score/$farmerId' : '/microfinance/credit-score';
  static const String simulateEmi = '/microfinance/simulate-emi';
  static const String applyLoan = '/microfinance/apply';
  static const String loanApplications = '/microfinance/applications';
  static String updateLoanStatus(String id) => '/microfinance/applications/$id/status';

  // Traceability
  static String traceBatch(String batchCode) => '/traceability/$batchCode';
  static const String generateBatchQr = '/traceability/generate';

  // Weather
  static const String weather = '/weather';
  static const String weatherAlerts = '/weather/alerts';

  // Chat
  static const String chatThreads = '/chat/threads';
  static String chatMessages(String threadId) => '/chat/threads/$threadId/messages';

  // Analytics
  static String farmerAnalytics(String? farmerId) => farmerId != null ? '/analytics/farmer/$farmerId' : '/analytics/farmer';
  static const String adminAnalytics = '/analytics/admin';

  // Plugins & Feature Flags
  static const String plugins = '/plugins';
  static String togglePlugin(String id) => '/plugins/$id/toggle';
  static const String registerPlugin = '/plugins/register';
}
