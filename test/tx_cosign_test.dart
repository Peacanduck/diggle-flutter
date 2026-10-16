import 'dart:typed_data';

import 'package:diggle/solana/tx_cosign.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

/// An unsigned two-signer transaction (payer + new account), like the
/// candy machine mint the wallet receives: every signature slot zeroed.
Future<(Uint8List, List<int>)> unsignedTwoSigner({
  required Ed25519HDKeyPair payer,
  required Ed25519HDKeyPair newAccount,
  required bool v0,
}) async {
  final message = Message.only(SystemInstruction.createAccount(
    fundingAccount: payer.publicKey,
    newAccount: newAccount.publicKey,
    lamports: 1461600,
    space: 82,
    owner: payer.publicKey,
  ));
  const blockhash = 'EETubP5AKHgjPAhzPAFcb8BAY1hMH639CWCFTqi3hq1k';
  final compiled = v0
      ? message.compileV0(recentBlockhash: blockhash, feePayer: payer.publicKey)
      : message.compile(recentBlockhash: blockhash, feePayer: payer.publicKey);
  final tx = SignedTx(
    compiledMessage: compiled,
    signatures: List.filled(
      2,
      Signature(List.filled(64, 0), publicKey: payer.publicKey),
    ),
  );
  return (
    Uint8List.fromList(tx.toByteArray().toList()),
    compiled.toByteArray().toList(),
  );
}

Uint8List slot(Uint8List tx, int i) => Uint8List.sublistView(tx, 1 + 64 * i, 1 + 64 * (i + 1));

bool isZero(Uint8List bytes) => bytes.every((b) => b == 0);

void main() {
  for (final v0 in [false, true]) {
    group(v0 ? 'v0 message' : 'legacy message', () {
      test('the co-signer fills only its own slot, over the exact message',
          () async {
        final payer = await Ed25519HDKeyPair.random();
        final mint = await Ed25519HDKeyPair.random();
        final (tx, messageBytes) =
            await unsignedTwoSigner(payer: payer, newAccount: mint, v0: v0);

        final signed = await cosignTransaction(tx, mint);

        expect(signed.length, tx.length);
        expect(isZero(slot(signed, 0)), isTrue, reason: 'payer slot untouched');
        expect(
          await verifySignature(
            message: messageBytes,
            signature: slot(signed, 1),
            publicKey: mint.publicKey,
          ),
          isTrue,
        );
        expect(signed.sublist(1 + 128), tx.sublist(1 + 128),
            reason: 'message bytes unchanged');
      });

      test('keeps a signature the wallet already added', () async {
        final payer = await Ed25519HDKeyPair.random();
        final mint = await Ed25519HDKeyPair.random();
        final (tx, messageBytes) =
            await unsignedTwoSigner(payer: payer, newAccount: mint, v0: v0);

        final walletSigned = await cosignTransaction(tx, payer);
        final both = await cosignTransaction(walletSigned, mint);

        for (final (i, key) in [(0, payer), (1, mint)]) {
          expect(
            await verifySignature(
              message: messageBytes,
              signature: slot(both, i),
              publicKey: key.publicKey,
            ),
            isTrue,
          );
        }
      });

      test('refuses a key that is not a signer', () async {
        final payer = await Ed25519HDKeyPair.random();
        final mint = await Ed25519HDKeyPair.random();
        final stranger = await Ed25519HDKeyPair.random();
        final (tx, _) =
            await unsignedTwoSigner(payer: payer, newAccount: mint, v0: v0);

        expect(() => cosignTransaction(tx, stranger), throwsArgumentError);
      });
    });
  }
}
