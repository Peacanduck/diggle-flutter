/// shop_overlay.dart
/// Surface shop overlay. All strings localized via AppLocalizations.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/diggle_game.dart';
import '../game/systems/economy_system.dart';
import '../game/systems/item_system.dart';
import '../game/world/tile.dart';

class ShopOverlay extends StatefulWidget {
  final DiggleGame game;
  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay>
    with SingleTickerProviderStateMixin {
  String? _message;
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildPlayerStats(l10n),
            _buildTabBar(l10n),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildServicesTab(l10n),
                  _buildUpgradesTab(l10n),
                  _buildItemsTab(l10n),
                ],
              ),
            ),
            if (_message != null) _buildMessage(),
            _buildReturnButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
          Text(l10n.miningSupplyCo,
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => widget.game.closeShop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(AppLocalizations l10n) {
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
                label: l10n.cash,
                value: '\$${widget.game.economySystem.cash}',
                color: Colors.amber,
              ),
              _buildStatItem(
                icon: Icons.shield,
                label: l10n.hull,
                value:
                '${widget.game.hullSystem.hull.toInt()}/${widget.game.hullSystem.maxHull.toInt()}',
                color: widget.game.hullSystem.isCritical
                    ? Colors.red
                    : Colors.green,
              ),
              _buildStatItem(
                icon: Icons.local_gas_station,
                label: l10n.fuelLabel,
                value:
                '${widget.game.fuelSystem.fuel.toInt()}/${widget.game.fuelSystem.maxFuel.toInt()}',
                color: Colors.cyan,
              ),
              _buildStatItem(
                icon: Icons.inventory_2,
                label: l10n.cargo,
                value:
                '${widget.game.economySystem.cargoCount}/${widget.game.economySystem.maxCapacity}',
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
        Text(label,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      color: Colors.grey.shade900,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.amber,
        labelColor: Colors.amber,
        unselectedLabelColor: Colors.white54,
        tabs: [
          Tab(icon: const Icon(Icons.handshake), text: l10n.services),
          Tab(icon: const Icon(Icons.upgrade), text: l10n.upgrades),
          Tab(icon: const Icon(Icons.backpack), text: l10n.itemsTab),
        ],
      ),
    );
  }

  Widget _buildServicesTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSellSection(l10n),
          const SizedBox(height: 12),
          _buildRefuelSection(l10n),
          const SizedBox(height: 12),
          _buildRepairSection(l10n),
        ],
      ),
    );
  }

  Widget _buildUpgradesTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildDrillbitUpgrade(l10n),
          const SizedBox(height: 12),
          _buildEngineUpgrade(l10n),
          const SizedBox(height: 12),
          _buildCoolingUpgrade(l10n),
          const SizedBox(height: 12),
          _buildFuelUpgrade(l10n),
          const SizedBox(height: 12),
          _buildCargoUpgrade(l10n),
          const SizedBox(height: 12),
          _buildHullUpgrade(l10n),
        ],
      ),
    );
  }

  Widget _buildItemsTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
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
                      l10n.inventorySlots(
                          items.usedSlots, ItemSystem.maxSlots),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
          ...ItemType.values.map((type) => _buildItemPurchaseRow(type)),
        ],
      ),
    );
  }

  Widget _buildSellSection(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        final economy = widget.game.economySystem;
        final hasOre = economy.hasOre;

        return _buildSection(
          title: l10n.sellOre,
          icon: Icons.sell,
          child: Column(
            children: [
              if (hasOre)
                ...economy.cargoItems.map((item) => _buildCargoRow(item))
              else
                Text(l10n.noOreToSell,
                    style: const TextStyle(color: Colors.white54)),
              if (hasOre) ...[
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalValue,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                    Text('\$${economy.cargoValue}',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
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
                    child: Text(l10n.sellAll),
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
          Text(item.oreType.displayName,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Text('x${item.quantity}',
              style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          Text('\$${item.totalValue}',
              style: const TextStyle(color: Colors.amber)),
        ],
      ),
    );
  }

  Widget _buildRefuelSection(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.fuelSystem,
      builder: (context, _) {
        final fuel = widget.game.fuelSystem;
        final cost = fuel.getRefillCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildSection(
          title: l10n.refuel,
          icon: Icons.local_gas_station,
          child: Column(
            children: [
              _buildProgressBar(
                value: fuel.fuel,
                max: fuel.maxFuel,
                color: fuel.isCritical
                    ? Colors.red
                    : fuel.isLow
                    ? Colors.orange
                    : Colors.green,
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
                    child: Text(l10n.refuelCost(cost)),
                  ),
                )
              else
                Text(l10n.tankFull,
                    style: const TextStyle(color: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepairSection(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.hullSystem,
      builder: (context, _) {
        final hull = widget.game.hullSystem;
        final cost = hull.getRepairCost();
        final canAfford = widget.game.economySystem.canAfford(cost);

        return _buildSection(
          title: l10n.repair,
          icon: Icons.build,
          child: Column(
            children: [
              _buildProgressBar(
                value: hull.hull,
                max: hull.maxHull,
                color: hull.isCritical
                    ? Colors.red
                    : hull.isLow
                    ? Colors.orange
                    : Colors.green,
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
                    child: Text(l10n.repairHullCost(cost)),
                  ),
                )
              else
                Text(l10n.hullFullyRepaired,
                    style: const TextStyle(color: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  // ── Upgrades ─────────────────────────────────────────────────

  Widget _buildDrillbitUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.drillbitSystem,
      builder: (context, _) {
        final system = widget.game.drillbitSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: system.icon,
            title: l10n.drillBit,
            currentLevel: system.name,
            currentDescription: system.description,
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel?.description,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeDrillbit : null,
            accentColor: Colors.orange);
      },
    );
  }

  Widget _buildEngineUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.engineSystem,
      builder: (context, _) {
        final system = widget.game.engineSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: system.icon,
            title: l10n.engine,
            currentLevel: system.name,
            currentDescription:
            l10n.speedPercent((system.speedMultiplier * 100).toInt()),
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel != null
                ? l10n.speedPercent(
                (nextLevel.speedMultiplier * 100).toInt())
                : null,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeEngine : null,
            accentColor: Colors.blue);
      },
    );
  }

  Widget _buildCoolingUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.coolingSystem,
      builder: (context, _) {
        final system = widget.game.coolingSystem;
        final nextLevel = system.getNextUpgrade();
        final cost = system.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: system.icon,
            title: l10n.cooling,
            currentLevel: system.name,
            currentDescription: system.savingsPercent > 0
                ? l10n.fuelSavingsPercent(system.savingsPercent)
                : l10n.noFuelSavings,
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel != null
                ? l10n.fuelSavingsPercent(nextLevel.savingsPercent)
                : null,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeCooling : null,
            accentColor: Colors.cyan);
      },
    );
  }

  Widget _buildFuelUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.fuelSystem,
      builder: (context, _) {
        final fuel = widget.game.fuelSystem;
        final nextLevel = fuel.getNextUpgrade();
        final cost = fuel.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: '⛽',
            title: l10n.fuelTank,
            currentLevel: fuel.tankLevel.name,
            currentDescription:
            l10n.capacityValue(fuel.maxFuel.toInt()),
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel != null
                ? l10n.capacityValue(nextLevel.maxFuel.toInt())
                : null,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeFuel : null,
            accentColor: Colors.green);
      },
    );
  }

  Widget _buildCargoUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.economySystem,
      builder: (context, _) {
        final economy = widget.game.economySystem;
        final nextLevel = economy.getNextCargoUpgrade();
        final cost = economy.getCargoUpgradeCost();
        final canAfford = economy.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: '📦',
            title: l10n.cargoBay,
            currentLevel: economy.cargoLevel.name,
            currentDescription:
            l10n.capacityValue(economy.maxCapacity),
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel != null
                ? l10n.capacityValue(nextLevel.maxCapacity)
                : null,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeCargo : null,
            accentColor: Colors.brown);
      },
    );
  }

  Widget _buildHullUpgrade(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.game.hullSystem,
      builder: (context, _) {
        final hull = widget.game.hullSystem;
        final nextLevel = hull.getNextUpgrade();
        final cost = hull.getUpgradeCost();
        final canAfford = widget.game.economySystem.canAfford(cost);
        return _buildUpgradeCard(l10n,
            icon: '🛡️',
            title: l10n.hullArmor,
            currentLevel: hull.hullLevel.name,
            currentDescription:
            l10n.maxHpValue(hull.maxHull.toInt()),
            nextLevel: nextLevel?.name,
            nextDescription: nextLevel != null
                ? l10n.maxHpValue(nextLevel.maxHull.toInt())
                : null,
            cost: cost,
            canAfford: canAfford,
            onUpgrade: nextLevel != null ? _upgradeHull : null,
            accentColor: Colors.purple);
      },
    );
  }

  Widget _buildUpgradeCard(
      AppLocalizations l10n, {
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
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isMaxed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.maxed,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
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
                      Text(currentLevel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(currentDescription,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
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
                      border: Border.all(
                          color: accentColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nextLevel!,
                            style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold)),
                        Text(nextDescription ?? '',
                            style: TextStyle(
                                color: accentColor.withOpacity(0.7),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
                child: Text(l10n.upgradeCost(cost)),
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
                    Text(type.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(type.description,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              if (owned > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('x$owned',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11)),
                ),
              ElevatedButton(
                onPressed: canBuy ? () => _buyItem(type) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                child: Text('\$${type.price}'),
              ),
            ],
          ),
        );
      },
    );
  }

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
              Text(title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24),
          child,
        ],
      ),
    );
  }

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
            child: Text('${value.toInt()} / ${max.toInt()}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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

  Widget _buildReturnButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: () => widget.game.closeShop(),
        icon: const Icon(Icons.construction),
        label: Text(l10n.returnToMining),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────

  void _sellOre() {
    final l10n = AppLocalizations.of(context)!;
    final earned = widget.game.sellOre();
    _showMessage(l10n.soldOreFor(earned));
  }

  void _refuel() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.refuel()) _showMessage(l10n.tankRefueled);
  }

  void _upgradeFuel() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeFuelTank()) _showMessage(l10n.fuelTankUpgraded);
  }

  void _upgradeCargo() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeCargo()) _showMessage(l10n.cargoBayUpgraded);
  }

  void _repairHull() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.repairHull()) _showMessage(l10n.hullRepaired);
  }

  void _upgradeHull() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeHull()) _showMessage(l10n.hullArmorUpgraded);
  }

  void _upgradeDrillbit() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeDrillbit()) _showMessage(l10n.drillBitUpgraded);
  }

  void _upgradeEngine() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeEngine()) _showMessage(l10n.engineUpgraded);
  }

  void _upgradeCooling() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.upgradeCooling()) _showMessage(l10n.coolingUpgraded);
  }

  void _buyItem(ItemType type) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.buyItem(type)) _showMessage(l10n.purchased(type.displayName));
  }

  void _showMessage(String message) {
    setState(() => _message = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = null);
    });
  }
}