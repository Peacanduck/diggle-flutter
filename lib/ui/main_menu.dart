/// main_menu.dart
/// Redesigned main menu with traditional game-style navigation.
/// All user-facing strings are localized via AppLocalizations.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';


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
    final l10n = AppLocalizations.of(context)!;

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
                        _buildTitle(l10n),
                        const Spacer(flex: 2),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAnimatedButton(
                                index: 0,
                                child: _PrimaryMenuButton(
                                  icon: Icons.add_circle_outline,
                                  label: l10n.newGame,
                                  color: Colors.amber,
                                  onPressed: widget.onNewGame,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (widget.hasSaves) ...[
                                _buildAnimatedButton(
                                  index: 1,
                                  child: _PrimaryMenuButton(
                                    icon: Icons.play_arrow_rounded,
                                    label: l10n.continueGame,
                                    color: Colors.green,
                                    onPressed: widget.onContinue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              _buildAnimatedButton(
                                index: widget.hasSaves ? 2 : 1,
                                child: _SecondaryMenuButton(
                                  icon: Icons.folder_open,
                                  label: l10n.loadGame,
                                  color: Colors.cyan,
                                  onPressed: widget.onLoadGame,
                                  enabled: widget.hasSaves,
                                  disabledSuffix: l10n.noSaves,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Divider
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

                              _buildAnimatedButton(
                                index: widget.hasSaves ? 3 : 2,
                                child: _SecondaryMenuButton(
                                  icon: Icons.person,
                                  label: l10n.account,
                                  color: Colors.purple,
                                  onPressed: widget.onAccount,
                                ),
                              ),

                              const SizedBox(height: 12),

                              _buildAnimatedButton(
                                index: widget.hasSaves ? 4 : 3,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _CompactMenuButton(
                                        icon: Icons.settings,
                                        label: l10n.settings,
                                        onPressed: widget.onSettings ??
                                                () => _showComingSoon(
                                                context, l10n.settings),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _CompactMenuButton(
                                        icon: Icons.help_outline,
                                        label: l10n.howToPlay,
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
                        _buildFooter(l10n),
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

  Widget _buildTitle(AppLocalizations l10n) {
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
          Icon(
            Icons.construction,
            color: Colors.amber.shade400,
            size: 48,
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.amber.shade600,
                Colors.orange.shade700,
              ],
            ).createShader(bounds),
            child: Text(
              l10n.appTitle.toUpperCase(),
              style: const TextStyle(
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
            l10n.tagline,
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

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.pyroLabs,
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.version,
          style: TextStyle(
            color: Colors.white.withOpacity(0.12),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoon(feature)),
        backgroundColor: Colors.blueGrey.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void _showHowToPlayDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.amber),
          const SizedBox(width: 8),
          Text(l10n.howToPlay, style: const TextStyle(color: Colors.white)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpSection(l10n.helpMiningTitle, l10n.helpMiningBody),
            _buildHelpSection(l10n.helpFuelTitle, l10n.helpFuelBody),
            _buildHelpSection(l10n.helpHullTitle, l10n.helpHullBody),
            _buildHelpSection(l10n.helpSellingTitle, l10n.helpSellingBody),
            _buildHelpSection(l10n.helpUpgradesTitle, l10n.helpUpgradesBody),
            _buildHelpSection(l10n.helpHazardsTitle, l10n.helpHazardsBody),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.gotIt),
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
        Text(title,
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// Menu Button Widgets
// ═══════════════════════════════════════════════════════════════════

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
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _SecondaryMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool enabled;
  final String? disabledSuffix;

  const _SecondaryMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.enabled = true,
    this.disabledSuffix,
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
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: effectiveColor)),
            if (!enabled && disabledSuffix != null) ...[
              const SizedBox(width: 6),
              Text(disabledSuffix!,
                  style: TextStyle(
                      fontSize: 10, color: Colors.white.withOpacity(0.2))),
            ],
          ],
        ),
      ),
    );
  }
}

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
            Text(label,
                style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}