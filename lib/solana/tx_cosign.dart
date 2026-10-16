/// tx_cosign.dart
/// Add a second signer's signature to a serialized transaction after the
/// wallet has signed it.
///
/// Phantom requires a multi-signer transaction to reach the wallet with no
/// signatures: it signs first, may add its own guard instructions, and only
/// then can the other signers sign. So the NFT mint keypair signs the
/// message the wallet RETURNED, read straight from the bytes — re-encoding
/// it could change a byte and void the wallet's signature.
library;

import 'dart:typed_data';

import 'package:solana/solana.dart';

/// Sign [transaction]'s message with [signer] and write the signature into
/// the signer's slot. Works for legacy and v0 messages.
///
/// Throws [ArgumentError] when [signer] is not one of the message's
/// required signers, and [FormatException] for malformed bytes.
Future<Uint8List> cosignTransaction(
  Uint8List transaction,
  Ed25519HDKeyPair signer,
) async {
  final (signatureCount, signaturesStart) = _readCompactU16(transaction, 0);
  final messageStart = signaturesStart + 64 * signatureCount;
  if (messageStart >= transaction.length) {
    throw const FormatException('Transaction has no message');
  }
  final message = Uint8List.sublistView(transaction, messageStart);

  // v0 messages start with a version prefix byte (high bit set).
  var offset = (message[0] & 0x80) != 0 ? 1 : 0;
  final requiredSignatures = message[offset];
  offset += 3; // header: required sigs, readonly signed, readonly unsigned
  final (keyCount, keysStart) = _readCompactU16(message, offset);

  final target = signer.publicKey.bytes;
  final signers = requiredSignatures < keyCount ? requiredSignatures : keyCount;
  for (var i = 0; i < signers; i++) {
    if (!_matches(message, keysStart + 32 * i, target)) continue;
    if (i >= signatureCount) {
      throw const FormatException('Missing signature slot for signer');
    }
    final signature = await signer.sign(message);
    final out = Uint8List.fromList(transaction);
    final slot = signaturesStart + 64 * i;
    out.setRange(slot, slot + 64, signature.bytes);
    return out;
  }
  throw ArgumentError.value(
      signer.address, 'signer', 'is not a required signer of this transaction');
}

/// Solana's compact-u16 (1–3 bytes, 7 bits each). Returns the value and
/// the offset just past it.
(int, int) _readCompactU16(Uint8List bytes, int offset) {
  var value = 0;
  for (var i = 0; i < 3; i++) {
    if (offset + i >= bytes.length) {
      throw const FormatException('Truncated compact-u16');
    }
    final byte = bytes[offset + i];
    value |= (byte & 0x7f) << (7 * i);
    if ((byte & 0x80) == 0) return (value, offset + i + 1);
  }
  throw const FormatException('Invalid compact-u16');
}

bool _matches(Uint8List bytes, int offset, List<int> key) {
  if (offset + 32 > bytes.length) return false;
  for (var i = 0; i < 32; i++) {
    if (bytes[offset + i] != key[i]) return false;
  }
  return true;
}
