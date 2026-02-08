/// diggle_mart_client.dart
/// Client for the Diggle Mart on-chain Solana program.
///
/// Program ID: 6CQzNRRyMYox8G3oWLPJ8MwXthznqq6bMREdUwqKDNKA
///
/// Handles:
/// - PDA derivation for store, treasury, boosters, NFT collection
/// - Building instructions with Anchor discriminators + Borsh args
/// - Transaction construction for MWA signing
/// - Deserializing on-chain account data (Store, BoosterAccount, NftCollection)
///
/// Instructions supported:
/// - purchaseBooster(boosterType: u8, durationSeconds: i64)
/// - purchasePointsPack(packType: u8)
/// - mintNft()
///
/// Read operations:
/// - fetchStoreConfig()
/// - fetchActiveBoosters(ownerPubkey)
/// - fetchNftCollection()

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
    '6CQzNRRyMYox8G3oWLPJ8MwXthznqq6bMREdUwqKDNKA';

/// System program
const String systemProgramId = '11111111111111111111111111111111';

/// SPL Token program
const String tokenProgramId = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';

/// SPL Associated Token Account program
const String associatedTokenProgramId =
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';

/// Sysvar Rent
const String sysvarRentId = 'SysvarRent111111111111111111111111111111111';

/// PDA seeds
const String _seedStore = 'store';
const String _seedTreasury = 'treasury';
const String _seedBooster = 'booster';
const String _seedNftCollection = 'nft_collection';

// ============================================================
// ANCHOR INSTRUCTION DISCRIMINATORS (from IDL)
// ============================================================

final Uint8List _discPurchaseBooster =
Uint8List.fromList([251, 49, 11, 156, 68, 194, 21, 140]);

final Uint8List _discPurchasePointsPack =
Uint8List.fromList([125, 42, 47, 199, 26, 93, 227, 99]);

final Uint8List _discMintNft =
Uint8List.fromList([211, 57, 6, 167, 15, 219, 35, 251]);

// ============================================================
// ANCHOR ACCOUNT DISCRIMINATORS (from IDL)
// ============================================================

final Uint8List _discBoosterAccount =
Uint8List.fromList([76, 202, 210, 44, 136, 61, 228, 19]);

final Uint8List _discStoreAccount =
Uint8List.fromList([130, 48, 247, 244, 182, 191, 30, 26]);

final Uint8List _discNftCollectionAccount =
Uint8List.fromList([230, 92, 80, 190, 97, 0, 132, 22]);

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

/// On-chain NFT collection data
class OnChainNftCollection {
  final String authority;
  final String collectionMint;
  final int maxSupply;
  final int currentSupply;
  final int mintPrice; // lamports
  final String name;
  final String symbol;
  final String uri;
  final bool isActive;
  final int bump;

  const OnChainNftCollection({
    required this.authority,
    required this.collectionMint,
    required this.maxSupply,
    required this.currentSupply,
    required this.mintPrice,
    required this.name,
    required this.symbol,
    required this.uri,
    required this.isActive,
    required this.bump,
  });

  double get mintPriceSOL => mintPrice / 1e9;
  bool get isSoldOut => currentSupply >= maxSupply;
  int get remainingSupply => maxSupply - currentSupply;
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
  Ed25519HDPublicKey? _nftCollectionPda;

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

  /// Derive NFT collection PDA: seeds = ["nft_collection"]
  Future<Ed25519HDPublicKey> getNftCollectionPda() async {
    if (_nftCollectionPda != null) return _nftCollectionPda!;
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [utf8.encode(_seedNftCollection)],
      programId: programId,
    );
    _nftCollectionPda = result;
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

