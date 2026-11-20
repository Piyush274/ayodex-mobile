import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';

class WalletBalanceCard extends StatefulWidget {
  final Decimal balance;
  final String currencySymbol;
  final VoidCallback? onExchangeTap;
  final VoidCallback? onTransferTap;
  final VoidCallback? onWithdrawTap;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    this.currencySymbol = 'USD',
    this.onExchangeTap,
    this.onTransferTap,
    this.onWithdrawTap,
  });

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard> {
  bool _isObscured = false;

  String _formatBalance(Decimal dec) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(dec.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(17, 2, 38, 0.15),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label and Eye Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL WALLET BALANCE',
                style: AppTextTheme.caption.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _isObscured = !_isObscured);
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p8),

          // Balance Display
          if (_isObscured)
            const Text(
              '••••••••',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatBalance(widget.balance),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.currencySymbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseLight,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppDimensions.p20),

          // Divider
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          const SizedBox(height: AppDimensions.p16),

          // Quick Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                label: 'Exchange',
                icon: Icons.currency_exchange,
                color: AppColors.base,
                onTap: widget.onExchangeTap,
              ),
              _ActionButton(
                label: 'Send Money',
                icon: Icons.send_rounded,
                color: AppColors.info,
                onTap: widget.onTransferTap,
              ),
              _ActionButton(
                label: 'Withdraw',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.success,
                onTap: widget.onWithdrawTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
