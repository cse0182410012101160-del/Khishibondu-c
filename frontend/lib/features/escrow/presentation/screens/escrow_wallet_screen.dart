import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../phase2/presentation/phase2_screens.dart';

class EscrowWalletScreen extends StatelessWidget {
  final UserEntity currentUser;
  const EscrowWalletScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isFarmer = currentUser.role == 'farmer';

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('escrow'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Escrow Vault Balance Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agro-Bridge Escrow Vault',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Bangladesh Bank Compliant', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isFarmer ? '৳ 282,000' : '৳ 422,000',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFarmer ? 'Locked in Escrow (Awaiting Delivery Inspection)' : 'Total Active Escrow Locked Across Lots',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Divider(color: Colors.white24, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Linked MFS Rail', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${currentUser.mfsProvider} (${currentUser.mfsNumber})',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bkashPink,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Verified MFS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Supported MFS Rails
            if (currentUser.role == 'buyer') ...[
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SandboxPaymentScreen(currentUser: currentUser)),
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Fund escrow in sandbox'),
              ),
              const SizedBox(height: 20),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connected Financial Rails', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _mfsBadge('bKash', AppColors.bkashPink, 'Active Payouts'),
                        const SizedBox(width: 10),
                        _mfsBadge('Nagad', AppColors.nagadOrange, 'Govt. Subsidies'),
                        const SizedBox(width: 10),
                        _mfsBadge('Rocket', AppColors.rocketPurple, 'DBBL Core'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Escrow History
            const Text('Recent Escrow Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _transactionItem(
              title: 'Diamond Potato Bulk Lot',
              sub: 'Order #POT-101 • bKash Rail',
              amount: '৳ 130,000',
              status: 'RELEASED',
              date: '14 Jan 2026',
              color: AppColors.success,
            ),
            _transactionItem(
              title: 'Deshi Red Onion Harvest Lot',
              sub: 'Order #ONI-103 • bKash Rail',
              amount: '৳ 282,000',
              status: 'LOCKED',
              date: '23 Mar 2026',
              color: AppColors.warning,
            ),
            _transactionItem(
              title: 'Kataribhog Aromatic Rice',
              sub: 'Order #KAT-102 • Nagad Rail',
              amount: '৳ 140,000',
              status: 'DISPUTED',
              date: '19 Mar 2026',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mfsBadge(String name, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem({
    required String title,
    required String sub,
    required String amount,
    required String status,
    required String date,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(status == 'RELEASED' ? Icons.arrow_downward : Icons.lock_outline, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

