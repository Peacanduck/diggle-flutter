import 'package:diggle/solana/candy_machine_service.dart';
import 'package:diggle/ui/tx_review_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatLamportsAsSol', () {
    test('fees never round to zero', () {
      expect(formatLamportsAsSol(30000), '0.00003 SOL');
      expect(formatLamportsAsSol(7000), '0.000007 SOL');
    });

    test('no trailing zeros', () {
      expect(formatLamportsAsSol(100000000), '0.1 SOL');
      expect(formatLamportsAsSol(1000000000), '1 SOL');
      expect(formatLamportsAsSol(117731280), '0.117731 SOL');
    });
  });

  test('shortAddress keeps both ends', () {
    expect(shortAddress('6tXwopHLEUr5DEiert4ASgmEQnfV3CQ2dkVWCTVvHUR9'),
        '6tXw…HUR9');
    expect(shortAddress('short'), 'short');
  });

  group('MintQuote.fromJson', () {
    test('reads the edge function quote', () {
      final quote = MintQuote.fromJson({
        'priceLamports': 100000000,
        'destination': '6tXwopHLEUr5DEiert4ASgmEQnfV3CQ2dkVWCTVvHUR9',
        'feeLamports': 30000,
        'rentLamports': 17701280,
        'totalLamports': 117731280,
      });
      expect(quote.priceLamports, 100000000);
      expect(quote.rentLamports, 17701280);
      expect(quote.feeLamports, 30000);
      expect(quote.totalLamports, 117731280);
      expect(quote.destination, '6tXwopHLEUr5DEiert4ASgmEQnfV3CQ2dkVWCTVvHUR9');
    });

    test('total falls back to the sum of its parts', () {
      final quote = MintQuote.fromJson({
        'priceLamports': 100000000,
        'feeLamports': 30000,
        'rentLamports': 17701280,
      });
      expect(quote.totalLamports, 117731280);
      expect(quote.destination, '');
    });
  });
}
