/// main_menu.dart
/// Redesigned main menu with traditional game-style navigation:
/// - New Game → Save Slots (new game mode) → Game
/// - Continue → loads most recent save directly
/// - Load Game → Save Slots (load mode) → Game
/// - Account → Profile, wallet, stats
/// - Settings → Game settings (placeholder)
/// - How to Play → Tutorial/instructions (placeholder)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_lifecycle_manager.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback onNewGame;
  final VoidCallback onLoadGame;
  final VoidCallback onContinue;
  final VoidCallback onAccount;
  final VoidCallback? onSettings;
  final VoidCallback? onHowToPlay;

  /// Whether a recent save exists (enables Continue button)
  final bool hasSaves;

  const MainMenu({
    super.key,
    required this.onNewGame,
    required this.onLoadGame,
    required this.onContinue,
    required this.onAccount,
    this.onSettings,
    this.onHowToPlay,
    this.hasSaves = false,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0d1117),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // ── Game Title ──────────────────────────
                        _buildTitle(),

                        const Spacer(flex: 2),

                        // ── Menu Buttons ────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Primary: New Game
                              _buildAnimatedButton(
                                index: 0,
                                child: _PrimaryMenuButton(
                                  icon: Icons.add_circle_outline,
                                  label: 'NEW GAME',
                                  color: Colors.amber,
                                  onPressed: widget.onNewGame,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Continue — only if saves exist
                              if (widget.hasSaves) ...[
                                _buildAnimatedButton(
                                  index: 1,
                                  child: _PrimaryMenuButton(
                                    icon: Icons.play_arrow_rounded,
                                    label: 'CONTINUE',
                                    color: Colors.green,
                                    onPressed: widget.onContinue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Load Game
                              _buildAnimatedButton(
                                index: widget.hasSaves ? 2 : 1,
                                child: _SecondaryMenuButton(
                                  icon: Icons.folder_open,
                                  label: 'LOAD GAME',
                                  color: Colors.cyan,
                                  onPressed: widget.onLoadGame,
                                  enabled: widget.hasSaves,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Divider ──────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Icon(Icons.construction,
                                        color: Colors.white.withOpacity(0.15),
                                        size: 16),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Account
                              _buildAnimatedButton(
                                index: widget.hasSaves ? 3 : 2,
                                child: _SecondaryMenuButton(
                                  icon: Icons.person,
                                  label: 'ACCOUNT',
                                  color: Colors.purple,
                                  onPressed: widget.onAccount,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Bottom row: Settings + How to Play
                              _buildAnimatedButton(
                                index: widget.hasSaves ? 4 : 3,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _CompactMenuButton(
                                        icon: Icons.settings,
                                        label: 'Settings',
                                        onPressed: widget.onSettings ??
                                                () => _showComingSoon(
                                                context, 'Settings'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _CompactMenuButton(
                                        icon: Icons.help_outline,
                                        label: 'How to Play',
                                        onPressed: widget.onHowToPlay ??
                                                () => _showHowToPlayDialog(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 3),

                        // ── Version / Footer ───────────────────
                        _buildFooter(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(
          _animController.value.clamp(0.0, 1.0),
        );
        return Transform.scale(
          scale: 0.5 + 0.5 * t,
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
      child: Column(
        children: [
          // Pickaxe icon
          Icon(
            Icons.construction,
            color: Colors.amber.shade400,
            size: 48,
          ),
          const SizedBox(height: 8),
          // Game name
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.amber.shade600,
                Colors.orange.shade700,
              ],
            ).createShader(bounds),
            child: const Text(
              'DIGGLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'DIG DEEP  •  MINE RICHES  •  GO FURTHER',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 10,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Animated Button Wrapper ───────────────────────────────────

  Widget _buildAnimatedButton({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, c) {
        final delay = 0.15 + index * 0.08;
        final end = (delay + 0.4).clamp(0.0, 1.0);
        final t = ((_animController.value - delay) / (end - delay))
            .clamp(0.0, 1.0);
        final curved = Curves.easeOut.transform(t);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - curved)),
          child: Opacity(opacity: curved, child: c),
        );
      },
      child: child,
    );
  }

  // ── Footer ────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'PyroLabs',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'v0.1.0-alpha',
          style: TextStyle(
            color: Colors.white.withOpacity(0.12),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ── Coming Soon Dialog ────────────────────────────────────────

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.blueGrey.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// How to play Dialog
void _showHowToPlayDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            'How to Play',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpSection(
              '⛏️ Mining',
              'Use the arrow controls to move your drill. Dig through dirt and rock to find valuable ores.',
            ),
            _buildHelpSection(
              '⛽ Fuel',
              'Moving and digging consumes fuel. Return to the surface before running out!',
            ),
            _buildHelpSection(
              '🛡️ Hull',
              'Falling too far damages your hull. Watch your HP!',
            ),
            _buildHelpSection(
              '💰 Selling',
              'Return to the surface and visit the SHOP to sell your ore for cash.',
            ),
            _buildHelpSection(
              '🔧 Upgrades',
              'Use cash to upgrade your fuel tank, cargo bay, and hull armor.',
            ),
            _buildHelpSection(
              '⚠️ Hazards',
              'Watch out for lava (instant death) and gas pockets (damage)!',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('GOT IT!'),
        ),
      ],
    ),
  );
}

Widget _buildHelpSection(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// Menu Button Widgets
// ═══════════════════════════════════════════════════════════════════

/// Full-width primary action button (New Game, Continue)
class _PrimaryMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width secondary action button (Load Game, Account)
class _SecondaryMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool enabled;

  const _SecondaryMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey.shade700;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(
            color: effectiveColor.withOpacity(enabled ? 0.3 : 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: effectiveColor,
              ),
            ),
            if (!enabled) ...[
              const SizedBox(width: 6),
              Text(
                '(no saves)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact half-width button for Settings / How to Play
class _CompactMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CompactMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white38,
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}