/// hud_overlay.dart
/// In-game HUD with HP bar, fuel, cargo, the backpack, the surface
/// compass, and controls.
/// All user-facing strings localized via AppLocalizations.

import 'dart:async';
import 'package:diggle/ui/xp_hud_widget.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/diggle_game.dart';
import '../game/player/drill_component.dart';
import '../game/world/surface_layout.dart';
import '../game/world/tile_map_component.dart';
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
  final ValueNotifier<bool> _hasQuestRewards = ValueNotifier<bool>(false);

  /// Backpack drawer open/closed. Closed at the start of every run.
  final ValueNotifier<bool> _backpackOpen = ValueNotifier<bool>(false);

  /// Bonus rewards currently animating in the feed. Drained from
  /// XPPointsSystem on the regular HUD tick (never during build) and
  /// removed by each notification when its animation finishes.
  final List<RewardEvent> _rewardFeed = [];

  @override
  void initState() {
    super.initState();
    // Seed before the first paint so the reward dot doesn't flash in.
    _hasQuestRewards.value = widget.game.questSystem.hasUnclaimedRewards;
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      _tick.value++;
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
    _backpackOpen.dispose();
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

          // Pause button. The quest-reward dot lives here now that Quests is
          // a building — the pause menu is how you reach it underground.
          Positioned(
            top: 8,
            right: 8,
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => widget.game.pause(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.pause, color: Colors.white, size: 24),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: IgnorePointer(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _hasQuestRewards,
                      builder: (context, hasRewards, child) => hasRewards
                          ? Container(
                              width: 12,
                              height: 12,
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
                ),
              ],
            ),
          ),

          // Surface compass: edge pills pointing at off-screen buildings.
          Positioned.fill(
            child: IgnorePointer(
              child: _ticking(() => _buildCompass(l10n)),
            ),
          ),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
          // Left column: backpack, then the boost chip. Store, Quests,
          // Museum and Shop are buildings on the surface now.
          Positioned(
            top: 150,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackpack(l10n),
                const SizedBox(height: 6),
                // Live boost status chip (tap → premium store)
                _ticking(_buildBoostChip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎒 button that opens into a drawer of items and collapses back.
  /// Quantities only move on buy/use, and ItemSystem notifies on both — no
  /// need to poll; open/closed is a ValueNotifier, so neither rebuilds the
  /// HUD.
  Widget _buildBackpack(AppLocalizations l10n) {
    return ValueListenableBuilder<bool>(
      valueListenable: _backpackOpen,
      builder: (context, open, _) => AnimatedBuilder(
        animation: widget.game.itemSystem,
        builder: (context, _) {
          final items = widget.game.itemSystem;
          final slots = items.itemSlots;
          final total = slots.fold<int>(0, (n, t) => n + items.getQuantity(t));
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width - 16),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: open ? 0.7 : 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBackpackButton(total, open),
                    if (open) ...[
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: slots.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(l10n.backpackEmpty,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12)),
                                )
                              : Row(
                                  children: [
                                    for (final type in slots)
                                      _buildItemSlot(
                                          type, items.getQuantity(type)),
                                  ],
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _backpackOpen.value = false,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.chevron_left,
                              color: Colors.white70, size: 28),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackpackButton(int total, bool open) {
    return GestureDetector(
      onTap: () => _backpackOpen.value = !open,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Opacity(
                opacity: total == 0 ? 0.5 : 1,
                child: const Text('🎒', style: TextStyle(fontSize: 26)),
              ),
            ),
            if (total > 0 && !open)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$total',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const Map<BuildingType, String> _buildingIcon = {
    BuildingType.shop: '🛠️',
    BuildingType.store: '💎',
    BuildingType.quests: '📋',
    BuildingType.museum: '🏛️',
  };

  String _buildingName(AppLocalizations l10n, BuildingType type) =>
      switch (type) {
        BuildingType.shop => l10n.shop,
        BuildingType.store => l10n.store,
        BuildingType.quests => l10n.quests,
        BuildingType.museum => l10n.museumTitle,
      };

  /// At the surface, pills on the screen edges for every building out of
  /// view, nearest first. The viewport is only ~8 tiles wide on a phone,
  /// so most buildings are off-screen most of the time.
  Widget _buildCompass(AppLocalizations l10n) {
    final game = widget.game;
    if (!game.isLoaded || !game.drill.isAtSurface) {
      return const SizedBox.shrink();
    }
    final view = game.camera.visibleWorldRect;
    const tile = TileMapComponent.tileSize;
    final left = <BuildingSite>[];
    final right = <BuildingSite>[];
    for (final site in SurfaceLayout.sites(game.worldConfig.width)) {
      if ((site.right + 1) * tile <= view.left) {
        left.add(site);
      } else if (site.left * tile >= view.right) {
        right.add(site);
      }
    }
    if (left.isEmpty && right.isEmpty) return const SizedBox.shrink();
    left.sort((a, b) => b.left.compareTo(a.left));
    right.sort((a, b) => a.left.compareTo(b.left));

    Widget pill(BuildingSite site, bool toLeft) {
      final label =
          '${_buildingIcon[site.type]} ${_buildingName(l10n, site.type)}';
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(toLeft ? '‹ $label' : '$label ›',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
    }

    return Stack(
      children: [
        Align(
          alignment: const Alignment(-1, 0.15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final site in left) pill(site, true)],
          ),
        ),
        Align(
          alignment: const Alignment(1, 0.15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [for (final site in right) pill(site, false)],
          ),
        ),
      ],
    );
  }

  /// Boost visibility: shows the active holder multiplier, the Heat
  /// Shield timer, or a subtle "no boost" nudge. The multiplier and
  /// nudge states tap into the premium store (NFT mint).
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
      return _chip(
        '⚡ ${mult.toStringAsFixed(mult == mult.roundToDouble() ? 0 : 2)}x',
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

    // Falling telegraph: pulse the hull indicator amber while the current
    // drop already exceeds the *effective* safe distance, so the causal link
    // between a long fall and hull damage is visible BEFORE the cost lands.
    // (This rebuilds on the 10Hz tick, so ~2.5Hz gives a gentle pulse.)
    final dangerFall = widget.game.drill.isFallingDangerously;
    final hullColor = dangerFall
        ? ((_tick.value ~/ 2).isEven ? Colors.amber : Colors.amberAccent)
        : hull.isCritical
            ? Colors.red
            : hull.isLow
                ? Colors.orange
                : Colors.green;

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
                  color: hullColor,
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