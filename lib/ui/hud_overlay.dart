/// hud_overlay.dart
/// In-game HUD with HP bar, fuel, cargo, item bar, and controls.
/// All user-facing strings localized via AppLocalizations.

import 'dart:async';
import 'package:diggle/ui/xp_hud_widget.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/diggle_game.dart';
import '../game/player/drill_component.dart';
import '../game/systems/item_system.dart';
import '../game/systems/xp_points_system.dart';
import 'quest_overlay.dart';

class HudOverlay extends StatefulWidget {
  final DiggleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late Timer _updateTimer;

  /// 10Hz poll for the readouts that have no notifier to hang off — the
  /// bars, cargo/cash/depth, and the boost/heat-shield countdowns. Only the
  /// subtrees that listen to it rebuild; the HUD tree itself does not.
  final ValueNotifier<int> _tick = ValueNotifier<int>(0);

  /// Structural state sampled on the same tick. A ValueNotifier only fires
  /// when the value actually differs, so these rebuild almost never.
  final ValueNotifier<bool> _atSurface = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasQuestRewards = ValueNotifier<bool>(false);

  /// Bonus rewards currently animating in the feed. Drained from
  /// XPPointsSystem on the regular HUD tick (never during build) and
  /// removed by each notification when its animation finishes.
  final List<RewardEvent> _rewardFeed = [];

  @override
  void initState() {
    super.initState();
    // Seed before the first paint so the shop button doesn't flash in.
    _atSurface.value = widget.game.drill.isAtSurface;
    _hasQuestRewards.value = widget.game.questSystem.hasUnclaimedRewards;
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      _tick.value++;
      _atSurface.value = widget.game.drill.isAtSurface;
      _hasQuestRewards.value = widget.game.questSystem.hasUnclaimedRewards;

      // setState is now reserved for the one thing that changes the tree's
      // shape. Calling it unconditionally rebuilt the whole HUD — SafeArea,
      // every Positioned, the four direction buttons and the l10n lookup —
      // ten times a second on the UI thread.
      final pending =
          widget.game.xpPointsSystem.takePendingAnnouncements();
      if (pending.isNotEmpty) {
        setState(() => _rewardFeed.addAll(pending));
      }
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _tick.dispose();
    _atSurface.dispose();
    _hasQuestRewards.dispose();
    super.dispose();
  }

