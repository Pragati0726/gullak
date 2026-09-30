import 'package:flutter/material.dart';
import 'package:gullak/utils/constants.dart';

class GullakWidget extends StatelessWidget {
  final bool glow;
  const GullakWidget({super.key, this.glow = false});

  Widget _dotBand() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          9,
          (_) => Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // ground shadow
          Positioned(
            bottom: -6,
            child: Container(
              width: 170,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(30),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // base
          Positioned(
            bottom: 0,
            child: Container(
              width: 110,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.clayRim,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // body
          Positioned(
            top: 28,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 210,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(105),
                gradient: const RadialGradient(
                  center: Alignment(-0.4, -0.5),
                  radius: 1.0,
                  colors: [AppColors.clayLight, AppColors.clayDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: glow ? AppColors.glow : Colors.black26,
                    blurRadius: glow ? 34 : 12,
                    spreadRadius: glow ? 6 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          // decorative bands
          Positioned(top: 78, left: 30, right: 30, child: _dotBand()),
          Positioned(top: 178, left: 40, right: 40, child: _dotBand()),
          // gold rupee emblem
          Positioned(
            top: 102,
            child: Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
                border: Border.all(color: AppColors.clayRim, width: 3),
              ),
              child: const Text(
                '₹',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.clayRim,
                ),
              ),
            ),
          ),
          // rim / neck
          Positioned(
            top: 6,
            child: Container(
              width: 120,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.clayRim,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          // coin slot
          Positioned(
            top: 18,
            child: Container(
              width: 76,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}