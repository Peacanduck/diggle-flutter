/// diggle_mart_client.dart
/// Client for the Diggle Mart on-chain Solana program.
///
/// Program ID: CHY3Z9P6icJiB4zDjoemhWWR71yh11Fhz8dhZHaxpsV4
///
/// Handles:
/// - PDA derivation for store, treasury, boosters
/// - Building instructions with Anchor discriminators + Borsh args
/// - Transaction construction for MWA signing
/// - Deserializing on-chain account data (Store, BoosterAccount)
///
/// Instructions supported:
/// - purchaseBooster(boosterType: u8, durationSeconds: i64)
/// - purchasePointsPack(packType: u8)
///
/// Read operations:
/// - fetchStore()
/// - fetchActiveBoosters(ownerPubkey)

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:solana/dto.dart' hide Instruction;
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

// ============================================================
// CONSTANTS
// ============================================================

/// Diggle Mart program ID
const String diggleMartProgramId =
    'CHY3Z9P6icJiB4zDjoemhWWR71yh11Fhz8dhZHaxpsV4';

/// System program
const String systemProgramId = '11111111111111111111111111111111';

/// PDA seeds
const String _seedStore = 'store';
const String _seedTreasury = 'treasury';
const String _seedBooster = 'booster';

// ============================================================
// ANCHOR INSTRUCTION DISCRIMINATORS (from IDL — 8 bytes)
// ============================================================

final Uint8List _discPurchaseBooster =
Uint8List.fromList([251, 49, 11, 156, 68, 194, 21, 140]);

final Uint8List _discPurchasePointsPack =
Uint8List.fromList([125, 42, 47, 199, 26, 93, 227, 99]);

// ============================================================
// ANCHOR ACCOUNT DISCRIMINATORS (from IDL — 1 byte, optimized)
// ============================================================

const int _discStoreAccount = 1;

const int _discBoosterAccount = 2;

// ============================================================
// DATA MODELS
// ============================================================

/// On-chain store configuration
class OnChainStoreConfig {
  final int xpBoostPricePerHour; // lamports
  final int pointsBoostPricePerHour;
  final int comboBoostPricePerHour;
  final int xpBoostMultiplier; // basis points (15000 = 1.5x)
  final int pointsBoostMultiplier;
  final int comboBoostMultiplier;
  final int pointsPackSmallPrice; // lamports
  final int pointsPackSmallAmount;
  final int pointsPackLargePrice;
  final int pointsPackLargeAmount;
  final bool isActive;

  const OnChainStoreConfig({
    required this.xpBoostPricePerHour,
    required this.pointsBoostPricePerHour,
    required this.comboBoostPricePerHour,
    required this.xpBoostMultiplier,
    required this.pointsBoostMultiplier,
    required this.comboBoostMultiplier,
    required this.pointsPackSmallPrice,
    required this.pointsPackSmallAmount,
    required this.pointsPackLargePrice,
    required this.pointsPackLargeAmount,
    required this.isActive,
  });

  /// Convert basis points multiplier to double (15000 -> 1.5)
  double get xpMultiplierDouble => xpBoostMultiplier / 10000.0;
  double get pointsMultiplierDouble => pointsBoostMultiplier / 10000.0;
  double get comboMultiplierDouble => comboBoostMultiplier / 10000.0;

  /// Convert lamports to SOL
  double get xpBoostPriceSOLPerHour => xpBoostPricePerHour / 1e9;
  double get pointsBoostPriceSOLPerHour => pointsBoostPricePerHour / 1e9;
  double get comboBoostPriceSOLPerHour => comboBoostPricePerHour / 1e9;
  double get pointsPackSmallPriceSOL => pointsPackSmallPrice / 1e9;
  double get pointsPackLargePriceSOL => pointsPackLargePrice / 1e9;
}

/// Full on-chain store account data
class OnChainStore {
  final String authority;
  final String treasury;
  final OnChainStoreConfig config;
  final int totalBoostersSold;
  final int totalSolCollected;
  final int bump;

