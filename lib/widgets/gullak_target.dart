import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';
import 'package:gullak/widgets/gullak_widget.dart';

class GullakTarget extends StatefulWidget {
  final ValueChanged<Coin> onCoinDropped;
  const GullakTarget({super.key, required this.onCoinDropped});

  @override
  State<GullakTarget> createState() => _GullakTargetState();
}

class _GullakTargetState extends State<GullakTarget>
    with TickerProviderStateMixin {
  late final AnimationController _bounce;
  late final AnimationController _pop;
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Coin>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        _lastValue = details.data.value;
        widget.onCoinDropped(details.data);
        _bounce.forward(from: 0);
        _pop.forward(from: 0);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return SizedBox(
          width: 220,
          height: 300,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _bounce,
                  builder: (context, child) {
                    final bounce =
                        1 + 0.12 * math.sin(math.pi * _bounce.value);
                    return Transform.scale(
                      scale: (hovering ? 1.06 : 1.0) * bounce,
                      child: child,
                    );
                  },
                  child: GullakWidget(glow: hovering),
                ),
              ),
              Positioned(
                top: 0,
                child: AnimatedBuilder(
                  animation: _pop,
                  builder: (context, _) {
                    final t = _pop.value;
                    if (t == 0) return const SizedBox.shrink();
                    return Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -20 * t),
                        child: Text(
                          '+₹$_lastValue',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coinBorder,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}