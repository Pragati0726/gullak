import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFF8F1);
  static const surface = Colors.white;
  static const peach = Color(0xFFFFE0C2);
  static const brown = Color(0xFF8B5E3C);
  static const coinLight = Color(0xFFFFE082);
  static const coinDark = Color(0xFFFFB300);
  static const coinBorder = Color(0xFFFF8F00);
  static const coinText = Color(0xFF6D4C00);
  static const glow = Color(0xCCFFC107);
  static const clayLight = Color(0xFFE9866A);
  static const clayDark = Color(0xFFB5482F);
  static const clayRim = Color(0xFF8F3420);
  static const gold = Color(0xFFFFCA28);
}

/// ★ CUSTOMISE HERE: add or remove denominations.
const List<int> kCoinValues = [1, 2, 5, 10, 20, 50, 100, 500];

/// coin look per denomination
class CoinStyle {
  final Color light, dark, border, text;
  const CoinStyle(this.light, this.dark, this.border, this.text);

  static const _gold = CoinStyle(
    AppColors.coinLight,
    AppColors.coinDark,
    AppColors.coinBorder,
    AppColors.coinText,
  );
  static const _silver = CoinStyle(
    Color(0xFFF5F5F5),
    Color(0xFFB0BEC5),
    Color(0xFF78909C),
    Color(0xFF37474F),
  );
  static const _green = CoinStyle(
    Color(0xFFA5D6A7),
    Color(0xFF388E3C),
    Color(0xFF1B5E20),
    Color(0xFFF1F8E9),
  );

  /// ₹1–10 gold, ₹20–50 silver, ₹100+ green
  static CoinStyle of(int value) {
    if (value >= 100) return _green;
    if (value >= 20) return _silver;
    return _gold;
  }
}