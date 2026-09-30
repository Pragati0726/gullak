import 'package:flutter/material.dart';
import 'package:gullak/utils/constants.dart';

class SavingsCard extends StatelessWidget {
  final int total;
  final int count;
  final VoidCallback onReset;

  const SavingsCard({
    super.key,
    required this.total,
    required this.count,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 10, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.clayLight, AppColors.clayDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayDark.withAlpha(90),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Savings',
                  style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: total),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, value, __) => Text(
                    '₹ $value',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.savings_outlined,
                        size: 16, color: Colors.white.withAlpha(210)),
                    const SizedBox(width: 6),
                    Text(
                      '$count ${count == 1 ? 'coin' : 'coins'} saved',
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Empty gullak',
            onPressed: onReset,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(50),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}