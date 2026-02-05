/// shop_overlay.dart
/// Surface shop overlay for:
/// - Selling collected ore
/// - Refueling
/// - Purchasing upgrades (fuel, cargo, hull, drillbit, engine, cooling)
/// - Buying items
///
/// Only accessible when player is at surface.

import 'package:flutter/material.dart';
import '../game/diggle_game.dart';
import '../game/systems/fuel_system.dart';
import '../game/systems/economy_system.dart';
import '../game/systems/hull_system.dart';
import '../game/systems/item_system.dart';
import '../game/systems/drillbit_system.dart';
import '../game/systems/engine_system.dart';
import '../game/systems/cooling_system.dart';
import '../game/world/tile.dart';

/// Shop overlay widget
class ShopOverlay extends StatefulWidget {
  final DiggleGame game;

  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> with SingleTickerProviderStateMixin {
  /// Message to display after action
  String? _message;

  /// Tab controller for shop sections
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            // Header with close button
            _buildHeader(),

            // Player stats
            _buildPlayerStats(),

            // Tab bar
            _buildTabBar(),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Services tab (sell, refuel, repair)
                  _buildServicesTab(),

                  // Upgrades tab
                  _buildUpgradesTab(),

                  // Items tab
                  _buildItemsTab(),
                ],
              ),
            ),

            // Action message
            if (_message != null) _buildMessage(),

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
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Tab bar
  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade900,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.amber,
        labelColor: Colors.amber,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(icon: Icon(Icons.handshake), text: 'Services'),
          Tab(icon: Icon(Icons.upgrade), text: 'Upgrades'),
          Tab(icon: Icon(Icons.backpack), text: 'Items'),
        ],
      ),
    );
  }

  /// Services tab (sell, refuel, repair)
  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSellSection(),
          const SizedBox(height: 12),
          _buildRefuelSection(),
          const SizedBox(height: 12),
          _buildRepairSection(),
        ],
      ),
    );
  }

  /// Upgrades tab
  Widget _buildUpgradesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildDrillbitUpgrade(),
          const SizedBox(height: 12),
          _buildEngineUpgrade(),
          const SizedBox(height: 12),
          _buildCoolingUpgrade(),
          const SizedBox(height: 12),
          _buildFuelUpgrade(),
          const SizedBox(height: 12),
          _buildCargoUpgrade(),
          const SizedBox(height: 12),
          _buildHullUpgrade(),
        ],
      ),
    );
  }

  /// Items tab
  Widget _buildItemsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
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
              _buildProgressBar(
                value: fuel.fuel,
                max: fuel.maxFuel,
                color: fuel.isCritical ? Colors.red : fuel.isLow ? Colors.orange : Colors.green,
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
                const Text('Tank is full!', style: TextStyle(color: Colors.green)),
            ],
          ),
        );
      },
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
              _buildProgressBar(
                value: hull.hull,
                max: hull.maxHull,
                color: hull.isCritical ? Colors.red : hull.isLow ? Colors.orange : Colors.green,
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
                const Text('Hull is fully repaired!', style: TextStyle(color: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  /// Drillbit upgrade
  Widget _buildDrillbitUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.drillbitSystem,
      builder: (context, _) {
        final system = widget.game.drillbitSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeCard(
          icon: system.icon,
          title: 'Drill Bit',
          currentLevel: system.name,
          currentDescription: system.description,
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel?.description,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeDrillbit : null,
          accentColor: Colors.orange,
        );
      },
    );
  }

  /// Engine upgrade
  Widget _buildEngineUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.engineSystem,
      builder: (context, _) {
        final system = widget.game.engineSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeCard(
          icon: system.icon,
          title: 'Engine',
          currentLevel: system.name,
          currentDescription: 'Speed: ${(system.speedMultiplier * 100).toInt()}%',
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel != null ? 'Speed: ${(nextLevel.speedMultiplier * 100).toInt()}%' : null,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeEngine : null,
          accentColor: Colors.blue,
        );
      },
    );
  }

  /// Cooling upgrade
  Widget _buildCoolingUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.coolingSystem,
      builder: (context, _) {
        final system = widget.game.coolingSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeCard(
          icon: system.icon,
          title: 'Cooling',
          currentLevel: system.name,
          currentDescription: system.savingsPercent > 0
              ? 'Fuel savings: ${system.savingsPercent}%'
              : 'No fuel savings',
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel != null ? 'Fuel savings: ${nextLevel.savingsPercent}%' : null,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeCooling : null,
          accentColor: Colors.cyan,
        );
      },
    );
  }

  /// Fuel tank upgrade
  Widget _buildFuelUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.fuelSystem,
      builder: (context, _) {
        final fuel = widget.game.fuelSystem;
        final nextLevel = fuel.getNextUpgrade();
        final cost = fuel.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeCard(
          icon: '⛽',
          title: 'Fuel Tank',
          currentLevel: fuel.tankLevel.name,
          currentDescription: 'Capacity: ${fuel.maxFuel.toInt()}',
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel != null ? 'Capacity: ${nextLevel.maxFuel.toInt()}' : null,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeFuel : null,
          accentColor: Colors.green,
        );
      },
    );
  }

  /// Cargo upgrade
  Widget _buildCargoUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        final economy = widget.game.economySystem;
        final nextLevel = economy.getNextCargoUpgrade();
        final cost = economy.getCargoUpgradeCost();
        final canAfford = economy.canAfford(cost);

        return _buildUpgradeCard(
          icon: '📦',
          title: 'Cargo Bay',
          currentLevel: economy.cargoLevel.name,
          currentDescription: 'Capacity: ${economy.maxCapacity}',
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel != null ? 'Capacity: ${nextLevel.maxCapacity}' : null,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeCargo : null,
          accentColor: Colors.brown,
        );
      },
    );
  }

  /// Hull upgrade
  Widget _buildHullUpgrade() {
    return ListenableBuilder(
      listenable: widget.game.hullSystem,
      builder: (context, _) {
        final hull = widget.game.hullSystem;
        final nextLevel = hull.getNextUpgrade();
        final cost = hull.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildUpgradeCard(
          icon: '🛡️',
          title: 'Hull Armor',
          currentLevel: hull.hullLevel.name,
          currentDescription: 'Max HP: ${hull.maxHull.toInt()}',
          nextLevel: nextLevel?.name,
          nextDescription: nextLevel != null ? 'Max HP: ${nextLevel.maxHull.toInt()}' : null,
          cost: cost,
          canAfford: canAfford,
          onUpgrade: nextLevel != null ? _upgradeHull : null,
          accentColor: Colors.purple,
        );
      },
    );
  }

  /// Generic upgrade card widget
  Widget _buildUpgradeCard({
    required String icon,
    required String title,
    required String currentLevel,
    required String currentDescription,
    String? nextLevel,
    String? nextDescription,
    required int cost,
    required bool canAfford,
    VoidCallback? onUpgrade,
    required Color accentColor,
  }) {
    final isMaxed = nextLevel == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isMaxed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'MAXED',
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Current level
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLevel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMaxed) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Colors.white54),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextLevel!,
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          nextDescription ?? '',
                          style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Upgrade button
          if (!isMaxed) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford ? onUpgrade : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade800,
                ),
                child: Text('UPGRADE - \$$cost'),
              ),
            ),
          ],
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
              Text(type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      type.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.all(12),
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

  /// Progress bar widget
  Widget _buildProgressBar({
    required double value,
    required double max,
    required Color color,
  }) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / max).clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Center(
            child: Text(
              '${value.toInt()} / ${max.toInt()}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Action message display
  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(_message!, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// Return to mining button
  Widget _buildReturnButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
    _showMessage('Sold ore for \$$earned!');
  }

  void _refuel() {
    if (widget.game.refuel()) {
      _showMessage('Tank refueled!');
    }
  }

  void _upgradeFuel() {
    if (widget.game.upgradeFuelTank()) {
      _showMessage('Fuel tank upgraded!');
    }
  }

  void _upgradeCargo() {
    if (widget.game.upgradeCargo()) {
      _showMessage('Cargo bay upgraded!');
    }
  }

  void _repairHull() {
    if (widget.game.repairHull()) {
      _showMessage('Hull repaired!');
    }
  }

  void _upgradeHull() {
    if (widget.game.upgradeHull()) {
      _showMessage('Hull armor upgraded!');
    }
  }

  void _upgradeDrillbit() {
    if (widget.game.upgradeDrillbit()) {
      _showMessage('Drill bit upgraded!');
    }
  }

  void _upgradeEngine() {
    if (widget.game.upgradeEngine()) {
      _showMessage('Engine upgraded!');
    }
  }

  void _upgradeCooling() {
    if (widget.game.upgradeCooling()) {
      _showMessage('Cooling system upgraded!');
    }
  }

  void _buyItem(ItemType type) {
    if (widget.game.buyItem(type)) {
      _showMessage('Purchased ${type.displayName}!');
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }
}