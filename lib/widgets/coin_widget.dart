import 'package:flutter/material.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';

class CoinWidget extends StatelessWidget {
  final Coin coin;
  final double size;

  const CoinWidget({super.key, required this.coin, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final style = CoinStyle.of(coin.value);
    final digits = coin.value.toString().length;
    final fontFactor = digits >= 3 ? 0.24 : 0.28;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [style.light, style.dark]),
        border: Border.all(color: style.border, width: 3),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        '₹${coin.value}',
        style: TextStyle(
          fontSize: size * fontFactor,
          fontWeight: FontWeight.bold,
          color: style.text,
        ),
      ),
    );
  }
}