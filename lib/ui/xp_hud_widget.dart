/// xp_hud_widget.dart
/// Compact XP/level display widget for the in-game HUD.
/// Minimal localization needed — mostly numeric displays.

import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/systems/xp_points_system.dart';
import '../game/systems/boost_manager.dart';

class XPHudWidget extends StatelessWidget {
  final XPPointsSystem xpSystem;
  final BoostManager boostManager;
  final VoidCallback? onTapStore;

  const XPHudWidget({
    super.key,
    required this.xpSystem,
    required this.boostManager,
    this.onTapStore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: xpSystem,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Level badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${xpSystem.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // XP progress bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.xpLabel(xpSystem.totalXP, xpSystem.xpForNextLevel),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                        if (xpSystem.hasActiveBoost || xpSystem.hasNFTBoost)
                          _buildBoostIndicator(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: xpSystem.levelProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Points display
              GestureDetector(
                onTap: onTapStore,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade900.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple.shade700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${xpSystem.points}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoostIndicator() {
    return ListenableBuilder(
      listenable: boostManager,
      builder: (context, _) {
        final boosts = <Widget>[];

        if (xpSystem.effectiveXPMultiplier > 1.0) {
          boosts.add(Text(
            '⚡${xpSystem.effectiveXPMultiplier.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.yellow, fontSize: 9),
          ));
        }
        if (xpSystem.effectivePointsMultiplier > 1.0) {
          boosts.add(Text(
            '💎${xpSystem.effectivePointsMultiplier.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.purple, fontSize: 9),
          ));
        }

        return Row(mainAxisSize: MainAxisSize.min, children: boosts);
      },
    );
  }
}

/// Floating XP gain notification
class XPGainNotification extends StatefulWidget {
  final RewardEvent event;
  final VoidCallback onComplete;

  const XPGainNotification({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<XPGainNotification> createState() => _XPGainNotificationState();
}

class _XPGainNotificationState extends State<XPGainNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.event.finalXP > 0)
                Text(
                  '+${widget.event.finalXP} XP',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              if (widget.event.finalXP > 0 &&
                  widget.event.finalPoints > 0)
                const SizedBox(width: 8),
              if (widget.event.finalPoints > 0)
                Text(
                  '+${widget.event.finalPoints} 💎',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              if (widget.event.xpMultiplier > 1.0)
                Text(
                  ' (${widget.event.xpMultiplier}x)',
                  style: const TextStyle(color: Colors.yellow, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}