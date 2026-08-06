// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline => 'DIG DEEP  •  MINE RICHES  •  GO FURTHER';

  @override
  String get mineDeepEarnRewards => 'Mine deep. Earn rewards.';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => 'NEW GAME';

  @override
  String get continueGame => 'CONTINUE';

  @override
  String get loadGame => 'LOAD GAME';

  @override
  String get account => 'ACCOUNT';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to Play';

  @override
  String comingSoon(String feature) {
    return '$feature coming soon!';
  }

  @override
  String get helpMiningTitle => '⛏️ Mining';

  @override
  String get helpMiningBody =>
      'Use the arrow controls to move your drill. Dig through dirt and rock to find valuable ores.';

  @override
  String get helpFuelTitle => '⛽ Fuel';

  @override
  String get helpFuelBody =>
      'Moving and digging consumes fuel. Return to the surface before running out!';

  @override
  String get helpHullTitle => '🛡️ Hull';

  @override
  String get helpHullBody =>
      'Falling too far damages your hull. Watch your HP!';

  @override
  String get helpSellingTitle => '💰 Selling';

  @override
  String get helpSellingBody =>
      'Return to the surface and visit the SHOP to sell your ore for cash.';

  @override
  String get helpUpgradesTitle => '🔧 Upgrades';

  @override
  String get helpUpgradesBody =>
      'Use cash to upgrade your fuel tank, cargo bay, and hull armor.';

  @override
  String get helpHazardsTitle => '⚠️ Hazards';

  @override
  String get helpHazardsBody =>
      'Watch out for lava (instant death) and gas pockets (damage)!';

  @override
  String get gotIt => 'GOT IT!';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => 'RESUME';

  @override
  String get saveGame => 'SAVE GAME';

  @override
  String get restart => 'RESTART';

  @override
  String get mainMenu => 'MAIN MENU';

  @override
  String savedToSlot(int slot) {
    return 'Saved to Slot $slot';
  }

  @override
  String get gameOver => 'GAME OVER';

  @override
  String depthReached(int depth) {
    return 'Depth reached: ${depth}m';
  }

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String get loadingDiggle => 'Loading Diggle...';

  @override
  String failedToLoadGame(String error) {
    return 'Failed to load game:\n$error';
  }

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get signInWithEmail => 'SIGN IN WITH EMAIL';

  @override
  String get signInWithWallet => 'SIGN IN WITH WALLET';

  @override
  String get playAsGuest => 'Play as Guest';

  @override
  String get or => 'OR';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get passwordMinChars => 'Password (min 6 characters)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get checkEmailConfirm => 'Check your email to confirm your account!';

  @override
  String get invalidEmailPassword => 'Invalid email or password';

  @override
  String get emailAlreadyRegistered =>
      'An account with this email already exists';

  @override
  String get pleaseConfirmEmail => 'Please confirm your email first';

  @override
  String get networkError => 'Network error — check your connection';

  @override
  String get tooManyAttempts => 'Too many attempts — try again later';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get pleaseFillFields => 'Please enter your email and password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get accountTitle => 'ACCOUNT';

  @override
  String get accountSubtitle => 'Profile, sign-in methods & stats';

  @override
  String get playerProfile => 'PLAYER PROFILE';

  @override
  String get enterDisplayName => 'Enter display name';

  @override
  String get anonymousMiner => 'Anonymous Miner';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get playingOffline => 'Playing offline';

  @override
  String get playerIdCopied => 'Player ID copied';

  @override
  String get signInMethods => 'SIGN-IN METHODS';

  @override
  String get signInMethodsSubtitle => 'How you can access your account';

  @override
  String get emailSignIn => 'Email sign-in';

  @override
  String get emailLabel => 'Email';

  @override
  String get solanaWallet => 'Solana Wallet';

  @override
  String get linkedWallet => 'Linked Wallet';

  @override
  String get addEmailAlt => 'Add email as an alternative way to sign in';

  @override
  String get linkForStore => 'Link for store purchases & NFTs';

  @override
  String get primary => 'PRIMARY';

  @override
  String get linked => 'LINKED';

  @override
  String get add => 'Add';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get unlink => 'Unlink';

  @override
  String get addEmailSignIn => 'Add Email Sign-In';

  @override
  String get addEmailSubtitle =>
      'Your wallet remains your primary sign-in. Email is an alternative.';

  @override
  String get addEmail => 'ADD EMAIL';

  @override
  String get checkEmailLink => 'Check your email to confirm the link!';

  @override
  String get emailSignInAdded => 'Email sign-in added!';

  @override
  String get walletConnectionCancelled => 'Wallet connection cancelled';

  @override
  String get couldNotGetWalletAddress => 'Could not get wallet address';

  @override
  String get signingCancelled => 'Signing was cancelled';

  @override
  String get walletLinked => 'Wallet linked! You can now sign in with it.';

  @override
  String get walletLinkFailed => 'Wallet link failed';

  @override
  String get unlinkWalletTitle => 'Unlink Wallet';

  @override
  String get unlinkWalletMessage =>
      'Your wallet will be removed from your account. You can link a different wallet afterwards.';

  @override
  String get cancel => 'Cancel';

  @override
  String get walletUnlinked => 'Wallet unlinked';

  @override
  String get unlinkFailed => 'Failed to unlink wallet';

  @override
  String get walletAdapter => 'WALLET ADAPTER';

  @override
  String get walletAdapterGuestSubtitle =>
      'Connect for store purchases this session';

  @override
  String get walletAdapterReconnectSubtitle => 'Reconnect to sign transactions';

  @override
  String get walletAdapterConnectSubtitle => 'Connect to use the store';

  @override
  String get network => 'Network';

  @override
  String get mainnet => 'Mainnet';

  @override
  String get devnet => 'Devnet';

  @override
  String connected(String network) {
    return 'Connected — $network';
  }

  @override
  String get loadingBalance => 'Loading balance...';

  @override
  String get airdropRequested => 'Airdrop requested!';

  @override
  String get airdropFailed => 'Airdrop failed';

  @override
  String get disconnectNote =>
      'Disconnecting ends the adapter session only. Your account stays linked — reconnect at any time.';

  @override
  String get disconnectAdapter => 'DISCONNECT ADAPTER';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectWallet => 'CONNECT WALLET';

  @override
  String get phantomTip => '💡 Use Phantom wallet for best devnet support';

  @override
  String get addressCopied => 'Address copied';

  @override
  String get lifetimeStats => 'LIFETIME STATS';

  @override
  String get statLevel => 'Level';

  @override
  String get statTotalXp => 'Total XP';

  @override
  String get statPoints => 'Points';

  @override
  String get statOresMined => 'Ores Mined';

  @override
  String get statMaxDepth => 'Max Depth';

  @override
  String get statPlayTime => 'Play Time';

  @override
  String get statPointsEarned => 'Points Earned';

  @override
  String get statPointsSpent => 'Points Spent';

  @override
  String get signedInEmail => 'Signed in with email';

  @override
  String get signedInWallet => 'Signed in with wallet';

  @override
  String get playingAsGuest => 'Playing as guest';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get guestSignOutWarning =>
      'Guest progress is only on this device. Signing out will remove access to your current saves. Are you sure?';

  @override
  String get emailAccount => 'Email Account';

  @override
  String get walletAccount => 'Wallet Account';

  @override
  String get guestLocalOnly => 'Guest — progress is local only';

  @override
  String get offline => 'Offline';

  @override
  String get newGameTitle => 'NEW GAME';

  @override
  String get loadGameTitle => 'LOAD GAME';

  @override
  String get newGameSubtitle => 'Choose a save slot for your new adventure';

  @override
  String get loadGameSubtitle => 'Select a save to continue your journey';

  @override
  String slotEmpty(int slot) {
    return 'Slot $slot — Empty';
  }

  @override
  String get tapToStart => 'Tap to start a new adventure';

  @override
  String get noSaveData => 'No save data';

  @override
  String slot(int slot) {
    return 'Slot $slot';
  }

  @override
  String savedAgo(String time) {
    return 'Saved $time';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return 'Delete Slot $slot?';
  }

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get delete => 'DELETE';

  @override
  String get overwriteSaveTitle => 'Overwrite Save?';

  @override
  String overwriteSaveMessage(int slot) {
    return 'Slot $slot already has a save. Starting a new game here will overwrite it.';
  }

  @override
  String get overwrite => 'OVERWRITE';

  @override
  String get noSaves => '(no saves)';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int min) {
    return '${min}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get hp => 'HP';

  @override
  String get fuel => 'FUEL';

  @override
  String get items => 'ITEMS: ';

  @override
  String get store => 'STORE';

  @override
  String get shop => 'SHOP';

  @override
  String depthMeter(int depth) {
    return '${depth}m';
  }

  @override
  String get miningSupplyCo => 'MINING SUPPLY CO.';

  @override
  String get cash => 'Cash';

  @override
  String get hull => 'Hull';

  @override
  String get fuelLabel => 'Fuel';

  @override
  String get cargo => 'Cargo';

  @override
  String get services => 'Services';

  @override
  String get upgrades => 'Upgrades';

  @override
  String get itemsTab => 'Items';

  @override
  String get sellOre => 'SELL ORE';

  @override
  String get noOreToSell => 'No ore to sell';

  @override
  String get totalValue => 'Total Value:';

  @override
  String get sellAll => 'SELL ALL';

  @override
  String get refuel => 'REFUEL';

  @override
  String refuelCost(int cost) {
    return 'REFUEL (\$$cost)';
  }

  @override
  String get tankFull => 'Tank is full!';

  @override
  String get repair => 'REPAIR';

  @override
  String repairHullCost(int cost) {
    return 'REPAIR HULL (\$$cost)';
  }

  @override
  String get hullFullyRepaired => 'Hull is fully repaired!';

  @override
  String inventorySlots(int used, int max) {
    return 'Inventory: $used/$max slots';
  }

  @override
  String upgradeCost(int cost) {
    return 'UPGRADE - \$$cost';
  }

  @override
  String get maxed => 'MAXED';

  @override
  String get drillBit => 'Drill Bit';

  @override
  String get engine => 'Engine';

  @override
  String get cooling => 'Cooling';

  @override
  String get fuelTank => 'Fuel Tank';

  @override
  String get cargoBay => 'Cargo Bay';

  @override
  String get hullArmor => 'Hull Armor';

  @override
  String capacityValue(int value) {
    return 'Capacity: $value';
  }

  @override
  String speedPercent(int percent) {
    return 'Speed: $percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return 'Fuel savings: $percent%';
  }

  @override
  String get noFuelSavings => 'No fuel savings';

  @override
  String maxHpValue(int value) {
    return 'Max HP: $value';
  }

  @override
  String get returnToMining => 'RETURN TO MINING';

  @override
  String soldOreFor(int amount) {
    return 'Sold ore for \$$amount!';
  }

  @override
  String get tankRefueled => 'Tank refueled!';

  @override
  String get fuelTankUpgraded => 'Fuel tank upgraded!';

  @override
  String get cargoBayUpgraded => 'Cargo bay upgraded!';

  @override
  String get hullRepaired => 'Hull repaired!';

  @override
  String get hullArmorUpgraded => 'Hull armor upgraded!';

  @override
  String get drillBitUpgraded => 'Drill bit upgraded!';

  @override
  String get engineUpgraded => 'Engine upgraded!';

  @override
  String get coolingUpgraded => 'Cooling system upgraded!';

  @override
  String purchased(String item) {
    return 'Purchased $item!';
  }

  @override
  String get premiumStore => 'PREMIUM STORE';

  @override
  String get onChainLoaded => 'On-chain prices loaded';

  @override
  String get usingDefaultPrices => 'Using default prices';

  @override
  String get level => 'Level';

  @override
  String get xp => 'XP';

  @override
  String get points => 'Points';

  @override
  String get activeBoosts => 'ACTIVE BOOSTS';

  @override
  String get permanent => 'Permanent';

  @override
  String get pointsTab => 'Points';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => 'Wallet Required';

  @override
  String get walletRequiredMessage =>
      'Connect your Solana wallet to access premium items.\nAll purchases are on-chain transactions.';

  @override
  String get storePricesUnavailable => 'Store Prices Unavailable';

  @override
  String get storePricesUnavailableMessage =>
      'Unable to load on-chain pricing.\nPlease check your connection and try again.';

  @override
  String get retry => 'RETRY';

  @override
  String get buy => 'BUY';

  @override
  String get notEnoughPoints => 'Not enough points!';

  @override
  String activated(String item) {
    return '$item activated!';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$item purchased! TX: $tx...';
  }

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get closeStore => 'CLOSE STORE';

  @override
  String get diggleDrillMachine => 'DIGGLE DRILL MACHINE';

  @override
  String get permanentBoostNft => 'Permanent boost NFT — one per player';

  @override
  String get holderBenefits => 'HOLDER BENEFITS';

  @override
  String get permanentXpBoost => 'Permanent XP Boost';

  @override
  String get permanentPointsBoost => 'Permanent Points Boost';

  @override
  String get limitedSupply => 'Limited Supply';

  @override
  String get soldOut => 'SOLD OUT';

  @override
  String get allNftsMinted => 'All Diggle Drill NFTs have been minted!';

  @override
  String get mintOpensSoon => 'MINT OPENS SOON';

  @override
  String startsAt(String date) {
    return 'Starts: $date';
  }

  @override
  String get checkBackLater => 'Check back later!';

  @override
  String get mintNft => 'MINT NFT';

  @override
  String mintCost(String cost) {
    return 'MINT — $cost SOL';
  }

  @override
  String get nftMinted => 'NFT Minted! 🎉';

  @override
  String get refresh => 'Refresh';

  @override
  String get boostsActive => 'Your boosts are permanently active!';

  @override
  String get mintStatusPreparing => 'Preparing transaction...';

  @override
  String get mintStatusApprove => 'Approve in your wallet app...';

  @override
  String get mintStatusSending => 'Sending transaction...';

  @override
  String get mintStatusConfirming => 'Confirming on-chain...';

  @override
  String get mintStatusSuccess => 'Minted successfully!';

  @override
  String get mintStatusError => 'Mint failed';

  @override
  String xpLabel(int current, int next) {
    return 'XP: $current/$next';
  }

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsSubtitle => 'Game preferences';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose your preferred language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateRequiredMessage =>
      'This version of Diggle is no longer supported. Please update to continue playing.';

  @override
  String get currentVersionLabel => 'Current';

  @override
  String get latestVersionLabel => 'Latest';

  @override
  String get requiredVersionLabel => 'Required';

  @override
  String get updateNow => 'UPDATE NOW';

  @override
  String get updateLater => 'Later';

  @override
  String get updateOpenStoreFailed =>
      'Could not open the dApp Store. Please update manually.';

  @override
  String get light => 'Light';

  @override
  String get lightUpgraded => 'Light system upgraded!';

  @override
  String revealRadiusValue(int radius) {
    return 'Reveal: $radius tiles';
  }

  @override
  String get questsTitle => 'QUESTS';

  @override
  String get questsSubtitle => 'Complete quests to earn XP & points';

  @override
  String get questsDailyTab => 'Daily';

  @override
  String get questsSocialTab => 'Social';

  @override
  String get questsClaim => 'CLAIM';

  @override
  String get questsClaimed => '✓ Claimed';

  @override
  String get questsGo => 'GO';

  @override
  String get questsClose => 'CLOSE';

  @override
  String get questsNoDailyQuests => 'No daily quests available';

  @override
  String get questsSocialInfo =>
      'Complete social actions to earn one-time rewards. Tap GO to open the link.';

  @override
  String get quests => 'QUESTS';

  @override
  String questMineOreTitle(int count) {
    return 'Mine $count Ores';
  }

  @override
  String questMineOreDesc(int count) {
    return 'Mine $count ore tiles in a single day';
  }

  @override
  String questReachDepthTitle(int depth) {
    return 'Reach ${depth}m Depth';
  }

  @override
  String questReachDepthDesc(int depth) {
    return 'Reach a depth of ${depth}m or more';
  }

  @override
  String questSellOreTitle(int value) {
    return 'Sell \$$value Worth';
  }

  @override
  String questSellOreDesc(int value) {
    return 'Sell ore worth a total of \$$value';
  }

  @override
  String questRepairTitle(int amount) {
    return 'Repair $amount HP';
  }

  @override
  String questRepairDesc(int amount) {
    return 'Repair a total of $amount hull HP';
  }

  @override
  String questUseItemsTitle(int count) {
    return 'Use $count Items';
  }

  @override
  String questUseItemsDesc(int count) {
    return 'Use $count items from your inventory';
  }

  @override
  String get questFollowTwitterTitle => 'Follow on X';

  @override
  String get questFollowTwitterDesc => 'Follow @DiggleGame on X (Twitter)';

  @override
  String get questJoinDiscordTitle => 'Join Discord';

  @override
  String get questJoinDiscordDesc => 'Join the Diggle Discord community';

  @override
  String get questPostTweetTitle => 'Share on X';

  @override
  String get questPostTweetDesc => 'Post a tweet about Diggle';

  @override
  String get questVerifyButton => 'Verify';

  @override
  String get questPasteTweetUrl => 'Paste your tweet URL here';

  @override
  String get questVerifying => 'Verifying...';

  @override
  String get questVerified => 'Quest verified and completed!';

  @override
  String get questVerificationFailed => 'Could not verify. Please try again.';

  @override
  String get loginStreak => 'Login Streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get streakClaimedToday => 'Claimed today';

  @override
  String get streakPlayToday => 'Play today to keep it going';

  @override
  String get streakStartToday => 'Play today to start a streak';

  @override
  String streakNextReward(int xp, int points) {
    return 'Next: +$xp XP, +$points pts';
  }

  @override
  String get streakJackpotReached => 'Jackpot rung — max daily reward';

  @override
  String streakToJackpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to the jackpot',
      one: '1 day to the jackpot',
    );
    return '$_temp0';
  }

  @override
  String get menuWeeklyChallenge => 'Weekly Challenge';

  @override
  String get menuLeaderboard => 'Leaderboard';

  @override
  String get menuHangar => 'Hangar';

  @override
  String get museumTitle => 'MUSEUM';

  @override
  String get achievementsTab => 'ACHIEVEMENTS';

  @override
  String get leaderboardHeading => '🏆 LEADERBOARD';

  @override
  String get leaderboardEmpty => 'No entries yet.\nBe the first on the board!';

  @override
  String get hangarHeading => '🛠️ HANGAR';

  @override
  String hangarMachineCount(int count) {
    return '$count Diggle Machines in this wallet — one can be equipped at a time.';
  }

  @override
  String get hangarSeekerVerified => 'SEEKER GENESIS VERIFIED';

  @override
  String get hangarSeekerBlurb =>
      'Solana Mobile pioneer — +5% XP & Points, always on.';

  @override
  String get hangarSealedCrate => 'SEALED CRATE';

  @override
  String get hangarSealedBlurb =>
      'This machine hasn\'t been revealed yet. Until then it grants the flat +25% XP & Points holder boost.\n\nAfter the reveal, its five gear traits (Hull, Thruster, Fuel Tank, Drill, Cargo Hold) become equippable with rarity-based stat bonuses. Tap refresh after reveal day!';

  @override
  String get hangarEquipped =>
      '✅ Equipped — bonuses active in normal runs.\nWeekly Challenge uses a standardized loadout (no gear).';

  @override
  String get quantity => 'Quantity';

  @override
  String get airdrop => 'Airdrop';

  @override
  String get questsWeeklyTab => 'Weekly';

  @override
  String get questsWeeklyInfo =>
      'Big challenges, big rewards. Resets every Monday (UTC).';

  @override
  String questsNotEnoughPoints(int cost) {
    return 'Not enough points ($cost needed). Grab a points pack in the store!';
  }

  @override
  String get questJoinDiscordServer => 'Join Discord Server';

  @override
  String get questCheckingMembership => 'Checking membership...';

  @override
  String get questVerifyMembership => 'Verify Membership';

  @override
  String get questDiscordHint =>
      'Join the server first, then tap Verify to confirm with Discord';

  @override
  String get questPostOnX => 'Post on X';

  @override
  String get questTweetHint =>
      'Post the tweet above, then paste the URL to verify';

  @override
  String get questDiscordUnavailable =>
      'Discord verification not available. Try again later.';

  @override
  String get questDiscordOpenFailed =>
      'Could not open Discord. Please try again.';

  @override
  String get questDiscordVerified => 'Discord membership verified! 🎉';

  @override
  String get questDiscordVerifyFailed =>
      'Could not verify membership. Make sure you joined the server and authorized Discord.';

  @override
  String get signNewContract => 'Sign New Contract';

  @override
  String get corporateContract => '⭐ Corporate Contract';

  @override
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  ) {
    return 'Sign Contract #$level?\n\nRESETS: world, cash, ship upgrades\nKEEPS: XP, points, NFTs, achievements, collection\n\nPERMANENT PERKS:\n• +$sellBonus% ore sell price\n• \$$startCash starting cash + starter kit\n$hardcore• $badge leaderboard badge';
  }

  @override
  String get prestigeHardcoreLine =>
      '• Hardcore seams: richer ore, deadlier hazards\n';

  @override
  String get notYet => 'Not yet';

  @override
  String get signContract => 'Sign Contract';

  @override
  String get recoveryFailedPoints => 'Recovery failed — not enough points';

  @override
  String emergencyRecoveryCost(int cost) {
    return 'Emergency Recovery ($cost pts)';
  }

  @override
  String emergencyRecoveryNeed(int cost) {
    return 'Need $cost pts — open Store';
  }

  @override
  String keepsCargo(int value) {
    return 'Keeps your \$$value cargo!';
  }

  @override
  String titleUnlocked(String title) {
    return 'Title unlocked: $title';
  }

  @override
  String get titleProspector => 'Prospector';

  @override
  String get titleExcavator => 'Excavator';

  @override
  String get titleDemolitionist => 'Demolitionist';

  @override
  String get titleDeepMiner => 'Deep Miner';

  @override
  String get titleVoidwalker => 'Voidwalker';

  @override
  String get titleCoreBreaker => 'Core Breaker';

  @override
  String get titleDiggleLegend => 'Diggle Legend';

  @override
  String get artifactTsFossilFern => 'Fern Fossil';

  @override
  String get artifactTsFossilFernDesc =>
      'A perfect imprint of a prehistoric fern.';

  @override
  String get artifactTsOldBoot => 'Prospector\'s Boot';

  @override
  String get artifactTsOldBootDesc => 'Somebody dug here long before you.';

  @override
  String get artifactTsClayJar => 'Clay Jar';

  @override
  String get artifactTsClayJarDesc => 'Ancient storage, miraculously unbroken.';

  @override
  String get artifactTsArrowhead => 'Flint Arrowhead';

  @override
  String get artifactTsArrowheadDesc =>
      'Knapped by hands ten thousand years gone.';

  @override
  String get artifactTsCoinHoard => 'Coin Hoard';

  @override
  String get artifactTsCoinHoardDesc => 'Corroded coins from a forgotten mint.';

  @override
  String get artifactPfMammothTusk => 'Mammoth Tusk';

  @override
  String get artifactPfMammothTuskDesc => 'Curved ivory, cold to the touch.';

  @override
  String get artifactPfIceLens => 'Ice Lens';

  @override
  String get artifactPfIceLensDesc => 'A naturally formed lens of ancient ice.';

  @override
  String get artifactPfFrozenFlower => 'Frozen Flower';

  @override
  String get artifactPfFrozenFlowerDesc =>
      'A bloom preserved mid-blossom for millennia.';

  @override
  String get artifactPfSledRunner => 'Sled Runner';

  @override
  String get artifactPfSledRunnerDesc =>
      'Part of an expedition that never returned.';

  @override
  String get artifactPfAmberInsect => 'Amber Insect';

  @override
  String get artifactPfAmberInsectDesc =>
      'A tiny passenger frozen in golden resin.';

  @override
  String get artifactCcSingingGeode => 'Singing Geode';

  @override
  String get artifactCcSingingGeodeDesc => 'It hums a note just below hearing.';

  @override
  String get artifactCcPrismCore => 'Prism Core';

  @override
  String get artifactCcPrismCoreDesc =>
      'Splits lamplight into colors with no names.';

  @override
  String get artifactCcPetrifiedEye => 'Petrified Eye';

  @override
  String get artifactCcPetrifiedEyeDesc =>
      'You are certain it was watching you.';

  @override
  String get artifactCcResonantShard => 'Resonant Shard';

  @override
  String get artifactCcResonantShardDesc =>
      'Vibrates when other crystals are near.';

  @override
  String get artifactCcHollowBell => 'Hollow Bell';

  @override
  String get artifactCcHollowBellDesc =>
      'A crystal bell that rings in silence.';

  @override
  String get artifactMcObsidianBlade => 'Obsidian Blade';

  @override
  String get artifactMcObsidianBladeDesc =>
      'Volcanic glass, sharper than any drill.';

  @override
  String get artifactMcFireOpal => 'Fire Opal';

  @override
  String get artifactMcFireOpalDesc => 'A stone with a living ember inside.';

  @override
  String get artifactMcBasaltIdol => 'Basalt Idol';

  @override
  String get artifactMcBasaltIdolDesc =>
      'Carved by something that liked the heat.';

  @override
  String get artifactMcMeteorFragment => 'Meteor Fragment';

  @override
  String get artifactMcMeteorFragmentDesc =>
      'It fell from above and sank this deep.';

  @override
  String get artifactMcHeartOfCore => 'Heart of the Core';

  @override
  String get artifactMcHeartOfCoreDesc => 'Still warm. Still beating?';

  @override
  String get achievementOre10 => 'First Haul';

  @override
  String get achievementOre10Desc => 'Mine 10 ores';

  @override
  String get achievementOre100 => 'Ore Hound';

  @override
  String get achievementOre100Desc => 'Mine 100 ores';

  @override
  String get achievementOre500 => 'Vein Chaser';

  @override
  String get achievementOre500Desc => 'Mine 500 ores';

  @override
  String get achievementOre2000 => 'Strip Miner';

  @override
  String get achievementOre2000Desc => 'Mine 2,000 ores';

  @override
  String get achievementOre10000 => 'Planet Eater';

  @override
  String get achievementOre10000Desc => 'Mine 10,000 ores';

  @override
  String get achievementDepth50 => 'Below the Roots';

  @override
  String get achievementDepth50Desc => 'Reach depth 50';

  @override
  String get achievementDepth120 => 'Into the Frost';

  @override
  String get achievementDepth120Desc => 'Reach the Permafrost (depth 120)';

  @override
  String get achievementDepth240 => 'Crystal Gazer';

  @override
  String get achievementDepth240Desc => 'Reach the Crystal Caverns (depth 240)';

  @override
  String get achievementDepth360 => 'Magma Diver';

  @override
  String get achievementDepth360Desc => 'Reach the Magma Core (depth 360)';

  @override
  String get achievementDepth445 => 'Rock Bottom';

  @override
  String get achievementDepth445Desc => 'Touch the world floor (depth 445)';

  @override
  String get achievementCash1k => 'Pocket Money';

  @override
  String get achievementCash1kDesc => 'Earn \\\$1,000 lifetime';

  @override
  String get achievementCash25k => 'Business Miner';

  @override
  String get achievementCash25kDesc => 'Earn \\\$25,000 lifetime';

  @override
  String get achievementCash250k => 'Ore Baron';

  @override
  String get achievementCash250kDesc => 'Earn \\\$250,000 lifetime';

  @override
  String get achievementCash1m => 'Diggle Tycoon';

  @override
  String get achievementCash1mDesc => 'Earn \\\$1,000,000 lifetime';

  @override
  String get achievementLevel5 => 'Getting Serious';

  @override
  String get achievementLevel5Desc => 'Reach level 5';

  @override
  String get achievementLevel10 => 'Double Digits';

  @override
  String get achievementLevel10Desc => 'Reach level 10';

  @override
  String get achievementLevel18 => 'Deep Veteran';

  @override
  String get achievementLevel18Desc => 'Reach level 18';

  @override
  String get achievementLevel25 => 'Maximum Diggle';

  @override
  String get achievementLevel25Desc => 'Reach level 25';

  @override
  String get achievementArtifact1 => 'Amateur Archaeologist';

  @override
  String get achievementArtifact1Desc => 'Find your first artifact';

  @override
  String get achievementArtifact10 => 'Museum Donor';

  @override
  String get achievementArtifact10Desc => 'Find 10 artifacts';

  @override
  String get achievementArtifact20 => 'Master Curator';

  @override
  String get achievementArtifact20Desc => 'Complete the full collection';

  @override
  String get achievementBlast5 => 'Fire in the Hole';

  @override
  String get achievementBlast5Desc => 'Detonate 5 explosives';

  @override
  String get achievementBlast50 => 'Controlled Demolition';

  @override
  String get achievementBlast50Desc => 'Detonate 50 explosives';

  @override
  String get achievementSales10 => 'Regular Customer';

  @override
  String get achievementSales10Desc => 'Sell ore 10 times';

  @override
  String get achievementSales100 => 'Market Mover';

  @override
  String get achievementSales100Desc => 'Sell ore 100 times';

  @override
  String get achievementDeath1 => 'Occupational Hazard';

  @override
  String get achievementDeath1Desc => 'Lose your first drill';

  @override
  String get achievementDeath25 => 'Never Say Die';

  @override
  String get achievementDeath25Desc => 'Lose 25 drills and keep digging';

  @override
  String get itemBackupFuel => '⛽';

  @override
  String get itemRepairBot => '🔧';

  @override
  String get itemDynamite => '🧨';

  @override
  String get itemC4 => '💣';

  @override
  String get itemSpaceRift => '🌀';

  @override
  String get itemOreScanner => '📡';

  @override
  String get itemHeatShield => '🛡️';

  @override
  String get tileEmpty => 'Empty';

  @override
  String get tileDirt => 'Dirt';

  @override
  String get tileRock => 'Rock';

  @override
  String get tileCoal => 'Coal';

  @override
  String get tileCopper => 'Copper';

  @override
  String get tileSilver => 'Silver';

  @override
  String get tileGold => 'Gold';

  @override
  String get tileSapphire => 'Sapphire';

  @override
  String get tileEmerald => 'Emerald';

  @override
  String get tileRuby => 'Ruby';

  @override
  String get tileDiamond => 'Diamond';

  @override
  String get tileLava => 'Lava';

  @override
  String get tileGas => 'Gas Pocket';

  @override
  String get tileFrozenDirt => 'Frozen Dirt';

  @override
  String get tileMagmaRock => 'Magma Rock';

  @override
  String get tileCrystalOre => 'Crystal';

  @override
  String get tileUnstableRock => 'Unstable Rock';

  @override
  String get tileLootCrate => 'Supply Crate';

  @override
  String get tileArtifact => 'Artifact';

  @override
  String get tileBedrock => 'Bedrock';

  @override
  String questUseExplosivesTitle(int count) {
    return 'Detonate $count explosives';
  }

  @override
  String questUseExplosivesDesc(int count) {
    return 'Use dynamite or C4 $count times';
  }

  @override
  String questFindArtifactTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find $count artifacts',
      one: 'Find an artifact',
    );
    return '$_temp0';
  }

  @override
  String get questFindArtifactDesc => 'Dig up buried artifacts in ruins';

  @override
  String questOpenCrateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Open $count supply crates',
      one: 'Open a supply crate',
    );
    return '$_temp0';
  }

  @override
  String get questOpenCrateDesc =>
      'Crack open supply crates in abandoned shafts';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';
}
