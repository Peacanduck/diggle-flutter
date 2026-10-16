/// tx_review_sheet.dart
/// "Review before you sign": every cost, the recipient and what the player
/// gets, shown before the wallet opens. Used by the Diggle Machine mint and
/// the Miner's Pass.
///
/// Phantom's review asks dApps to make fees, amounts, assets, recipients
/// and outcomes clear before anyone is asked to sign; the wallet's own
/// screen should then show the same numbers.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// One line of a review.
class TxReviewRow {
  final String label;
  final String value;

  /// Smaller line under the value, e.g. the recipient address.
  final String? detail;

  /// The total line: highlighted and set apart.
  final bool isTotal;

  const TxReviewRow(this.label, this.value, {this.detail, this.isTotal = false});
}

/// SOL with up to 6 decimals and no trailing zeros: fees are a few
/// hundred-thousandths of a SOL and must not round to zero.
String formatLamportsAsSol(int lamports) {
  final text = (lamports / 1e9)
      .toStringAsFixed(6)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  return '$text SOL';
}

/// `AbCd…WxYz`
String shortAddress(String address) => address.length <= 10
    ? address
    : '${address.substring(0, 4)}…${address.substring(address.length - 4)}';

/// Show the review. Resolves true only when the player taps approve.
Future<bool> showTxReviewSheet(
  BuildContext context, {
  required List<TxReviewRow> rows,
  String? note,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final approved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1a1a2e),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.txReviewTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Colors.white12),
                    _ReviewRow(row: rows[i]),
                  ],
                ],
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 12),
              Text(note,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l10n.txReviewApprove,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(false),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    ),
  );
  return approved ?? false;
}

class _ReviewRow extends StatelessWidget {
  final TxReviewRow row;

  const _ReviewRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final valueStyle = row.isTotal
        ? const TextStyle(
            color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)
        : const TextStyle(color: Colors.white, fontSize: 14);
    return Container(
      color: row.isTotal ? Colors.white.withOpacity(0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: TextStyle(
                color: row.isTotal ? Colors.white : Colors.white70,
                fontSize: row.isTotal ? 15 : 13,
                fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(row.value, textAlign: TextAlign.end, style: valueStyle),
                if (row.detail != null)
                  Text(
                    row.detail!,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
