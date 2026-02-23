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

class HudOverlay extends StatefulWidget {
  final DiggleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

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
            child: _buildTopBar(l10n),
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
            child: _buildItemBar(l10n),
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

          // Premium store
          Positioned(
            top: 210,
            left: 16,
            child: ElevatedButton.icon(
              onPressed: () => widget.game.openPremiumStore(),
              icon: const Text('💎', style: TextStyle(fontSize: 16)),
              label: Text(l10n.store),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
              ),
            ),
          ),

          // Shop button when at surface
          if (widget.game.drill.isAtSurface)
            Positioned(
              top: 210,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () => widget.game.openShop(),
                icon: const Icon(Icons.store),
                label: Text(l10n.shop),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
        ],
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