  /// Derive ATA (Associated Token Account)
  Future<Ed25519HDPublicKey> getAssociatedTokenAddress(
      Ed25519HDPublicKey owner,
      Ed25519HDPublicKey mint,
      ) async {
    final ataProgramId =
    Ed25519HDPublicKey.fromBase58(associatedTokenProgramId);
    final tokenProgram = Ed25519HDPublicKey.fromBase58(tokenProgramId);
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [owner.bytes, tokenProgram.bytes, mint.bytes],
      programId: ataProgramId,
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
        // Try to handle as raw list/string
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
      // Use getProgramAccounts with memcmp filters:
      // - Filter 1: Account discriminator (bytes 0-7)
      // - Filter 2: Owner pubkey (bytes 8-39)
      final ownerBytes =
          Ed25519HDPublicKey.fromBase58(ownerPubkey).bytes;

      final accounts = await rpcClient.rpcClient.getProgramAccounts(
        diggleMartProgramId,
        encoding: Encoding.base64,
        filters: [
          // Filter by account discriminator
          ProgramDataFilter.memcmpBase58(
            offset: 0,
            bytes: base58encode(_discBoosterAccount),
          ),
          // Filter by owner
          ProgramDataFilter.memcmpBase58(
            offset: 8,
            bytes: ownerPubkey,
          ),
        ],
      );

      final boosters = <OnChainBooster>[];
      for (final account in accounts) {
        try {
          final data = Uint8List.fromList((account.account.data as BinaryAccountData).data);
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

  /// Fetch NFT collection data
  Future<OnChainNftCollection?> fetchNftCollection() async {
    try {
      final pda = await getNftCollectionPda();
      final accountInfo = await rpcClient.rpcClient.getAccountInfo(
        pda.toBase58(),
        encoding: Encoding.base64,
      );

      if (accountInfo.value == null || accountInfo.value!.data == null) {
        debugPrint('NFT collection account not found');
        return null;
      }

      final data = Uint8List.fromList((accountInfo.value!.data as BinaryAccountData).data);
      return _deserializeNftCollection(data);
    } catch (e) {
      debugPrint('Error fetching NFT collection: $e');
      return null;
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

  /// Build a mintNft transaction.
  ///
  /// [minter] - the wallet minting (signer + payer)
  /// [nftMintPubkey] - the pre-created mint account pubkey
  ///
  /// NOTE: The nft mint account must be created in a preceding instruction
  /// within the same transaction. This method returns the mint_nft instruction.
  /// The caller is responsible for also including create_account + initialize_mint
  /// instructions for the nft mint keypair.
  ///
  /// Returns serialized transaction bytes ready for MWA signing.
  Future<Uint8List> buildMintNftTx({
    required Ed25519HDPublicKey minter,
    required Ed25519HDPublicKey nftMintPubkey,
  }) async {
    final nftCollectionPda = await getNftCollectionPda();
    final treasuryPda = await getTreasuryPda();
    final minterAta = await getAssociatedTokenAddress(minter, nftMintPubkey);

    final tokenProgram = Ed25519HDPublicKey.fromBase58(tokenProgramId);
    final ataProgramPubkey =
    Ed25519HDPublicKey.fromBase58(associatedTokenProgramId);
    final systemProgram = Ed25519HDPublicKey.fromBase58(systemProgramId);
    final rent = Ed25519HDPublicKey.fromBase58(sysvarRentId);

    // Instruction data: just the discriminator (no args)
    final data = BytesBuilder();
    data.add(_discMintNft);

    final instruction = Instruction(
      programId: programId,
      accounts: [
        AccountMeta.writeable(pubKey: minter, isSigner: true),
        AccountMeta.writeable(pubKey: nftCollectionPda, isSigner: false),
        AccountMeta.writeable(pubKey: nftMintPubkey, isSigner: false),
        AccountMeta.writeable(pubKey: minterAta, isSigner: false),
        AccountMeta.writeable(pubKey: treasuryPda, isSigner: false),
        AccountMeta.readonly(pubKey: tokenProgram, isSigner: false),
        AccountMeta.readonly(pubKey: ataProgramPubkey, isSigner: false),
        AccountMeta.readonly(pubKey: systemProgram, isSigner: false),
        AccountMeta.readonly(pubKey: rent, isSigner: false),
      ],
      data: ByteArray(data.toBytes()),
    );

    return _buildSerializedTransaction(instruction, minter);
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
    /* Build wire format manually for maximum compatibility
    final buffer = BytesBuilder();
    // 1. Compact-u16: number of signatures
    _writeCompactU16(buffer, numSignatures);

    // 2. Placeholder signatures (64 zero bytes each)
    for (int i = 0; i < numSignatures; i++) {
      buffer.add(Uint8List(64)); // 64 zero bytes
    }
    // 3. Serialized message bytes
    // CompiledMessage.data returns ByteArray with the serialized message
    final messageBytes = compiledMessage.toList();
    buffer.add(messageBytes);

    final txBytes = Uint8List.fromList(buffer.toBytes());
    debugPrint('Serialized tx: ${txBytes.length} bytes '
        '(sigs: ${numSignatures * 64 + 1}, msg: ${messageBytes.length})');
    return txBytes;*/

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

/* /// Write a compact-u16 value to a BytesBuilder.
  /// Solana uses a variable-length encoding for small integers.
  void _writeCompactU16(BytesBuilder buffer, int value) {
    if (value < 0x80) {
      buffer.addByte(value);
    } else if (value < 0x4000) {
      buffer.addByte((value & 0x7F) | 0x80);
      buffer.addByte(value >> 7);
    } else {
      buffer.addByte((value & 0x7F) | 0x80);
      buffer.addByte(((value >> 7) & 0x7F) | 0x80);
      buffer.addByte(value >> 14);
    }
  }
*/
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

  /// Deserialize Store account data (after discriminator)
  OnChainStore? _deserializeStore(Uint8List data) {
    if (data.length < 8) return null;

    // Verify discriminator
    for (int i = 0; i < 8; i++) {
      if (data[i] != _discStoreAccount[i]) {
        debugPrint('Store discriminator mismatch');
        return null;
      }
    }

    final reader = _BorshReader(data, 8); // Skip discriminator

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

  /// Deserialize BoosterAccount data
  OnChainBooster? _deserializeBooster(Uint8List data, String address) {
    if (data.length < 8) return null;

    for (int i = 0; i < 8; i++) {
      if (data[i] != _discBoosterAccount[i]) return null;
    }

    final reader = _BorshReader(data, 8);

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

  /// Deserialize NftCollection account data
  OnChainNftCollection? _deserializeNftCollection(Uint8List data) {
    if (data.length < 8) return null;

    for (int i = 0; i < 8; i++) {
      if (data[i] != _discNftCollectionAccount[i]) return null;
    }

    final reader = _BorshReader(data, 8);

    final authority = reader.readPubkey();
    final collectionMint = reader.readPubkey();
    final maxSupply = reader.readU32();
    final currentSupply = reader.readU32();
    final mintPrice = reader.readU64();
    final name = reader.readString();
    final symbol = reader.readString();
    final uri = reader.readString();
    final isActive = reader.readBool();
    final bump = reader.readU8();

    return OnChainNftCollection(
      authority: authority,
      collectionMint: collectionMint,
      maxSupply: maxSupply,
      currentSupply: currentSupply,
      mintPrice: mintPrice,
      name: name,
      symbol: symbol,
      uri: uri,
      isActive: isActive,
      bump: bump,
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