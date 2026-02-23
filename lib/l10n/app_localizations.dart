import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Diggle'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'DIG DEEP  •  MINE RICHES  •  GO FURTHER'**
  String get tagline;

  /// No description provided for @mineDeepEarnRewards.
  ///
  /// In en, this message translates to:
  /// **'Mine deep. Earn rewards.'**
  String get mineDeepEarnRewards;

  /// No description provided for @pyroLabs.
  ///
  /// In en, this message translates to:
  /// **'PyroLabs'**
  String get pyroLabs;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'v0.1.0-alpha'**
  String get version;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'NEW GAME'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueGame;

  /// No description provided for @loadGame.
  ///
  /// In en, this message translates to:
  /// **'LOAD GAME'**
  String get loadGame;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon!'**
  String comingSoon(String feature);

  /// No description provided for @helpMiningTitle.
  ///
  /// In en, this message translates to:
  /// **'⛏️ Mining'**
  String get helpMiningTitle;

  /// No description provided for @helpMiningBody.
  ///
  /// In en, this message translates to:
  /// **'Use the arrow controls to move your drill. Dig through dirt and rock to find valuable ores.'**
  String get helpMiningBody;

  /// No description provided for @helpFuelTitle.
  ///
  /// In en, this message translates to:
  /// **'⛽ Fuel'**
  String get helpFuelTitle;

  /// No description provided for @helpFuelBody.
  ///
  /// In en, this message translates to:
  /// **'Moving and digging consumes fuel. Return to the surface before running out!'**
  String get helpFuelBody;

  /// No description provided for @helpHullTitle.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Hull'**
  String get helpHullTitle;

  /// No description provided for @helpHullBody.
  ///
  /// In en, this message translates to:
  /// **'Falling too far damages your hull. Watch your HP!'**
  String get helpHullBody;

  /// No description provided for @helpSellingTitle.
  ///
  /// In en, this message translates to:
  /// **'💰 Selling'**
  String get helpSellingTitle;

  /// No description provided for @helpSellingBody.
  ///
  /// In en, this message translates to:
  /// **'Return to the surface and visit the SHOP to sell your ore for cash.'**
  String get helpSellingBody;

  /// No description provided for @helpUpgradesTitle.
  ///
  /// In en, this message translates to:
  /// **'🔧 Upgrades'**
  String get helpUpgradesTitle;

  /// No description provided for @helpUpgradesBody.
  ///
  /// In en, this message translates to:
  /// **'Use cash to upgrade your fuel tank, cargo bay, and hull armor.'**
  String get helpUpgradesBody;

  /// No description provided for @helpHazardsTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Hazards'**
  String get helpHazardsTitle;

  /// No description provided for @helpHazardsBody.
  ///
  /// In en, this message translates to:
  /// **'Watch out for lava (instant death) and gas pockets (damage)!'**
  String get helpHazardsBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT!'**
  String get gotIt;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// No description provided for @saveGame.
  ///
  /// In en, this message translates to:
  /// **'SAVE GAME'**
  String get saveGame;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'RESTART'**
  String get restart;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'MAIN MENU'**
  String get mainMenu;

  /// No description provided for @savedToSlot.
  ///
  /// In en, this message translates to:
  /// **'Saved to Slot {slot}'**
  String savedToSlot(int slot);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @depthReached.
  ///
  /// In en, this message translates to:
  /// **'Depth reached: {depth}m'**
  String depthReached(int depth);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @loadingDiggle.
  ///
  /// In en, this message translates to:
  /// **'Loading Diggle...'**
  String get loadingDiggle;

  /// No description provided for @failedToLoadGame.
  ///
  /// In en, this message translates to:
  /// **'Failed to load game:\n{error}'**
  String failedToLoadGame(String error);

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH EMAIL'**
  String get signInWithEmail;

  /// No description provided for @signInWithWallet.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH WALLET'**
  String get signInWithWallet;

  /// No description provided for @playAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get playAsGuest;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 characters)'**
  String get passwordMinChars;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccount;

  /// No description provided for @checkEmailConfirm.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account!'**
  String get checkEmailConfirm;

  /// No description provided for @invalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailPassword;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get emailAlreadyRegistered;

  /// No description provided for @pleaseConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first'**
  String get pleaseConfirmEmail;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error — check your connection'**
  String get networkError;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts — try again later'**
  String get tooManyAttempts;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pleaseFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password'**
  String get pleaseFillFields;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNoMatch;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, sign-in methods & stats'**
  String get accountSubtitle;

  /// No description provided for @playerProfile.
  ///
  /// In en, this message translates to:
  /// **'PLAYER PROFILE'**
  String get playerProfile;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter display name'**
  String get enterDisplayName;

  /// No description provided for @anonymousMiner.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Miner'**
  String get anonymousMiner;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @playingOffline.
  ///
  /// In en, this message translates to:
  /// **'Playing offline'**
  String get playingOffline;

  /// No description provided for @playerIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Player ID copied'**
  String get playerIdCopied;

  /// No description provided for @signInMethods.
  ///
  /// In en, this message translates to:
  /// **'SIGN-IN METHODS'**
  String get signInMethods;

  /// No description provided for @signInMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How you can access your account'**
  String get signInMethodsSubtitle;

  /// No description provided for @emailSignIn.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in'**
  String get emailSignIn;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @solanaWallet.
  ///
  /// In en, this message translates to:
  /// **'Solana Wallet'**
  String get solanaWallet;

  /// No description provided for @linkedWallet.
  ///
  /// In en, this message translates to:
  /// **'Linked Wallet'**
  String get linkedWallet;

  /// No description provided for @addEmailAlt.
  ///
  /// In en, this message translates to:
  /// **'Add email as an alternative way to sign in'**
  String get addEmailAlt;

  /// No description provided for @linkForStore.
  ///
  /// In en, this message translates to:
  /// **'Link for store purchases & NFTs'**
  String get linkForStore;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get primary;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'LINKED'**
  String get linked;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @addEmailSignIn.
  ///
  /// In en, this message translates to:
  /// **'Add Email Sign-In'**
  String get addEmailSignIn;

  /// No description provided for @addEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet remains your primary sign-in. Email is an alternative.'**
  String get addEmailSubtitle;

  /// No description provided for @addEmail.
  ///
  /// In en, this message translates to:
  /// **'ADD EMAIL'**
  String get addEmail;

  /// No description provided for @checkEmailLink.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm the link!'**
  String get checkEmailLink;

  /// No description provided for @emailSignInAdded.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in added!'**
  String get emailSignInAdded;

  /// No description provided for @walletConnectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Wallet connection cancelled'**
  String get walletConnectionCancelled;

  /// No description provided for @couldNotGetWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not get wallet address'**
  String get couldNotGetWalletAddress;

  /// No description provided for @signingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Signing was cancelled'**
  String get signingCancelled;

  /// No description provided for @walletLinked.
  ///
  /// In en, this message translates to:
  /// **'Wallet linked! You can now sign in with it.'**
  String get walletLinked;

  /// No description provided for @walletLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Wallet link failed'**
  String get walletLinkFailed;

  /// No description provided for @unlinkWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Wallet'**
  String get unlinkWalletTitle;

  /// No description provided for @unlinkWalletMessage.
  ///
  /// In en, this message translates to:
  /// **'Your wallet will be removed from your account. You can link a different wallet afterwards.'**
  String get unlinkWalletMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @walletUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Wallet unlinked'**
  String get walletUnlinked;

  /// No description provided for @unlinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink wallet'**
  String get unlinkFailed;

  /// No description provided for @walletAdapter.
  ///
  /// In en, this message translates to:
  /// **'WALLET ADAPTER'**
  String get walletAdapter;

  /// No description provided for @walletAdapterGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect for store purchases this session'**
  String get walletAdapterGuestSubtitle;

  /// No description provided for @walletAdapterReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to sign transactions'**
  String get walletAdapterReconnectSubtitle;

  /// No description provided for @walletAdapterConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to use the store'**
  String get walletAdapterConnectSubtitle;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @mainnet.
  ///
  /// In en, this message translates to:
  /// **'Mainnet'**
  String get mainnet;

  /// No description provided for @devnet.
  ///
  /// In en, this message translates to:
  /// **'Devnet'**
  String get devnet;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected — {network}'**
  String connected(String network);

  /// No description provided for @loadingBalance.
  ///
  /// In en, this message translates to:
  /// **'Loading balance...'**
  String get loadingBalance;

  /// No description provided for @airdropRequested.
  ///
  /// In en, this message translates to:
  /// **'Airdrop requested!'**
  String get airdropRequested;

  /// No description provided for @airdropFailed.
  ///
  /// In en, this message translates to:
  /// **'Airdrop failed'**
  String get airdropFailed;

  /// No description provided for @disconnectNote.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting ends the adapter session only. Your account stays linked — reconnect at any time.'**
  String get disconnectNote;

  /// No description provided for @disconnectAdapter.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT ADAPTER'**
  String get disconnectAdapter;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectWallet.
  ///
  /// In en, this message translates to:
  /// **'CONNECT WALLET'**
  String get connectWallet;

  /// No description provided for @phantomTip.
  ///
  /// In en, this message translates to:
  /// **'💡 Use Phantom wallet for best devnet support'**
  String get phantomTip;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied;

  /// No description provided for @lifetimeStats.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME STATS'**
  String get lifetimeStats;

  /// No description provided for @statLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get statLevel;

  /// No description provided for @statTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get statTotalXp;

  /// No description provided for @statPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPoints;

  /// No description provided for @statOresMined.
  ///
  /// In en, this message translates to:
  /// **'Ores Mined'**
  String get statOresMined;

  /// No description provided for @statMaxDepth.
  ///
  /// In en, this message translates to:
  /// **'Max Depth'**
  String get statMaxDepth;

  /// No description provided for @statPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play Time'**
  String get statPlayTime;

  /// No description provided for @statPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get statPointsEarned;

  /// No description provided for @statPointsSpent.
  ///
  /// In en, this message translates to:
  /// **'Points Spent'**
  String get statPointsSpent;

  /// No description provided for @signedInEmail.
  ///
  /// In en, this message translates to:
  /// **'Signed in with email'**
  String get signedInEmail;

  /// No description provided for @signedInWallet.
  ///
  /// In en, this message translates to:
  /// **'Signed in with wallet'**
  String get signedInWallet;

  /// No description provided for @playingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as guest'**
  String get playingAsGuest;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @guestSignOutWarning.
  ///
  /// In en, this message translates to:
  /// **'Guest progress is only on this device. Signing out will remove access to your current saves. Are you sure?'**
  String get guestSignOutWarning;

  /// No description provided for @emailAccount.
  ///
  /// In en, this message translates to:
  /// **'Email Account'**
  String get emailAccount;

  /// No description provided for @walletAccount.
  ///
  /// In en, this message translates to:
  /// **'Wallet Account'**
  String get walletAccount;

  /// No description provided for @guestLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Guest — progress is local only'**
  String get guestLocalOnly;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @newGameTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW GAME'**
  String get newGameTitle;

  /// No description provided for @loadGameTitle.
  ///
  /// In en, this message translates to:
  /// **'LOAD GAME'**
  String get loadGameTitle;

  /// No description provided for @newGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a save slot for your new adventure'**
  String get newGameSubtitle;

  /// No description provided for @loadGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a save to continue your journey'**
  String get loadGameSubtitle;

  /// No description provided for @slotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot} — Empty'**
  String slotEmpty(int slot);

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start a new adventure'**
  String get tapToStart;

  /// No description provided for @noSaveData.
  ///
  /// In en, this message translates to:
  /// **'No save data'**
  String get noSaveData;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot}'**
  String slot(int slot);

  /// No description provided for @savedAgo.
  ///
  /// In en, this message translates to:
  /// **'Saved {time}'**
  String savedAgo(String time);

  /// No description provided for @deleteSlotConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Slot {slot}?'**
  String deleteSlotConfirm(int slot);

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @overwriteSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Save?'**
  String get overwriteSaveTitle;

  /// No description provided for @overwriteSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot} already has a save. Starting a new game here will overwrite it.'**
  String overwriteSaveMessage(int slot);

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'OVERWRITE'**
  String get overwrite;

  /// No description provided for @noSaves.
  ///
  /// In en, this message translates to:
  /// **'(no saves)'**
  String get noSaves;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{min}m ago'**
  String minutesAgo(int min);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @hp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get hp;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'FUEL'**
  String get fuel;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'ITEMS: '**
  String get items;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get store;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get shop;

  /// No description provided for @depthMeter.
  ///
  /// In en, this message translates to:
  /// **'{depth}m'**
  String depthMeter(int depth);

  /// No description provided for @miningSupplyCo.
  ///
  /// In en, this message translates to:
  /// **'MINING SUPPLY CO.'**
  String get miningSupplyCo;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @hull.
  ///
  /// In en, this message translates to:
  /// **'Hull'**
  String get hull;

  /// No description provided for @fuelLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelLabel;

  /// No description provided for @cargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get cargo;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @upgrades.
  ///
  /// In en, this message translates to:
  /// **'Upgrades'**
  String get upgrades;

  /// No description provided for @itemsTab.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTab;

  /// No description provided for @sellOre.
  ///
  /// In en, this message translates to:
  /// **'SELL ORE'**
  String get sellOre;

  /// No description provided for @noOreToSell.
  ///
  /// In en, this message translates to:
  /// **'No ore to sell'**
  String get noOreToSell;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value:'**
  String get totalValue;

  /// No description provided for @sellAll.
  ///
  /// In en, this message translates to:
  /// **'SELL ALL'**
  String get sellAll;

  /// No description provided for @refuel.
  ///
  /// In en, this message translates to:
  /// **'REFUEL'**
  String get refuel;

  /// No description provided for @refuelCost.
  ///
  /// In en, this message translates to:
  /// **'REFUEL (\${cost})'**
  String refuelCost(int cost);

  /// No description provided for @tankFull.
  ///
  /// In en, this message translates to:
  /// **'Tank is full!'**
  String get tankFull;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'REPAIR'**
  String get repair;

  /// No description provided for @repairHullCost.
  ///
  /// In en, this message translates to:
  /// **'REPAIR HULL (\${cost})'**
  String repairHullCost(int cost);

  /// No description provided for @hullFullyRepaired.
  ///
  /// In en, this message translates to:
  /// **'Hull is fully repaired!'**
  String get hullFullyRepaired;

  /// No description provided for @inventorySlots.
  ///
  /// In en, this message translates to:
  /// **'Inventory: {used}/{max} slots'**
  String inventorySlots(int used, int max);

  /// No description provided for @upgradeCost.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE - \${cost}'**
  String upgradeCost(int cost);

  /// No description provided for @maxed.
  ///
  /// In en, this message translates to:
  /// **'MAXED'**
  String get maxed;

  /// No description provided for @drillBit.
  ///
  /// In en, this message translates to:
  /// **'Drill Bit'**
  String get drillBit;

  /// No description provided for @engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engine;

  /// No description provided for @cooling.
  ///
  /// In en, this message translates to:
  /// **'Cooling'**
  String get cooling;

  /// No description provided for @fuelTank.
  ///
  /// In en, this message translates to:
  /// **'Fuel Tank'**
  String get fuelTank;

  /// No description provided for @cargoBay.
  ///
  /// In en, this message translates to:
  /// **'Cargo Bay'**
  String get cargoBay;

  /// No description provided for @hullArmor.
  ///
  /// In en, this message translates to:
  /// **'Hull Armor'**
  String get hullArmor;

  /// No description provided for @capacityValue.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {value}'**
  String capacityValue(int value);

  /// No description provided for @speedPercent.
  ///
  /// In en, this message translates to:
  /// **'Speed: {percent}%'**
  String speedPercent(int percent);

  /// No description provided for @fuelSavingsPercent.
  ///
  /// In en, this message translates to:
  /// **'Fuel savings: {percent}%'**
  String fuelSavingsPercent(int percent);

  /// No description provided for @noFuelSavings.
  ///
  /// In en, this message translates to:
  /// **'No fuel savings'**
  String get noFuelSavings;

  /// No description provided for @maxHpValue.
  ///
  /// In en, this message translates to:
  /// **'Max HP: {value}'**
  String maxHpValue(int value);

  /// No description provided for @returnToMining.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO MINING'**
  String get returnToMining;

  /// No description provided for @soldOreFor.
  ///
  /// In en, this message translates to:
  /// **'Sold ore for \${amount}!'**
  String soldOreFor(int amount);

  /// No description provided for @tankRefueled.
  ///
  /// In en, this message translates to:
  /// **'Tank refueled!'**
  String get tankRefueled;

  /// No description provided for @fuelTankUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Fuel tank upgraded!'**
  String get fuelTankUpgraded;

  /// No description provided for @cargoBayUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Cargo bay upgraded!'**
  String get cargoBayUpgraded;

  /// No description provided for @hullRepaired.
  ///
  /// In en, this message translates to:
  /// **'Hull repaired!'**
  String get hullRepaired;

  /// No description provided for @hullArmorUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Hull armor upgraded!'**
  String get hullArmorUpgraded;

  /// No description provided for @drillBitUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Drill bit upgraded!'**
  String get drillBitUpgraded;

  /// No description provided for @engineUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Engine upgraded!'**
  String get engineUpgraded;

  /// No description provided for @coolingUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Cooling system upgraded!'**
  String get coolingUpgraded;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased {item}!'**
  String purchased(String item);

  /// No description provided for @premiumStore.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM STORE'**
  String get premiumStore;

  /// No description provided for @onChainLoaded.
  ///
  /// In en, this message translates to:
  /// **'On-chain prices loaded'**
  String get onChainLoaded;

  /// No description provided for @usingDefaultPrices.
  ///
  /// In en, this message translates to:
  /// **'Using default prices'**
  String get usingDefaultPrices;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @activeBoosts.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE BOOSTS'**
  String get activeBoosts;

  /// No description provided for @permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get permanent;

  /// No description provided for @pointsTab.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsTab;

  /// No description provided for @solTab.
  ///
  /// In en, this message translates to:
  /// **'SOL'**
  String get solTab;

  /// No description provided for @nftTab.
  ///
  /// In en, this message translates to:
  /// **'NFT'**
  String get nftTab;

  /// No description provided for @walletRequired.
  ///
  /// In en, this message translates to:
  /// **'Wallet Required'**
  String get walletRequired;

  /// No description provided for @walletRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect your Solana wallet to access premium items.\nAll purchases are on-chain transactions.'**
  String get walletRequiredMessage;

  /// No description provided for @storePricesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store Prices Unavailable'**
  String get storePricesUnavailable;

  /// No description provided for @storePricesUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load on-chain pricing.\nPlease check your connection and try again.'**
  String get storePricesUnavailableMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points!'**
  String get notEnoughPoints;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'{item} activated!'**
  String activated(String item);

  /// No description provided for @purchasedTx.
  ///
  /// In en, this message translates to:
  /// **'{item} purchased! TX: {tx}...'**
  String purchasedTx(String item, String tx);

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// No description provided for @closeStore.
  ///
  /// In en, this message translates to:
  /// **'CLOSE STORE'**
  String get closeStore;

  /// No description provided for @diggleDrillMachine.
  ///
  /// In en, this message translates to:
  /// **'DIGGLE DRILL MACHINE'**
  String get diggleDrillMachine;

  /// No description provided for @permanentBoostNft.
  ///
  /// In en, this message translates to:
  /// **'Permanent boost NFT — one per player'**
  String get permanentBoostNft;

  /// No description provided for @holderBenefits.
  ///
  /// In en, this message translates to:
  /// **'HOLDER BENEFITS'**
  String get holderBenefits;

  /// No description provided for @permanentXpBoost.
  ///
  /// In en, this message translates to:
  /// **'Permanent XP Boost'**
  String get permanentXpBoost;

  /// No description provided for @permanentPointsBoost.
  ///
  /// In en, this message translates to:
  /// **'Permanent Points Boost'**
  String get permanentPointsBoost;

  /// No description provided for @limitedSupply.
  ///
  /// In en, this message translates to:
  /// **'Limited Supply'**
  String get limitedSupply;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'SOLD OUT'**
  String get soldOut;

  /// No description provided for @allNftsMinted.
  ///
  /// In en, this message translates to:
  /// **'All Diggle Drill NFTs have been minted!'**
  String get allNftsMinted;

  /// No description provided for @mintOpensSoon.
  ///
  /// In en, this message translates to:
  /// **'MINT OPENS SOON'**
  String get mintOpensSoon;

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts: {date}'**
  String startsAt(String date);

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later!'**
  String get checkBackLater;

  /// No description provided for @mintNft.
  ///
  /// In en, this message translates to:
  /// **'MINT NFT'**
  String get mintNft;

  /// No description provided for @mintCost.
  ///
  /// In en, this message translates to:
  /// **'MINT — {cost} SOL'**
  String mintCost(String cost);

  /// No description provided for @nftMinted.
  ///
  /// In en, this message translates to:
  /// **'NFT Minted! 🎉'**
  String get nftMinted;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @boostsActive.
  ///
  /// In en, this message translates to:
  /// **'Your boosts are permanently active!'**
  String get boostsActive;

  /// No description provided for @mintStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing transaction...'**
  String get mintStatusPreparing;

  /// No description provided for @mintStatusApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve in your wallet app...'**
  String get mintStatusApprove;

  /// No description provided for @mintStatusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending transaction...'**
  String get mintStatusSending;

  /// No description provided for @mintStatusConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming on-chain...'**
  String get mintStatusConfirming;

  /// No description provided for @mintStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Minted successfully!'**
  String get mintStatusSuccess;

  /// No description provided for @mintStatusError.
  ///
  /// In en, this message translates to:
  /// **'Mint failed'**
  String get mintStatusError;

  /// No description provided for @xpLabel.
  ///
  /// In en, this message translates to:
  /// **'XP: {current}/{next}'**
  String xpLabel(int current, int next);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Game preferences'**
  String get settingsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSubtitle;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This version of Diggle is no longer supported. Please update to continue playing.'**
  String get updateRequiredMessage;

  /// No description provided for @currentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentVersionLabel;

  /// No description provided for @latestVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestVersionLabel;

  /// No description provided for @requiredVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredVersionLabel;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateOpenStoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dApp Store. Please update manually.'**
  String get updateOpenStoreFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