  const OnChainStore({
    required this.authority,
    required this.treasury,
    required this.config,
    required this.totalBoostersSold,
    required this.totalSolCollected,
    required this.bump,
  });
}

/// On-chain booster account data
class OnChainBooster {
  final String owner;
  final int boosterType; // 0=XP, 1=Points, 2=Combo
  final int multiplier; // basis points
  final int purchasedAt; // unix timestamp
  final int expiresAt; // unix timestamp
  final bool isActive;
  final int pricePaid; // lamports
  final int bump;
  final String address; // PDA address of this account

  const OnChainBooster({
    required this.owner,
    required this.boosterType,
    required this.multiplier,
    required this.purchasedAt,
    required this.expiresAt,
    required this.isActive,
    required this.pricePaid,
    required this.bump,
    required this.address,
  });

  double get multiplierDouble => multiplier / 10000.0;

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresAt;

  Duration get timeRemaining {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = expiresAt - now;
    return remaining > 0 ? Duration(seconds: remaining) : Duration.zero;
  }
}

// ============================================================
// DIGGLE MART CLIENT
// ============================================================

class DiggleMartClient {
  final SolanaClient rpcClient;
  final Ed25519HDPublicKey programId;

  // Cached PDAs
  Ed25519HDPublicKey? _storePda;
  Ed25519HDPublicKey? _treasuryPda;

  DiggleMartClient({required this.rpcClient})
      : programId = Ed25519HDPublicKey.fromBase58(diggleMartProgramId);

  // ============================================================
  // PDA DERIVATION
  // ============================================================

