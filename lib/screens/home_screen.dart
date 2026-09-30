import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';
import 'package:gullak/widgets/coin_tray.dart';
import 'package:gullak/widgets/gullak_target.dart';
import 'package:gullak/widgets/savings_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int total = 0;
  int count = 0;

  void _addCoin(Coin coin) {
    HapticFeedback.lightImpact();
    setState(() {
      total += coin.value;
      count++;
    });
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() {
      total = 0;
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gullak',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.brown,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              SavingsCard(total: total, count: count, onReset: _reset),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              child: GullakTarget(onCoinDropped: _addCoin),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _HintPill(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Center(
                      child: SingleChildScrollView(child: CoinTray()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.peach.withAlpha(140),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 18, color: AppColors.brown),
          SizedBox(width: 6),
          Text(
            'Drag a coin into the gullak',
            style: TextStyle(color: AppColors.brown, fontSize: 13),
          ),
        ],
      ),
    );
  }
}