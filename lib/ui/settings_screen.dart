/// settings_screen.dart
/// Game settings screen with language selector.
///
/// Currently supports:
///   - Language / locale selection
///
/// Placeholder sections for future settings (audio, controls, etc.)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_provider.dart';

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

// ── Language Section ──────────────────────────────────────────────

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.language,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.languageSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),

          // System default option
          _LanguageOption(
            flag: '🌐',
            label: l10n.systemDefault,
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
              child: _LanguageOption(
                flag: flag,
                label: label,
                isSelected: currentLocale?.languageCode == code,
                onTap: () => localeProvider.setLocale(locale),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Language Option Row ───────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
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
              ? Colors.blue.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue.shade200 : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }
}