  /// Derive store PDA: seeds = ["store"]
  Future<Ed25519HDPublicKey> getStorePda() async {
    if (_storePda != null) return _storePda!;
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [utf8.encode(_seedStore)],
      programId: programId,
    );
    _storePda = result;
    return result;
  }

  /// Derive treasury PDA: seeds = ["treasury"]
  Future<Ed25519HDPublicKey> getTreasuryPda() async {
    if (_treasuryPda != null) return _treasuryPda!;
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [utf8.encode(_seedTreasury)],
      programId: programId,
    );
    _treasuryPda = result;
    return result;
  }

  /// Derive booster PDA: seeds = ["booster", buyer, total_boosters_sold (LE u64)]
  Future<Ed25519HDPublicKey> getBoosterPda(
      Ed25519HDPublicKey buyer,
      int totalBoostersSold,
      ) async {
    final countBytes = _encodeU64LE(totalBoostersSold);
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        utf8.encode(_seedBooster),
        buyer.bytes,
        countBytes,
      ],
      programId: programId,
    );
    return result;
  }

  // ============================================================
  // FETCH ACCOUNTS (READ)
  // ============================================================

  /// Fetch and deserialize the Store account
  Future<OnChainStore?> fetchStore() async {
    try {
      final storePda = await getStorePda();
      final accountInfo = await rpcClient.rpcClient.getAccountInfo(
        storePda.toBase58(),
        encoding: Encoding.base64,
      );

      if (accountInfo.value == null || accountInfo.value!.data == null) {
        debugPrint('Store account not found at ${storePda.toBase58()}');
        return null;
      }

      final accountData = accountInfo.value!.data;
      Uint8List data;
      if (accountData is BinaryAccountData) {
        data = Uint8List.fromList(accountData.data);
      } else {
        debugPrint('Unexpected account data type: ${accountData.runtimeType}');
        return null;
      }
      debugPrint('Store account data length: ${data.length} bytes');
      return _deserializeStore(data);
    } catch (e, stack) {
      debugPrint('Error fetching store: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Fetch active boosters for a wallet address
  Future<List<OnChainBooster>> fetchActiveBoosters(String ownerPubkey) async {
    try {
      final accounts = await rpcClient.rpcClient.getProgramAccounts(
        diggleMartProgramId,
        encoding: Encoding.base64,
        filters: [
          // Filter by 1-byte account discriminator at offset 0
          ProgramDataFilter.memcmpBase58(
            offset: 0,
            bytes: base58encode(Uint8List.fromList([_discBoosterAccount])),
          ),
          // Filter by owner pubkey at offset 1 (right after 1-byte discriminator)
          ProgramDataFilter.memcmpBase58(
            offset: 1,
            bytes: ownerPubkey,
          ),
        ],
      );

      final boosters = <OnChainBooster>[];
      for (final account in accounts) {
        try {
          final data = Uint8List.fromList(
              (account.account.data as BinaryAccountData).data);
          final booster = _deserializeBooster(data, account.pubkey);
          if (booster != null && !booster.isExpired) {
            boosters.add(booster);
          }
        } catch (e) {
          debugPrint('Error deserializing booster: $e');
        }
      }

      return boosters;
    } catch (e) {
      debugPrint('Error fetching boosters: $e');
      return [];
    }
  }

  // ============================================================
  // BUILD TRANSACTIONS
  // ============================================================

  /// Build a purchaseBooster transaction.
  ///
  /// [buyer] - the wallet paying for the booster (signer)
  /// [boosterType] - 0=XP, 1=Points, 2=Combo
  /// [durationSeconds] - how long the boost lasts
  /// [totalBoostersSold] - current count from store (for PDA derivation)
  ///
  /// Returns serialized transaction bytes ready for MWA signing.
  Future<Uint8List> buildPurchaseBoosterTx({
    required Ed25519HDPublicKey buyer,
    required int boosterType,
    required int durationSeconds,
    required int totalBoostersSold,
  }) async {
    final storePda = await getStorePda();
    final treasuryPda = await getTreasuryPda();
    final boosterPda = await getBoosterPda(buyer, totalBoostersSold);

    // Build instruction data: discriminator + boosterType(u8) + durationSeconds(i64 LE)
    final data = BytesBuilder();
    data.add(_discPurchaseBooster);
    data.addByte(boosterType);
    data.add(_encodeI64LE(durationSeconds));

    final instruction = Instruction(
      programId: programId,
      accounts: [
        AccountMeta.writeable(pubKey: buyer, isSigner: true),
        AccountMeta.writeable(pubKey: storePda, isSigner: false),
        AccountMeta.writeable(pubKey: boosterPda, isSigner: false),
        AccountMeta.writeable(pubKey: treasuryPda, isSigner: false),
        AccountMeta.readonly(
          pubKey: Ed25519HDPublicKey.fromBase58(systemProgramId),
          isSigner: false,
        ),
      ],
      data: ByteArray(data.toBytes()),
    );

    return _buildSerializedTransaction(instruction, buyer);
  }

  /// Build a purchasePointsPack transaction.
  ///
  /// [buyer] - the wallet paying (signer)
  /// [packType] - 0=small, 1=large
  ///
  /// Returns serialized transaction bytes ready for MWA signing.
  Future<Uint8List> buildPurchasePointsPackTx({
    required Ed25519HDPublicKey buyer,
    required int packType,
  }) async {
    final storePda = await getStorePda();
    final treasuryPda = await getTreasuryPda();

    // Build instruction data: discriminator + packType(u8)
    final data = BytesBuilder();
    data.add(_discPurchasePointsPack);
    data.addByte(packType);

    final instruction = Instruction(
      programId: programId,
      accounts: [
        AccountMeta.writeable(pubKey: buyer, isSigner: true),
        AccountMeta.writeable(pubKey: storePda, isSigner: false),
        AccountMeta.writeable(pubKey: treasuryPda, isSigner: false),
        AccountMeta.readonly(
          pubKey: Ed25519HDPublicKey.fromBase58(systemProgramId),
          isSigner: false,
        ),
      ],
      data: ByteArray(data.toBytes()),
    );

    return _buildSerializedTransaction(instruction, buyer);
  }

  // ============================================================
  // TRANSACTION HELPERS
  // ============================================================

  /// Build and serialize a transaction with a single instruction.
  /// Produces the standard Solana wire format:
  /// [compact-u16 sig_count] [64-byte placeholder sigs...] [message bytes]
  /// The wallet will replace placeholder signatures with real ones.
  Future<Uint8List> _buildSerializedTransaction(
      Instruction instruction,
      Ed25519HDPublicKey feePayer,
      ) async {
    // Get recent blockhash
    final blockhashResult =
    await rpcClient.rpcClient.getLatestBlockhash();
    final blockhash = blockhashResult.value.blockhash;

    debugPrint('Building tx with blockhash: $blockhash');

    // Compile message
    final message = Message(
      instructions: [instruction],
    );

    final compiledMessage = message.compile(
      recentBlockhash: blockhash,
      feePayer: feePayer,
    );

    final numSignatures = compiledMessage.requiredSignatureCount;
    debugPrint('Compiled message: $numSignatures required sigs, '
        '${compiledMessage.accountKeys.length} accounts');

    // Build wire format using SignedTx with placeholder signatures
    final tx = SignedTx(
      compiledMessage: compiledMessage,
      signatures: List.filled(
        numSignatures,
        Signature(List.filled(64, 0), publicKey: feePayer),
      ),
    );
    final txBytes = Uint8List.fromList(tx.toByteArray().toList());
    debugPrint('Serialized tx: ${txBytes.length} bytes');
    return txBytes;
  }

  /// Confirm a transaction signature
  Future<bool> confirmTransaction(String signature,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      try {
        final statuses = await rpcClient.rpcClient
            .getSignatureStatuses([signature]);
        if (statuses.value.isNotEmpty && statuses.value[0] != null) {
          final status = statuses.value[0]!;
          if (status.confirmationStatus == Commitment.confirmed ||
              status.confirmationStatus == Commitment.finalized) {
            return status.err == null;
          }
        }
      } catch (e) {
        // Ignore and retry
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    return false;
  }

  // ============================================================
  // DESERIALIZATION
  // ============================================================

  /// Deserialize Store account data (1-byte discriminator)
  OnChainStore? _deserializeStore(Uint8List data) {
    if (data.isEmpty) return null;

    // Verify 1-byte discriminator
    if (data[0] != _discStoreAccount) {
      debugPrint(
          'Store discriminator mismatch: got ${data[0]}, expected $_discStoreAccount');
      return null;
    }

    final reader = _BorshReader(data, 1); // Skip 1-byte discriminator

    final authority = reader.readPubkey();
    final treasury = reader.readPubkey();

    // StoreConfig
    final xpBoostPricePerHour = reader.readU64();
    final pointsBoostPricePerHour = reader.readU64();
    final comboBoostPricePerHour = reader.readU64();
    final xpBoostMultiplier = reader.readU16();
    final pointsBoostMultiplier = reader.readU16();
    final comboBoostMultiplier = reader.readU16();
    final pointsPackSmallPrice = reader.readU64();
    final pointsPackSmallAmount = reader.readU32();
    final pointsPackLargePrice = reader.readU64();
    final pointsPackLargeAmount = reader.readU32();
    final isActive = reader.readBool();

    final totalBoostersSold = reader.readU64();
    final totalSolCollected = reader.readU64();
    final bump = reader.readU8();

    return OnChainStore(
      authority: authority,
      treasury: treasury,
      config: OnChainStoreConfig(
        xpBoostPricePerHour: xpBoostPricePerHour,
        pointsBoostPricePerHour: pointsBoostPricePerHour,
        comboBoostPricePerHour: comboBoostPricePerHour,
        xpBoostMultiplier: xpBoostMultiplier,
        pointsBoostMultiplier: pointsBoostMultiplier,
        comboBoostMultiplier: comboBoostMultiplier,
        pointsPackSmallPrice: pointsPackSmallPrice,
        pointsPackSmallAmount: pointsPackSmallAmount,
        pointsPackLargePrice: pointsPackLargePrice,
        pointsPackLargeAmount: pointsPackLargeAmount,
        isActive: isActive,
      ),
      totalBoostersSold: totalBoostersSold,
      totalSolCollected: totalSolCollected,
      bump: bump,
    );
  }

  /// Deserialize BoosterAccount data (1-byte discriminator)
  OnChainBooster? _deserializeBooster(Uint8List data, String address) {
    if (data.isEmpty) return null;

    // Verify 1-byte discriminator
    if (data[0] != _discBoosterAccount) return null;

    final reader = _BorshReader(data, 1); // Skip 1-byte discriminator

    final owner = reader.readPubkey();
    final boosterType = reader.readU8();
    final multiplier = reader.readU16();
    final purchasedAt = reader.readI64();
    final expiresAt = reader.readI64();
    final isActive = reader.readBool();
    final pricePaid = reader.readU64();
    final bump = reader.readU8();

    return OnChainBooster(
      owner: owner,
      boosterType: boosterType,
      multiplier: multiplier,
      purchasedAt: purchasedAt,
      expiresAt: expiresAt,
      isActive: isActive,
      pricePaid: pricePaid,
      bump: bump,
      address: address,
    );
  }

  // ============================================================
  // BORSH ENCODING HELPERS
  // ============================================================

  /// Encode u64 as little-endian bytes
  static Uint8List _encodeU64LE(int value) {
    final bytes = ByteData(8);
    bytes.setUint64(0, value, Endian.little);
    return bytes.buffer.asUint8List();
  }

  /// Encode i64 as little-endian bytes
  static Uint8List _encodeI64LE(int value) {
    final bytes = ByteData(8);
    bytes.setInt64(0, value, Endian.little);
    return bytes.buffer.asUint8List();
  }
}

// ============================================================
// BASE58 HELPER
// ============================================================

/// Simple base58 encoder for filter values
String base58encode(Uint8List data) {
  const alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  if (data.isEmpty) return '';

  // Convert to BigInt
  var value = BigInt.zero;
  for (final byte in data) {
    value = (value << 8) | BigInt.from(byte);
  }

  // Convert to base58
  final result = StringBuffer();
  while (value > BigInt.zero) {
    final remainder = (value % BigInt.from(58)).toInt();
    value = value ~/ BigInt.from(58);
    result.write(alphabet[remainder]);
  }

  // Add leading zeros
  for (final byte in data) {
    if (byte == 0) {
      result.write(alphabet[0]);
    } else {
      break;
    }
  }

  return result.toString().split('').reversed.join();
}

// ============================================================
// BORSH READER (deserialization helper)
// ============================================================

class _BorshReader {
  final Uint8List data;
  int offset;

  _BorshReader(this.data, [this.offset = 0]);

  int readU8() {
    final value = data[offset];
    offset += 1;
    return value;
  }

  int readU16() {
    final bd = ByteData.sublistView(data, offset, offset + 2);
    final value = bd.getUint16(0, Endian.little);
    offset += 2;
    return value;
  }

  int readU32() {
    final bd = ByteData.sublistView(data, offset, offset + 4);
    final value = bd.getUint32(0, Endian.little);
    offset += 4;
    return value;
  }

  int readU64() {
    final bd = ByteData.sublistView(data, offset, offset + 8);
    final value = bd.getUint64(0, Endian.little);
    offset += 8;
    return value;
  }

  int readI64() {
    final bd = ByteData.sublistView(data, offset, offset + 8);
    final value = bd.getInt64(0, Endian.little);
    offset += 8;
    return value;
  }

  bool readBool() {
    final value = data[offset] != 0;
    offset += 1;
    return value;
  }

  /// Read a 32-byte public key as base58 string
  String readPubkey() {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 32));
    offset += 32;
    return Ed25519HDPublicKey(bytes).toBase58();
  }

  /// Read a Borsh-encoded string (4-byte length prefix + UTF-8 bytes)
  String readString() {
    final length = readU32();
    final bytes = data.sublist(offset, offset + length);
    offset += length;
    return utf8.decode(bytes);
  }
}