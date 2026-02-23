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
}
