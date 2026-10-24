
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';
import 'package:gullak/widgets/coin_widget.dart';

class CoinTray extends StatefulWidget {
  const CoinTray({super.key});

  @override
  State<CoinTray> createState() => _CoinTrayState();
}

class _CoinTrayState extends State<CoinTray> {
  static const double _coinSize = 52;
  static const int _layers = 5;
  static const double _layerGap = 4;

  final TextEditingController _amountController = TextEditingController();

  Coin? _customCoin;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _createCoin() {
    final amount = int.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Enter a valid positive amount';
        _customCoin = null;
      });
      return;
    }

    setState(() {
      _customCoin = Coin(amount);
      _error = null;
    });

    FocusScope.of(context).unfocus();
  }

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
                  border: Border.all(
                    color: style.border,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: _layers * _layerGap,
            child: _draggableCoin(coin),
          ),
        ],
      ),
    );
  }

  Widget _draggableCoin(Coin coin) {
    return Draggable<Coin>(
      data: coin,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: CoinWidget(
            coin: coin,
            size: _coinSize,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: CoinWidget(
          coin: coin,
          size: _coinSize,
        ),
      ),
      child: CoinWidget(
        coin: coin,
        size: _coinSize,
      ),
    );
  }

  Widget _customAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          color: AppColors.peach,
          height: 24,
        ),
        const Text(
          'CUSTOM AMOUNT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: 'Enter amount',
            errorText: _error,
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _createCoin(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: _createCoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Coin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (_customCoin != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                const Text(
                  'Drag into Gullak',
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                _draggableCoin(_customCoin!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.peach,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
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
            Wrap(
              spacing: 12,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                for (final value in kCoinValues)
                  _stack(value),
              ],
            ),
            _customAmountSection(),
          ],
        ),
      ),
    );
  }
}
