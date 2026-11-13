import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/marketplace/presentation/screens/crop_list_screen.dart';
import '../features/orders/presentation/screens/orders_list_screen.dart';
import '../features/microfinance/presentation/screens/credit_score_screen.dart';
import '../features/microfinance/presentation/screens/ngo_loan_review_screen.dart';
import '../features/weather/presentation/screens/weather_screen.dart';
import '../features/analytics/presentation/screens/farmer_dashboard_screen.dart';
import '../features/analytics/presentation/screens/admin_dashboard_screen.dart';
import '../features/escrow/presentation/screens/escrow_wallet_screen.dart';
import '../features/traceability/presentation/screens/trace_scanner_screen.dart';
import '../features/chat/presentation/screens/chat_threads_screen.dart';
import '../features/plugins/screens/plugins_catalog_screen.dart';
import '../features/phase2/presentation/phase2_screens.dart';

class MainNavigationShell extends StatefulWidget {
  final UserEntity currentUser;
  const MainNavigationShell({super.key, required this.currentUser});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    final role = widget.currentUser.role;

    if (role == 'farmer') {
      return [
        CropListScreen(currentUser: widget.currentUser),
        OrdersListScreen(currentUser: widget.currentUser),
        CreditScoreScreen(currentUser: widget.currentUser),
        const WeatherScreen(),
        FarmerDashboardScreen(currentUser: widget.currentUser),
      ];
    } else if (role == 'buyer') {
      return [
        const ProcurementScreen(),
        OrdersListScreen(currentUser: widget.currentUser),
        EscrowWalletScreen(currentUser: widget.currentUser),
        const TraceScannerScreen(),
        ChatThreadsScreen(currentUser: widget.currentUser),
      ];
    } else if (role == 'ngo') {
      return [
        NgoLoanReviewScreen(currentUser: widget.currentUser),
        const NgoAnalyticsScreen(),
        const WeatherScreen(),
        EscrowWalletScreen(currentUser: widget.currentUser),
      ];
    } else {
      // Admin
      return [
        AdminDashboardScreen(currentUser: widget.currentUser),
        OrdersListScreen(currentUser: widget.currentUser),
        CropListScreen(currentUser: widget.currentUser),
        PluginsCatalogScreen(currentUserRole: widget.currentUser.role),
      ];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems(AppLocalizations loc) {
    final role = widget.currentUser.role;

    if (role == 'farmer') {
      return [
        BottomNavigationBarItem(icon: const Icon(Icons.storefront), label: loc.translate('marketplace')),
        BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: loc.translate('orders')),
        BottomNavigationBarItem(icon: const Icon(Icons.score), label: loc.translate('creditAndLoans')),
        BottomNavigationBarItem(icon: const Icon(Icons.wb_sunny_outlined), label: loc.translate('weather')),
        BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), label: loc.translate('analytics')),
      ];
    } else if (role == 'buyer') {
      return [
        BottomNavigationBarItem(icon: const Icon(Icons.inventory_2_outlined), label: loc.translate('marketplace')),
        BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: loc.translate('orders')),
        BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), label: loc.translate('escrow')),
        BottomNavigationBarItem(icon: const Icon(Icons.qr_code_scanner), label: loc.translate('traceability')),
        BottomNavigationBarItem(icon: const Icon(Icons.chat_outlined), label: loc.translate('chat')),
      ];
    } else if (role == 'ngo') {
      return [
        BottomNavigationBarItem(icon: const Icon(Icons.verified_user_outlined), label: loc.translate('loanReviews')),
        BottomNavigationBarItem(icon: const Icon(Icons.insights_outlined), label: loc.translate('analytics')),
        BottomNavigationBarItem(icon: const Icon(Icons.wb_sunny_outlined), label: loc.translate('weatherRisk')),
        BottomNavigationBarItem(icon: const Icon(Icons.payments_outlined), label: loc.translate('disbursements')),
      ];
    } else {
      // Admin
      return [
        BottomNavigationBarItem(icon: const Icon(Icons.admin_panel_settings_outlined), label: loc.translate('adminOps')),
        BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: loc.translate('orders')),
        BottomNavigationBarItem(icon: const Icon(Icons.storefront), label: loc.translate('crops')),
        BottomNavigationBarItem(icon: const Icon(Icons.extension_outlined), label: loc.translate('plugins')),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeCubit = context.read<LocaleCubit>();
    final screens = _buildScreens();

    return Scaffold(
      drawer: _buildDrawer(context, loc, localeCubit),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _buildNavItems(loc),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations loc, LocaleCubit localeCubit) {
    final isBn = loc.isBangla;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.currentUser.name.isNotEmpty ? widget.currentUser.name[0] : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary),
              ),
            ),
            accountName: Text(widget.currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(
              '${widget.currentUser.role.toUpperCase()} • ${widget.currentUser.phone}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          // Language Switcher Banner in Drawer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isBn ? const Color(0xFFF0FDF4) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isBn ? AppColors.primary : Colors.grey.shade300),
            ),
            child: ListTile(
              leading: const Icon(Icons.g_translate_rounded, color: AppColors.primary),
              title: Text(
                isBn ? 'ভাষা: বাংলা (সক্রিয়)' : 'Language: English',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                isBn ? 'ইংরেজিতে দেখতে ট্যাপ করুন' : 'Tap to switch entire app to Bangla',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              trailing: Switch(
                value: isBn,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                onChanged: (val) {
                  localeCubit.setLocale(val ? 'bn' : 'en');
                },
              ),
              onTap: () {
                localeCubit.toggleLocale();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined, color: AppColors.secondary),
            title: Text(
              isBn ? 'কৃষিঋণ ও ক্রেডিট স্কোর (Get Credit)' : 'Get Credit & Microloans',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isBn ? 'বিক্রির রেকর্ডে জামানতহীন ঋণ' : 'No physical land collateral required',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Text(
                isBn ? 'আবেদন' : 'Apply',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreditScoreScreen(currentUser: widget.currentUser)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.extension_outlined, color: AppColors.secondary),
            title: Text(loc.translate('pluggableFeatures')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PluginsCatalogScreen(currentUserRole: widget.currentUser.role)),
              );
            },
          ),
          if (widget.currentUser.role == 'farmer') ...[
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: AppColors.info),
              title: const Text('Bangla Farming Assistant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_outlined, color: AppColors.primary),
              title: const Text('Crop Quality Check'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CropQualityScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.secondary),
              title: const Text('BNPL Input Shop'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InputShopScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sensors_outlined, color: AppColors.info),
              title: const Text('IoT Soil Sensors'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilSensorsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.public_outlined, color: AppColors.primary),
              title: const Text('Export Matchmaking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportMatchmakingScreen()));
              },
            ),
          ],
          if (widget.currentUser.role == 'buyer')
            ListTile(
              leading: const Icon(Icons.public_outlined, color: AppColors.primary),
              title: const Text('Export Matchmaking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportMatchmakingScreen()));
              },
            ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.bkashPink),
            title: Text(loc.translate('escrow')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EscrowWalletScreen(currentUser: widget.currentUser)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: AppColors.info),
            title: Text(loc.translate('batchProvenanceScanner')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TraceScannerScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(loc.translate('logout'), style: const TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
