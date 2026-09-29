/// review_prompt_overlay.dart
/// The store-review sheet.
///
/// Two buttons, no star-picker and no "rate us 1–5?" pre-filter — those gates
/// read as manipulative and the dApp Store audience is sensitive to it (§7).
///
/// [ReviewPromptSheet] is the self-contained card; it is shown two ways —
/// as a Flame overlay in-game ([ReviewPromptOverlay]) and as a modal bottom
/// sheet on the menu (see main.dart). Both drive the same
/// [ReviewPromptService].
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../game/diggle_game.dart';
import '../l10n/app_localizations.dart';
import '../services/review_prompt_service.dart';

/// Game-overlay wrapper: dims the world and centres the sheet. Registered as
/// `'reviewPrompt'` in the overlay map.
class ReviewPromptOverlay extends StatelessWidget {
  final DiggleGame game;

  const ReviewPromptOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final service = game.reviewPromptService;
    if (service == null) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ReviewPromptSheet(
          service: service,
          onClose: () => game.overlays.remove('reviewPrompt'),
        ),
      ),
    );
  }
}

enum _Phase { prompt, thanks, failed }

class ReviewPromptSheet extends StatefulWidget {
  final ReviewPromptService service;
  final VoidCallback onClose;

  const ReviewPromptSheet({
    super.key,
    required this.service,
    required this.onClose,
  });

  @override
  State<ReviewPromptSheet> createState() => _ReviewPromptSheetState();
}

class _ReviewPromptSheetState extends State<ReviewPromptSheet> {
  _Phase _phase = _Phase.prompt;
  bool _busy = false;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRate() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.service.rate();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _phase = ok ? _Phase.thanks : _Phase.failed;
    });
    // Thanks self-closes; the failure message lingers a little longer, then
    // closes. On failure the milestone stays banked (service.rate left
    // pending set), so it retries next session.
    _closeTimer = Timer(
      Duration(milliseconds: ok ? 1500 : 2500),
      widget.onClose,
    );
  }

  Future<void> _onLater() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.service.dismiss();
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Widget body;
    switch (_phase) {
      case _Phase.thanks:
        body = _Message(text: l10n.reviewPromptThanks, icon: Icons.favorite);
        break;
      case _Phase.failed:
        body = _Message(
            text: l10n.reviewPromptFailed, icon: Icons.error_outline);
        break;
      case _Phase.prompt:
        body = _prompt(l10n);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: body,
        ),
      ),
    );
  }

  Widget _prompt(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.reviewPromptTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.reviewPromptBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: _busy ? null : _onRate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(46),
          ),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : Text(
                  l10n.reviewPromptRate,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _onLater,
          child: Text(
            l10n.reviewPromptLater,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Message({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.amber, size: 32),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}
