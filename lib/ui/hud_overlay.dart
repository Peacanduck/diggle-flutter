/// hud_overlay.dart
/// In-game HUD overlay displaying:
/// - Fuel gauge
/// - Cargo count
/// - Cash
/// - Depth meter
/// - Movement controls
/// 
/// This is a Flutter widget that overlays the Flame game.
/// It uses ListenableBuilder to react to system changes.

import 'package:flutter/material.dart';
import '../game/diggle_game.dart';
import '../game/player/drill_component.dart';
import '../game/systems/fuel_system.dart';
import '../game/systems/economy_system.dart';

/// Main HUD overlay widget
class HudOverlay extends StatelessWidget {
  final DiggleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top bar with stats
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Movement controls at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),

          // Shop button (only when at surface)
          Positioned(
            top: 80,
            right: 16,
            child: _buildShopButton(),
          ),
        ],
      ),
    );
  }

  /// Top stats bar
  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Fuel gauge
          Expanded(
            flex: 2,
            child: _buildFuelGauge(),
          ),

          const SizedBox(width: 16),

          // Cargo count
          Expanded(
            child: _buildCargoDisplay(),
          ),

          const SizedBox(width: 16),

          // Cash display
          Expanded(
            child: _buildCashDisplay(),
          ),

          const SizedBox(width: 16),

          // Depth meter
          _buildDepthMeter(),
        ],
      ),
    );
  }

  /// Fuel gauge with visual bar
  Widget _buildFuelGauge() {
    return ListenableBuilder(
      listenable: game.fuelSystem,
      builder: (context, _) {
        final fuel = game.fuelSystem;
        final percentage = fuel.fuelPercentage;
        
        Color barColor;
        if (fuel.isCritical) {
          barColor = Colors.red;
        } else if (fuel.isLow) {
          barColor = Colors.orange;
        } else {
          barColor = Colors.green;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.local_gas_station, 
                    color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${fuel.fuel.toInt()}/${fuel.maxFuel.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Cargo capacity display
  Widget _buildCargoDisplay() {
    return ListenableBuilder(
      listenable: game.economySystem,
      builder: (context, _) {
        final economy = game.economySystem;
        final isFull = economy.isCargoFull;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2,
              color: isFull ? Colors.red : Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${economy.cargoCount}/${economy.maxCapacity}',
              style: TextStyle(
                color: isFull ? Colors.red : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Cash display
  Widget _buildCashDisplay() {
    return ListenableBuilder(
      listenable: game.economySystem,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_money, 
                color: Colors.amber, size: 16),
            Text(
              '${game.economySystem.cash}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Depth meter
  Widget _buildDepthMeter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_downward, 
            color: Colors.white70, size: 16),
        const SizedBox(width: 2),
        Text(
          '${game.drill.depth}m',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Shop button (only visible at surface)
  Widget _buildShopButton() {
    // Check if at surface
    if (!game.drill.isAtSurface) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () => game.openShop(),
      icon: const Icon(Icons.store),
      label: const Text('SHOP'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Movement controls
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left/Right controls
          Row(
            children: [
              _buildControlButton(
                icon: Icons.arrow_back,
                direction: MoveDirection.left,
              ),
              const SizedBox(width: 16),
              _buildControlButton(
                icon: Icons.arrow_forward,
                direction: MoveDirection.right,
              ),
            ],
          ),

          // Down control
          _buildControlButton(
            icon: Icons.arrow_downward,
            direction: MoveDirection.down,
            size: 80,
          ),
        ],
      ),
    );
  }

  /// Single control button with press/release handling
  Widget _buildControlButton({
    required IconData icon,
    required MoveDirection direction,
    double size = 64,
  }) {
    return GestureDetector(
      onTapDown: (_) => game.handleMove(direction),
      onTapUp: (_) => game.handleMoveRelease(),
      onTapCancel: () => game.handleMoveRelease(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(size / 4),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Game Over overlay
class GameOverOverlay extends StatelessWidget {
  final DiggleGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You ran out of fuel!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),

            // Stats
            _buildStatRow('Max Depth', '${game.economySystem.maxDepthReached}m'),
            _buildStatRow('Ore Collected', '${game.economySystem.totalOreCollected}'),
            _buildStatRow('Cash Earned', '\$${game.economySystem.totalCashEarned}'),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40, 
                  vertical: 16,
                ),
              ),
              child: const Text(
                'TRY AGAIN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}