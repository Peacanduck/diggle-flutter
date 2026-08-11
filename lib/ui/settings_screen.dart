/// settings_screen.dart
/// Game settings screen.
///
/// Currently supports:
///   - Language / locale selection
///   - Visual effect quality (particles, screen shake, impact flashes)
///
/// Placeholder sections for future settings (audio, controls, etc.)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/systems/vfx_queue.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_provider.dart';
import '../services/vfx_settings.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _LanguageSection(),
                      const SizedBox(height: 16),
                      _VfxSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white70, size: 28),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTitle,
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              Text(
                l10n.settingsSubtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────
// Shared chrome so every settings section reads the same.

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final MaterialColor accent;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Language Section ──────────────────────────────────────────────

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return _SettingsCard(
      icon: Icons.language,
      accent: Colors.blue,
      title: l10n.language,
      subtitle: l10n.languageSubtitle,
      children: [
        // System default option
        _SettingOption(
          glyph: '🌐',
          label: l10n.systemDefault,
          accent: Colors.blue,
          isSelected: currentLocale == null,
          onTap: () => localeProvider.clearLocale(),
        ),

        const SizedBox(height: 6),

        // Each supported locale
        ...LocaleProvider.supportedLocales.map((locale) {
          final code = locale.languageCode;
          final flag = LocaleProvider.localeFlags[code] ?? '🏳️';
          final label = LocaleProvider.localeLabels[code] ?? code;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SettingOption(
              glyph: flag,
              label: label,
              accent: Colors.blue,
              isSelected: currentLocale?.languageCode == code,
              onTap: () => localeProvider.setLocale(locale),
            ),
          );
        }),
      ],
    );
  }
}

// ── Visual Effects Section ────────────────────────────────────────

class _VfxSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<VfxSettings>();

    // Best first. Off last, so the destructive-looking option is not the
    // one a thumb lands on by accident.
    final options = <(VfxQuality, String, String, String)>[
      (VfxQuality.full, '✨', l10n.vfxQualityFull, l10n.vfxQualityFullDesc),
      (VfxQuality.low, '💫', l10n.vfxQualityLow, l10n.vfxQualityLowDesc),
      (VfxQuality.off, '🚫', l10n.vfxQualityOff, l10n.vfxQualityOffDesc),
    ];

    return _SettingsCard(
      icon: Icons.auto_awesome,
      accent: Colors.amber,
      title: l10n.vfxQualitySection,
      subtitle: l10n.vfxQualitySubtitle,
      children: [
        for (final (quality, glyph, label, description) in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SettingOption(
              glyph: glyph,
              label: label,
              description: description,
              accent: Colors.amber,
              isSelected: settings.quality == quality,
              onTap: () => settings.setQuality(quality),
            ),
          ),
      ],
    );
  }
}

// ── Option Row ────────────────────────────────────────────────────

class _SettingOption extends StatelessWidget {
  final String glyph;
  final String label;
  final String? description;
  final MaterialColor accent;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingOption({
    required this.glyph,
    required this.label,
    required this.accent,
    required this.isSelected,
    required this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accent.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(glyph, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? accent.shade200 : Colors.white70,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}