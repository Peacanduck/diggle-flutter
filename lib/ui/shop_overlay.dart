/// shop_overlay.dart
/// Surface shop overlay for:
/// - Selling collected ore
/// - Refueling
/// - Purchasing upgrades
///
/// Only accessible when player is at surface.

import 'package:flutter/material.dart';
import '../game/diggle_game.dart';
import '../game/systems/fuel_system.dart';
import '../game/systems/economy_system.dart';
import '../game/systems/hull_system.dart';
import '../game/systems/item_system.dart';
import '../game/world/tile.dart';

/// Shop overlay widget
class ShopOverlay extends StatefulWidget {
  final DiggleGame game;

  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  /// Message to display after action
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            // Header with close button
            _buildHeader(),

            // Shop content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Player stats
                    _buildPlayerStats(),

                    const SizedBox(height: 20),

                    // Sell section
                    _buildSellSection(),

                    const SizedBox(height: 20),

                    // Refuel section
                    _buildRefuelSection(),

                    const SizedBox(height: 20),

                    // Repair section
                    _buildRepairSection(),

                    const SizedBox(height: 20),

                    // Upgrades section
                    _buildUpgradesSection(),

                    const SizedBox(height: 20),

                    // Items section
                    _buildItemsSection(),

                    // Action message
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      _buildMessage(),
                    ],
                  ],
                ),
              ),
            ),

            // Return to mining button
            _buildReturnButton(),
          ],
        ),
      ),
    );
  }

  /// Header bar
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown.shade800,
        border: Border(
          bottom: BorderSide(color: Colors.amber.shade700, width: 2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.amber, size: 32),
          const SizedBox(width: 12),
          const Text(
            'MINING SUPPLY CO.',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => widget.game.closeShop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Player stats display
  Widget _buildPlayerStats() {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.attach_money,
                label: 'Cash',
                value: '\$${widget.game.economySystem.cash}',
                color: Colors.amber,
              ),
              _buildStatItem(
                icon: Icons.shield,
                label: 'Hull',
                value: '${widget.game.hullSystem.hull.toInt()}/${widget.game.hullSystem.maxHull.toInt()}',
                color: widget.game.hullSystem.isCritical ? Colors.red : Colors.green,
              ),
              _buildStatItem(
                icon: Icons.local_gas_station,
                label: 'Fuel',
                value: '${widget.game.fuelSystem.fuel.toInt()}/${widget.game.fuelSystem.maxFuel.toInt()}',
                color: Colors.cyan,
              ),
              _buildStatItem(
                icon: Icons.inventory_2,
                label: 'Cargo',
                value: '${widget.game.economySystem.cargoCount}/${widget.game.economySystem.maxCapacity}',
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Sell ore section
  Widget _buildSellSection() {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        final economy = widget.game.economySystem;
        final hasOre = economy.hasOre;

        return _buildSection(
          title: 'SELL ORE',
          icon: Icons.sell,
          child: Column(
            children: [
              // List cargo
              if (hasOre)
                ...economy.cargoItems.map((item) => _buildCargoRow(item))
              else
                const Text(
                  'No ore to sell',
                  style: TextStyle(color: Colors.white54),
                ),

              if (hasOre) ...[
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Value:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '\$${economy.cargoValue}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sellOre,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('SELL ALL'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCargoRow(CargoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.oreType.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.oreType.displayName,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'x${item.quantity}',
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Text(
            '\$${item.totalValue}',
            style: const TextStyle(color: Colors.amber),
          ),
        ],
      ),
    );
  }

  /// Refuel section
  Widget _buildRefuelSection() {
    return ListenableBuilder(
      listenable: widget.game.fuelSystem,
      builder: (context, _) {
        final fuel = widget.game.fuelSystem;
        final cost = fuel.getRefillCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildSection(
          title: 'REFUEL',
          icon: Icons.local_gas_station,
          child: Column(
            children: [
              // Fuel bar
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fuel.fuelPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: fuel.isCritical
                              ? Colors.red
                              : fuel.isLow
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${fuel.fuel.toInt()} / ${fuel.maxFuel.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (!fuel.isFull)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford ? _refuel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('REFUEL (\$$cost)'),
                  ),
                )
              else
                const Text(
                  'Tank is full!',
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Upgrades section
  Widget _buildUpgradesSection() {
    return _buildSection(
      title: 'UPGRADES',
      icon: Icons.upgrade,
      child: Column(
        children: [
          _buildFuelUpgrade(),
          const SizedBox(height: 12),
          _buildCargoUpgrade(),
          const SizedBox(height: 12),
          _buildHullUpgrade(),
        ],
      ),
    );
  }

  /// Repair section
  Widget _buildRepairSection() {
    return ListenableBuilder(
      listenable: widget.game.hullSystem,
      builder: (context, _) {
        final hull = widget.game.hullSystem;
        final cost = hull.getRepairCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildSection(
          title: 'REPAIR',
          icon: Icons.build,
          child: Column(
            children: [
              // Hull bar
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: hull.hullPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: hull.isCritical
                              ? Colors.red
                              : hull.isLow
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${hull.hull.toInt()} / ${hull.maxHull.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (hull.isDamaged)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford ? _repairHull : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('REPAIR HULL (\$$cost)'),
                  ),
                )
              else
                const Text(
                  'Hull is fully repaired!',
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFuelUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.fuelSystem,
      builder: (context, _) {
        final fuel = widget.game.fuelSystem;
        final nextLevel = fuel.getNextUpgrade();
        final cost = fuel.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeRow(
          title: 'Fuel Tank',
          current: fuel.tankLevel.name,
          next: nextLevel?.name,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeFuel : null,
        );
      },
    );
  }

  Widget _buildCargoUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        final economy = widget.game.economySystem;
        final nextLevel = economy.getNextCargoUpgrade();
        final cost = economy.getCargoUpgradeCost();
        final canAfford = economy.canAfford(cost);

        return _buildUpgradeRow(
          title: 'Cargo Bay',
          current: economy.cargoLevel.name,
          next: nextLevel?.name,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeCargo : null,
        );
      },
    );
  }

  Widget _buildHullUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.hullSystem,
      builder: (context, _) {
        final hull = widget.game.hullSystem;
        final nextLevel = hull.getNextUpgrade();
        final cost = hull.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeRow(
          title: 'Hull Armor',
          current: hull.hullLevel.name,
          next: nextLevel?.name,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeHull : null,
        );
      },
    );
  }

  Widget _buildUpgradeRow({
    required String title,
    required String current,
    String? next,
    required int cost,
    required bool canAfford,
    VoidCallback? onUpgrade,
  }) {
    final isMaxed = next == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isMaxed ? current : '$current → $next',
                  style: TextStyle(
                    color: isMaxed ? Colors.green : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isMaxed)
            const Text(
              'MAXED',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onUpgrade : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text('\$$cost'),
            ),
        ],
      ),
    );
  }

  /// Items section
  Widget _buildItemsSection() {
    return _buildSection(
      title: 'ITEMS',
      icon: Icons.backpack,
      child: Column(
        children: [
          // Current inventory
          ListenableBuilder(
            listenable: widget.game.itemSystem,
            builder: (context, _) {
              final items = widget.game.itemSystem;
              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Inventory: ${items.usedSlots}/${ItemSystem.maxSlots} slots',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
          // Item purchase buttons
          ...ItemType.values.map((type) => _buildItemPurchaseRow(type)),
        ],
      ),
    );
  }

  Widget _buildItemPurchaseRow(ItemType type) {
    return ListenableBuilder(
      listenable: widget.game.itemSystem,
      builder: (context, _) {
        final items = widget.game.itemSystem;
        final owned = items.getQuantity(type);
        final canBuy = items.canAddItem(type) &&
            widget.game.economySystem.canAfford(type.price);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon
              Text(type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      type.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Owned count
              if (owned > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'x$owned',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              // Buy button
              ElevatedButton(
                onPressed: canBuy ? () => _buyItem(type) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text('\$${type.price}'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section wrapper
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          child,
        ],
      ),
    );
  }

  /// Action message display
  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            _message!,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Return to mining button
  Widget _buildReturnButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => widget.game.closeShop(),
        icon: const Icon(Icons.construction),
        label: const Text('RETURN TO MINING'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _sellOre() {
    final earned = widget.game.sellOre();
    setState(() {
      _message = 'Sold ore for \$$earned!';
    });
    _clearMessageAfterDelay();
  }

  void _refuel() {
    if (widget.game.refuel()) {
      setState(() {
        _message = 'Tank refueled!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _upgradeFuel() {
    if (widget.game.upgradeFuelTank()) {
      setState(() {
        _message = 'Fuel tank upgraded!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _upgradeCargo() {
    if (widget.game.upgradeCargo()) {
      setState(() {
        _message = 'Cargo bay upgraded!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _repairHull() {
    if (widget.game.repairHull()) {
      setState(() {
        _message = 'Hull repaired!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _upgradeHull() {
    if (widget.game.upgradeHull()) {
      setState(() {
        _message = 'Hull armor upgraded!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _buyItem(ItemType type) {
    if (widget.game.buyItem(type)) {
      setState(() {
        _message = 'Purchased ${type.displayName}!';
      });
      _clearMessageAfterDelay();
    }
  }

  void _clearMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }
}