import 'package:flutter/material.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';
import 'package:gullak/widgets/coin_widget.dart';

class CoinTray extends StatelessWidget {
  const CoinTray({super.key});

  static const double _coinSize = 52;
  static const int _layers = 5;
  static const double _layerGap = 4;

  Widget _stack(int value) {
    final coin = Coin(value);
    final style = CoinStyle.of(value);
    final height = _coinSize + _layers * _layerGap;

    return SizedBox(
      width: _coinSize,
      height: height,
      child: Stack(
        children: [
          for (int i = 0; i < _layers; i++)
            Positioned(
              bottom: i * _layerGap,
              child: Container(
                width: _coinSize,
                height: _coinSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style.dark,
                  border: Border.all(color: style.border, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: _layers * _layerGap,
            child: Draggable<Coin>(
              data: coin,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 1.2,
                  child: CoinWidget(coin: coin, size: _coinSize),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: CoinWidget(coin: coin, size: _coinSize),
              ),
              child: CoinWidget(coin: coin, size: _coinSize),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.peach, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'COINS',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: _coinSize * 2 + 16,
            child: Wrap(
              spacing: 16,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [for (final v in kCoinValues) _stack(v)],
            ),
          ),
        ],
      ),
    );
  }
}