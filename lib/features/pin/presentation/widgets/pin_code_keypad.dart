import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';

class PinCodeKeypad extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String>? onPinComplete;
  final ValueChanged<String>? onChanged;
  final String? title;
  final String? subtitle;
  final bool showDots;

  const PinCodeKeypad({
    super.key,
    this.pinLength = 4,
    this.onPinComplete,
    this.onChanged,
    this.title,
    this.subtitle,
    this.showDots = true,
  });

  @override
  State<PinCodeKeypad> createState() => _PinCodeKeypadState();
}

class _PinCodeKeypadState extends State<PinCodeKeypad> {
  String _pin = '';

  void _handleDigit(String digit) {
    if (_pin.length >= widget.pinLength) return;

    setState(() {
      _pin += digit;
    });

    widget.onChanged?.call(_pin);

    if (_pin.length == widget.pinLength) {
      widget.onPinComplete?.call(_pin);
    }
  }

  void _handleBackspace() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });

    widget.onChanged?.call(_pin);
  }

  void _handleClear() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = '';
    });

    widget.onChanged?.call(_pin);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.p8),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: AppTextTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.p20),
        ],

        // PIN Dot indicators
        if (widget.showDots) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (index) {
              final isFilled = index < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.base : Colors.transparent,
                  border: Border.all(
                    color: isFilled ? AppColors.base : AppColors.border,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.p32),
        ],

        // Numeric Keypad Grid
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: AppDimensions.p16),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: AppDimensions.p16),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: AppDimensions.p16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionKey(
                    icon: null,
                    label: 'C',
                    onTap: _handleClear,
                  ),
                  _buildDigitKey('0'),
                  _buildActionKey(
                    icon: Icons.backspace_outlined,
                    label: null,
                    onTap: _handleBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitKey(d)).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return InkWell(
      onTap: () => _handleDigit(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTextTheme.displayLarge.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 26, color: AppColors.heading)
            : Text(
                label ?? '',
                style: AppTextTheme.headingMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