  /// Rebuilds [build] on every 10Hz tick. For the live readouts only.
  Widget _ticking(Widget Function() build) => ValueListenableBuilder<int>(
        valueListenable: _tick,
        builder: (context, value, child) => build(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Stack(
        children: [
          // Top stats bars
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ticking(() => _buildTopBar(l10n)),
          ),
          // XP bar
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: XPHudWidget(
              xpSystem: widget.game.xpPointsSystem,
              boostManager: widget.game.boostManager!,
              onTapStore: () => widget.game.openPremiumStore(),
            ),
          ),

          // Item bar
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            // Quantities only move on buy/use, and ItemSystem notifies on
            // both — no need to poll this one.
            child: AnimatedBuilder(
              animation: widget.game.itemSystem,
              builder: (context, _) => _buildItemBar(l10n),
            ),
          ),

          // Reward feed: achievements, artifacts, login streak, titles
          if (_rewardFeed.isNotEmpty)
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final event in _rewardFeed)
                      Padding(
                        key: ObjectKey(event),
                        padding: const EdgeInsets.only(bottom: 6),
                        child: XPGainNotification(
                          event: event,
                          onComplete: () {
                            if (!mounted) return;
                            setState(() => _rewardFeed.remove(event));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Pause button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => widget.game.pause(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 24),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
          // Left-side action column: store / quests / museum / boost.
          // A single Column (instead of absolute Positioned tops) so the
          // buttons can never overlap regardless of their heights.
          Positioned(
            top: 210,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () => widget.game.openPremiumStore(),
                  icon: const Text('💎', style: TextStyle(fontSize: 16)),
                  label: Text(l10n.store),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => widget.game.openQuests(),
                      icon: const Text('📋', style: TextStyle(fontSize: 16)),
                      label: Text(l10n.quests),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _hasQuestRewards,
                        builder: (context, hasRewards, child) => hasRewards
                            ? Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: () => widget.game.openCollection(),
                  icon: const Text('🏛️', style: TextStyle(fontSize: 16)),
                  label: AnimatedBuilder(
                    animation: widget.game.collectionSystem,
                    builder: (context, _) => Text(
                      '${widget.game.collectionSystem.foundCount}'
                      '/${widget.game.collectionSystem.totalCount}',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                // Live boost status chip (tap → premium store)
                _ticking(_buildBoostChip),
              ],
            ),
          ),

          // Shop button when at surface
          Positioned(
            top: 210,
            right: 16,
            child: ValueListenableBuilder<bool>(
              valueListenable: _atSurface,
              builder: (context, atSurface, child) => atSurface
                  ? ElevatedButton.icon(
                      onPressed: () => widget.game.openShop(),
                      icon: const Icon(Icons.store),
                      label: Text(l10n.shop),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  /// Boost visibility: shows the active multiplier with a live
  /// countdown, the Heat Shield timer, or a subtle "no boost" nudge.
  /// Every state taps into the premium store.
  Widget _buildBoostChip() {
    final game = widget.game;
    final xp = game.xpPointsSystem;

    // Heat shield takes display priority (short, urgent timer)
    if (game.heatShieldActive) {
      return _chip(
        '🛡️ ${game.heatShieldRemaining.ceil()}s lava immunity',
        Colors.deepOrange.shade800,
        onTap: null,
      );
    }

    if (xp.hasActiveBoost || xp.hasNFTBoost) {
      final mult = xp.effectiveXPMultiplier >= xp.effectivePointsMultiplier
          ? xp.effectiveXPMultiplier
          : xp.effectivePointsMultiplier;
      final boosters = game.boostManager?.activeBoosters ?? [];
      String remaining = '';
      if (boosters.isNotEmpty) {
        // Shortest remaining timed booster drives the countdown
        boosters.sort((a, b) => a.timeRemaining.compareTo(b.timeRemaining));
        final timed =
            boosters.where((b) => b.timeRemaining > Duration.zero).toList();
        if (timed.isNotEmpty) {
          final rem = timed.first.timeRemaining;
          remaining = rem.inHours > 0
              ? ' ${rem.inHours}h ${rem.inMinutes % 60}m'
              : ' ${rem.inMinutes}m ${rem.inSeconds % 60}s';
        }
      }
      return _chip(
        '⚡ ${mult.toStringAsFixed(mult == mult.roundToDouble() ? 0 : 2)}x'
        '$remaining',
        Colors.cyan.shade800,
        onTap: () => game.openPremiumStore(),
      );
    }

    // No boost: quiet nudge
    return _chip(
      '⚡ --',
      Colors.blueGrey.shade800.withOpacity(0.6),
      onTap: () => game.openPremiumStore(),
    );
  }

  Widget _chip(String text, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    final fuel = widget.game.fuelSystem;
    final hull = widget.game.hullSystem;
    final economy = widget.game.economySystem;
    final depth = widget.game.drill.depth;

    return Container(
      margin: const EdgeInsets.only(left: 8, right: 60, top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBar(
                  icon: Icons.shield,
                  label: l10n.hp,
                  value: hull.hull,
                  max: hull.maxHull,
                  color: hull.isCritical
                      ? Colors.red
                      : hull.isLow
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBar(
                  icon: Icons.local_gas_station,
                  label: l10n.fuel,
                  value: fuel.fuel,
                  max: fuel.maxFuel,
                  color: fuel.isCritical
                      ? Colors.red
                      : fuel.isLow
                      ? Colors.orange
                      : Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2,
                      color:
                      economy.isCargoFull ? Colors.red : Colors.white70,
                      size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${economy.cargoCount}/${economy.maxCapacity}',
                    style: TextStyle(
                      color:
                      economy.isCargoFull ? Colors.red : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_money,
                      color: Colors.amber, size: 16),
                  Text(
                    '${economy.cash}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.height,
                      color: Colors.white70, size: 16),
                  Text(
                    l10n.depthMeter(depth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required IconData icon,
    required String label,
    required double value,
    required double max,
    required Color color,
  }) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              '$label: ${value.toInt()}/${max.toInt()}',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemBar(AppLocalizations l10n) {
    final items = widget.game.itemSystem;
    final slots = items.itemSlots;

    if (slots.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.items,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          ...slots.map(
                  (type) => _buildItemSlot(type, items.getQuantity(type))),
        ],
      ),
    );
  }

  Widget _buildItemSlot(ItemType type, int quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => widget.game.useItem(type),
        child: Container(
          width: 50,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade600),
          ),
          child: Stack(
            children: [
              Center(child: Text(type.icon, style: const TextStyle(fontSize: 20))),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('x$quantity',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _DirectionButton(
                icon: Icons.arrow_back,
                direction: MoveDirection.left,
                drill: widget.game.drill,
              ),
              const SizedBox(width: 20),
              _DirectionButton(
                icon: Icons.arrow_forward,
                direction: MoveDirection.right,
                drill: widget.game.drill,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DirectionButton(
                icon: Icons.arrow_upward,
                direction: MoveDirection.up,
                drill: widget.game.drill,
              ),
              const SizedBox(height: 12),
              _DirectionButton(
                icon: Icons.arrow_downward,
                direction: MoveDirection.down,
                drill: widget.game.drill,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DirectionButton extends StatefulWidget {
  final IconData icon;
  final MoveDirection direction;
  final DrillComponent drill;

  const _DirectionButton({
    required this.icon,
    required this.direction,
    required this.drill,
  });

  @override
  State<_DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<_DirectionButton> {
  bool _pressed = false;

  void _onPress() {
    setState(() => _pressed = true);
    widget.drill.heldDirection = widget.direction;
  }

  void _onRelease() {
    setState(() => _pressed = false);
    if (widget.drill.heldDirection == widget.direction) {
      widget.drill.heldDirection = MoveDirection.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onPress(),
      onPointerUp: (_) => _onRelease(),
      onPointerCancel: (_) => _onRelease(),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 36),
      ),
    );
  }
}