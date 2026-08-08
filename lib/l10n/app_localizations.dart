import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
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

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Light system upgraded!'**
  String get lightUpgraded;

  /// No description provided for @revealRadiusValue.
  ///
  /// In en, this message translates to:
  /// **'Reveal: {radius} tiles'**
  String revealRadiusValue(int radius);

  /// No description provided for @questsTitle.
  ///
  /// In en, this message translates to:
  /// **'QUESTS'**
  String get questsTitle;

  /// No description provided for @questsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete quests to earn XP & points'**
  String get questsSubtitle;

  /// No description provided for @questsDailyTab.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get questsDailyTab;

  /// No description provided for @questsSocialTab.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get questsSocialTab;

  /// No description provided for @questsClaim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get questsClaim;

  /// No description provided for @questsClaimed.
  ///
  /// In en, this message translates to:
  /// **'✓ Claimed'**
  String get questsClaimed;

  /// No description provided for @questsGo.
  ///
  /// In en, this message translates to:
  /// **'GO'**
  String get questsGo;

  /// No description provided for @questsClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get questsClose;

  /// No description provided for @questsNoDailyQuests.
  ///
  /// In en, this message translates to:
  /// **'No daily quests available'**
  String get questsNoDailyQuests;

  /// No description provided for @questsSocialInfo.
  ///
  /// In en, this message translates to:
  /// **'Complete social actions to earn one-time rewards. Tap GO to open the link.'**
  String get questsSocialInfo;

  /// No description provided for @quests.
  ///
  /// In en, this message translates to:
  /// **'QUESTS'**
  String get quests;

  /// No description provided for @questMineOreTitle.
  ///
  /// In en, this message translates to:
  /// **'Mine {count} Ores'**
  String questMineOreTitle(int count);

  /// No description provided for @questMineOreDesc.
  ///
  /// In en, this message translates to:
  /// **'Mine {count} ore tiles in a single day'**
  String questMineOreDesc(int count);

  /// No description provided for @questReachDepthTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach {depth}m Depth'**
  String questReachDepthTitle(int depth);

  /// No description provided for @questReachDepthDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach a depth of {depth}m or more'**
  String questReachDepthDesc(int depth);

  /// No description provided for @questSellOreTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell \${value} Worth'**
  String questSellOreTitle(int value);

  /// No description provided for @questSellOreDesc.
  ///
  /// In en, this message translates to:
  /// **'Sell ore worth a total of \${value}'**
  String questSellOreDesc(int value);

  /// No description provided for @questRepairTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair {amount} HP'**
  String questRepairTitle(int amount);

  /// No description provided for @questRepairDesc.
  ///
  /// In en, this message translates to:
  /// **'Repair a total of {amount} hull HP'**
  String questRepairDesc(int amount);

  /// No description provided for @questUseItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use {count} Items'**
  String questUseItemsTitle(int count);

  /// No description provided for @questUseItemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Use {count} items from your inventory'**
  String questUseItemsDesc(int count);

  /// No description provided for @questFollowTwitterTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow on X'**
  String get questFollowTwitterTitle;

  /// No description provided for @questFollowTwitterDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow @DiggleGame on X (Twitter)'**
  String get questFollowTwitterDesc;

  /// No description provided for @questJoinDiscordTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Discord'**
  String get questJoinDiscordTitle;

  /// No description provided for @questJoinDiscordDesc.
  ///
  /// In en, this message translates to:
  /// **'Join the Diggle Discord community'**
  String get questJoinDiscordDesc;

  /// No description provided for @questPostTweetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share on X'**
  String get questPostTweetTitle;

  /// No description provided for @questPostTweetDesc.
  ///
  /// In en, this message translates to:
  /// **'Post a tweet about Diggle'**
  String get questPostTweetDesc;

  /// No description provided for @questVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get questVerifyButton;

  /// No description provided for @questPasteTweetUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste your tweet URL here'**
  String get questPasteTweetUrl;

  /// No description provided for @questVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get questVerifying;

  /// No description provided for @questVerified.
  ///
  /// In en, this message translates to:
  /// **'Quest verified and completed!'**
  String get questVerified;

  /// No description provided for @questVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify. Please try again.'**
  String get questVerificationFailed;

  /// No description provided for @loginStreak.
  ///
  /// In en, this message translates to:
  /// **'Login Streak'**
  String get loginStreak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1 day} other{{count} days}}'**
  String streakDays(int count);

  /// No description provided for @streakClaimedToday.
  ///
  /// In en, this message translates to:
  /// **'Claimed today'**
  String get streakClaimedToday;

  /// No description provided for @streakPlayToday.
  ///
  /// In en, this message translates to:
  /// **'Play today to keep it going'**
  String get streakPlayToday;

  /// No description provided for @streakStartToday.
  ///
  /// In en, this message translates to:
  /// **'Play today to start a streak'**
  String get streakStartToday;

  /// No description provided for @streakNextReward.
  ///
  /// In en, this message translates to:
  /// **'Next: +{xp} XP, +{points} pts'**
  String streakNextReward(int xp, int points);

  /// No description provided for @streakJackpotReached.
  ///
  /// In en, this message translates to:
  /// **'Jackpot rung — max daily reward'**
  String get streakJackpotReached;

  /// No description provided for @streakToJackpot.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to the jackpot} other{{count} days to the jackpot}}'**
  String streakToJackpot(int count);

  /// No description provided for @menuWeeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get menuWeeklyChallenge;

  /// No description provided for @menuLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get menuLeaderboard;

  /// No description provided for @menuHangar.
  ///
  /// In en, this message translates to:
  /// **'Hangar'**
  String get menuHangar;

  /// No description provided for @museumTitle.
  ///
  /// In en, this message translates to:
  /// **'MUSEUM'**
  String get museumTitle;

  /// No description provided for @achievementsTab.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get achievementsTab;

  /// No description provided for @leaderboardHeading.
  ///
  /// In en, this message translates to:
  /// **'🏆 LEADERBOARD'**
  String get leaderboardHeading;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet.\nBe the first on the board!'**
  String get leaderboardEmpty;

  /// No description provided for @hangarHeading.
  ///
  /// In en, this message translates to:
  /// **'🛠️ HANGAR'**
  String get hangarHeading;

  /// No description provided for @hangarMachineCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Diggle Machines in this wallet — one can be equipped at a time.'**
  String hangarMachineCount(int count);

  /// No description provided for @hangarSeekerVerified.
  ///
  /// In en, this message translates to:
  /// **'SEEKER GENESIS VERIFIED'**
  String get hangarSeekerVerified;

  /// No description provided for @hangarSeekerBlurb.
  ///
  /// In en, this message translates to:
  /// **'Solana Mobile pioneer — +5% XP & Points, always on.'**
  String get hangarSeekerBlurb;

  /// No description provided for @hangarSealedCrate.
  ///
  /// In en, this message translates to:
  /// **'SEALED CRATE'**
  String get hangarSealedCrate;

  /// No description provided for @hangarSealedBlurb.
  ///
  /// In en, this message translates to:
  /// **'This machine hasn\'t been revealed yet. Until then it grants the flat +25% XP & Points holder boost.\n\nAfter the reveal, its five gear traits (Hull, Thruster, Fuel Tank, Drill, Cargo Hold) become equippable with rarity-based stat bonuses. Tap refresh after reveal day!'**
  String get hangarSealedBlurb;

  /// No description provided for @hangarEquipped.
  ///
  /// In en, this message translates to:
  /// **'✅ Equipped — bonuses active in normal runs.\nWeekly Challenge uses a standardized loadout (no gear).'**
  String get hangarEquipped;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @airdrop.
  ///
  /// In en, this message translates to:
  /// **'Airdrop'**
  String get airdrop;

  /// No description provided for @questsWeeklyTab.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get questsWeeklyTab;

  /// No description provided for @questsWeeklyInfo.
  ///
  /// In en, this message translates to:
  /// **'Big challenges, big rewards. Resets every Monday (UTC).'**
  String get questsWeeklyInfo;

  /// No description provided for @questsNotEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points ({cost} needed). Grab a points pack in the store!'**
  String questsNotEnoughPoints(int cost);

  /// No description provided for @questJoinDiscordServer.
  ///
  /// In en, this message translates to:
  /// **'Join Discord Server'**
  String get questJoinDiscordServer;

  /// No description provided for @questCheckingMembership.
  ///
  /// In en, this message translates to:
  /// **'Checking membership...'**
  String get questCheckingMembership;

  /// No description provided for @questVerifyMembership.
  ///
  /// In en, this message translates to:
  /// **'Verify Membership'**
  String get questVerifyMembership;

  /// No description provided for @questDiscordHint.
  ///
  /// In en, this message translates to:
  /// **'Join the server first, then tap Verify to confirm with Discord'**
  String get questDiscordHint;

  /// No description provided for @questPostOnX.
  ///
  /// In en, this message translates to:
  /// **'Post on X'**
  String get questPostOnX;

  /// No description provided for @questTweetHint.
  ///
  /// In en, this message translates to:
  /// **'Post the tweet above, then paste the URL to verify'**
  String get questTweetHint;

  /// No description provided for @questDiscordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Discord verification not available. Try again later.'**
  String get questDiscordUnavailable;

  /// No description provided for @questDiscordOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Discord. Please try again.'**
  String get questDiscordOpenFailed;

  /// No description provided for @questDiscordVerified.
  ///
  /// In en, this message translates to:
  /// **'Discord membership verified! 🎉'**
  String get questDiscordVerified;

  /// No description provided for @questDiscordVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify membership. Make sure you joined the server and authorized Discord.'**
  String get questDiscordVerifyFailed;

  /// No description provided for @signNewContract.
  ///
  /// In en, this message translates to:
  /// **'Sign New Contract'**
  String get signNewContract;

  /// No description provided for @corporateContract.
  ///
  /// In en, this message translates to:
  /// **'⭐ Corporate Contract'**
  String get corporateContract;

  /// No description provided for @prestigeDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Sign Contract #{level}?\n\nRESETS: world, cash, ship upgrades\nKEEPS: XP, points, NFTs, achievements, collection\n\nPERMANENT PERKS:\n• +{sellBonus}% ore sell price\n• \${startCash} starting cash + starter kit\n{hardcore}• {badge} leaderboard badge'**
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  );

  /// No description provided for @prestigeHardcoreLine.
  ///
  /// In en, this message translates to:
  /// **'• Hardcore seams: richer ore, deadlier hazards\n'**
  String get prestigeHardcoreLine;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @signContract.
  ///
  /// In en, this message translates to:
  /// **'Sign Contract'**
  String get signContract;

  /// No description provided for @recoveryFailedPoints.
  ///
  /// In en, this message translates to:
  /// **'Recovery failed — not enough points'**
  String get recoveryFailedPoints;

  /// No description provided for @emergencyRecoveryCost.
  ///
  /// In en, this message translates to:
  /// **'Emergency Recovery ({cost} pts)'**
  String emergencyRecoveryCost(int cost);

  /// No description provided for @emergencyRecoveryNeed.
  ///
  /// In en, this message translates to:
  /// **'Need {cost} pts — open Store'**
  String emergencyRecoveryNeed(int cost);

  /// No description provided for @keepsCargo.
  ///
  /// In en, this message translates to:
  /// **'Keeps your \${value} cargo!'**
  String keepsCargo(int value);

  /// No description provided for @titleUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Title unlocked: {title}'**
  String titleUnlocked(String title);

  /// No description provided for @titleProspector.
  ///
  /// In en, this message translates to:
  /// **'Prospector'**
  String get titleProspector;

  /// No description provided for @titleExcavator.
  ///
  /// In en, this message translates to:
  /// **'Excavator'**
  String get titleExcavator;

  /// No description provided for @titleDemolitionist.
  ///
  /// In en, this message translates to:
  /// **'Demolitionist'**
  String get titleDemolitionist;

  /// No description provided for @titleDeepMiner.
  ///
  /// In en, this message translates to:
  /// **'Deep Miner'**
  String get titleDeepMiner;

  /// No description provided for @titleVoidwalker.
  ///
  /// In en, this message translates to:
  /// **'Voidwalker'**
  String get titleVoidwalker;

  /// No description provided for @titleCoreBreaker.
  ///
  /// In en, this message translates to:
  /// **'Core Breaker'**
  String get titleCoreBreaker;

  /// No description provided for @titleDiggleLegend.
  ///
  /// In en, this message translates to:
  /// **'Diggle Legend'**
  String get titleDiggleLegend;

  /// No description provided for @artifactTsFossilFern.
  ///
  /// In en, this message translates to:
  /// **'Fern Fossil'**
  String get artifactTsFossilFern;

  /// No description provided for @artifactTsFossilFernDesc.
  ///
  /// In en, this message translates to:
  /// **'A perfect imprint of a prehistoric fern.'**
  String get artifactTsFossilFernDesc;

  /// No description provided for @artifactTsOldBoot.
  ///
  /// In en, this message translates to:
  /// **'Prospector\'s Boot'**
  String get artifactTsOldBoot;

  /// No description provided for @artifactTsOldBootDesc.
  ///
  /// In en, this message translates to:
  /// **'Somebody dug here long before you.'**
  String get artifactTsOldBootDesc;

  /// No description provided for @artifactTsClayJar.
  ///
  /// In en, this message translates to:
  /// **'Clay Jar'**
  String get artifactTsClayJar;

  /// No description provided for @artifactTsClayJarDesc.
  ///
  /// In en, this message translates to:
  /// **'Ancient storage, miraculously unbroken.'**
  String get artifactTsClayJarDesc;

  /// No description provided for @artifactTsArrowhead.
  ///
  /// In en, this message translates to:
  /// **'Flint Arrowhead'**
  String get artifactTsArrowhead;

  /// No description provided for @artifactTsArrowheadDesc.
  ///
  /// In en, this message translates to:
  /// **'Knapped by hands ten thousand years gone.'**
  String get artifactTsArrowheadDesc;

  /// No description provided for @artifactTsCoinHoard.
  ///
  /// In en, this message translates to:
  /// **'Coin Hoard'**
  String get artifactTsCoinHoard;

  /// No description provided for @artifactTsCoinHoardDesc.
  ///
  /// In en, this message translates to:
  /// **'Corroded coins from a forgotten mint.'**
  String get artifactTsCoinHoardDesc;

  /// No description provided for @artifactPfMammothTusk.
  ///
  /// In en, this message translates to:
  /// **'Mammoth Tusk'**
  String get artifactPfMammothTusk;

  /// No description provided for @artifactPfMammothTuskDesc.
  ///
  /// In en, this message translates to:
  /// **'Curved ivory, cold to the touch.'**
  String get artifactPfMammothTuskDesc;

  /// No description provided for @artifactPfIceLens.
  ///
  /// In en, this message translates to:
  /// **'Ice Lens'**
  String get artifactPfIceLens;

  /// No description provided for @artifactPfIceLensDesc.
  ///
  /// In en, this message translates to:
  /// **'A naturally formed lens of ancient ice.'**
  String get artifactPfIceLensDesc;

  /// No description provided for @artifactPfFrozenFlower.
  ///
  /// In en, this message translates to:
  /// **'Frozen Flower'**
  String get artifactPfFrozenFlower;

  /// No description provided for @artifactPfFrozenFlowerDesc.
  ///
  /// In en, this message translates to:
  /// **'A bloom preserved mid-blossom for millennia.'**
  String get artifactPfFrozenFlowerDesc;

  /// No description provided for @artifactPfSledRunner.
  ///
  /// In en, this message translates to:
  /// **'Sled Runner'**
  String get artifactPfSledRunner;

  /// No description provided for @artifactPfSledRunnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Part of an expedition that never returned.'**
  String get artifactPfSledRunnerDesc;

  /// No description provided for @artifactPfAmberInsect.
  ///
  /// In en, this message translates to:
  /// **'Amber Insect'**
  String get artifactPfAmberInsect;

  /// No description provided for @artifactPfAmberInsectDesc.
  ///
  /// In en, this message translates to:
  /// **'A tiny passenger frozen in golden resin.'**
  String get artifactPfAmberInsectDesc;

  /// No description provided for @artifactCcSingingGeode.
  ///
  /// In en, this message translates to:
  /// **'Singing Geode'**
  String get artifactCcSingingGeode;

  /// No description provided for @artifactCcSingingGeodeDesc.
  ///
  /// In en, this message translates to:
  /// **'It hums a note just below hearing.'**
  String get artifactCcSingingGeodeDesc;

  /// No description provided for @artifactCcPrismCore.
  ///
  /// In en, this message translates to:
  /// **'Prism Core'**
  String get artifactCcPrismCore;

  /// No description provided for @artifactCcPrismCoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Splits lamplight into colors with no names.'**
  String get artifactCcPrismCoreDesc;

  /// No description provided for @artifactCcPetrifiedEye.
  ///
  /// In en, this message translates to:
  /// **'Petrified Eye'**
  String get artifactCcPetrifiedEye;

  /// No description provided for @artifactCcPetrifiedEyeDesc.
  ///
  /// In en, this message translates to:
  /// **'You are certain it was watching you.'**
  String get artifactCcPetrifiedEyeDesc;

  /// No description provided for @artifactCcResonantShard.
  ///
  /// In en, this message translates to:
  /// **'Resonant Shard'**
  String get artifactCcResonantShard;

  /// No description provided for @artifactCcResonantShardDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrates when other crystals are near.'**
  String get artifactCcResonantShardDesc;

  /// No description provided for @artifactCcHollowBell.
  ///
  /// In en, this message translates to:
  /// **'Hollow Bell'**
  String get artifactCcHollowBell;

  /// No description provided for @artifactCcHollowBellDesc.
  ///
  /// In en, this message translates to:
  /// **'A crystal bell that rings in silence.'**
  String get artifactCcHollowBellDesc;

  /// No description provided for @artifactMcObsidianBlade.
  ///
  /// In en, this message translates to:
  /// **'Obsidian Blade'**
  String get artifactMcObsidianBlade;

  /// No description provided for @artifactMcObsidianBladeDesc.
  ///
  /// In en, this message translates to:
  /// **'Volcanic glass, sharper than any drill.'**
  String get artifactMcObsidianBladeDesc;

  /// No description provided for @artifactMcFireOpal.
  ///
  /// In en, this message translates to:
  /// **'Fire Opal'**
  String get artifactMcFireOpal;

  /// No description provided for @artifactMcFireOpalDesc.
  ///
  /// In en, this message translates to:
  /// **'A stone with a living ember inside.'**
  String get artifactMcFireOpalDesc;

  /// No description provided for @artifactMcBasaltIdol.
  ///
  /// In en, this message translates to:
  /// **'Basalt Idol'**
  String get artifactMcBasaltIdol;

  /// No description provided for @artifactMcBasaltIdolDesc.
  ///
  /// In en, this message translates to:
  /// **'Carved by something that liked the heat.'**
  String get artifactMcBasaltIdolDesc;

  /// No description provided for @artifactMcMeteorFragment.
  ///
  /// In en, this message translates to:
  /// **'Meteor Fragment'**
  String get artifactMcMeteorFragment;

  /// No description provided for @artifactMcMeteorFragmentDesc.
  ///
  /// In en, this message translates to:
  /// **'It fell from above and sank this deep.'**
  String get artifactMcMeteorFragmentDesc;

  /// No description provided for @artifactMcHeartOfCore.
  ///
  /// In en, this message translates to:
  /// **'Heart of the Core'**
  String get artifactMcHeartOfCore;

  /// No description provided for @artifactMcHeartOfCoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Still warm. Still beating?'**
  String get artifactMcHeartOfCoreDesc;

  /// No description provided for @achievementOre10.
  ///
  /// In en, this message translates to:
  /// **'First Haul'**
  String get achievementOre10;

  /// No description provided for @achievementOre10Desc.
  ///
  /// In en, this message translates to:
  /// **'Mine 10 ores'**
  String get achievementOre10Desc;

  /// No description provided for @achievementOre100.
  ///
  /// In en, this message translates to:
  /// **'Ore Hound'**
  String get achievementOre100;

  /// No description provided for @achievementOre100Desc.
  ///
  /// In en, this message translates to:
  /// **'Mine 100 ores'**
  String get achievementOre100Desc;

  /// No description provided for @achievementOre500.
  ///
  /// In en, this message translates to:
  /// **'Vein Chaser'**
  String get achievementOre500;

  /// No description provided for @achievementOre500Desc.
  ///
  /// In en, this message translates to:
  /// **'Mine 500 ores'**
  String get achievementOre500Desc;

  /// No description provided for @achievementOre2000.
  ///
  /// In en, this message translates to:
  /// **'Strip Miner'**
  String get achievementOre2000;

  /// No description provided for @achievementOre2000Desc.
  ///
  /// In en, this message translates to:
  /// **'Mine 2,000 ores'**
  String get achievementOre2000Desc;

  /// No description provided for @achievementOre10000.
  ///
  /// In en, this message translates to:
  /// **'Planet Eater'**
  String get achievementOre10000;

  /// No description provided for @achievementOre10000Desc.
  ///
  /// In en, this message translates to:
  /// **'Mine 10,000 ores'**
  String get achievementOre10000Desc;

  /// No description provided for @achievementDepth50.
  ///
  /// In en, this message translates to:
  /// **'Below the Roots'**
  String get achievementDepth50;

  /// No description provided for @achievementDepth50Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach depth 50'**
  String get achievementDepth50Desc;

  /// No description provided for @achievementDepth120.
  ///
  /// In en, this message translates to:
  /// **'Into the Frost'**
  String get achievementDepth120;

  /// No description provided for @achievementDepth120Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach the Permafrost (depth 120)'**
  String get achievementDepth120Desc;

  /// No description provided for @achievementDepth240.
  ///
  /// In en, this message translates to:
  /// **'Crystal Gazer'**
  String get achievementDepth240;

  /// No description provided for @achievementDepth240Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach the Crystal Caverns (depth 240)'**
  String get achievementDepth240Desc;

  /// No description provided for @achievementDepth360.
  ///
  /// In en, this message translates to:
  /// **'Magma Diver'**
  String get achievementDepth360;

  /// No description provided for @achievementDepth360Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach the Magma Core (depth 360)'**
  String get achievementDepth360Desc;

  /// No description provided for @achievementDepth445.
  ///
  /// In en, this message translates to:
  /// **'Rock Bottom'**
  String get achievementDepth445;

  /// No description provided for @achievementDepth445Desc.
  ///
  /// In en, this message translates to:
  /// **'Touch the world floor (depth 445)'**
  String get achievementDepth445Desc;

  /// No description provided for @achievementCash1k.
  ///
  /// In en, this message translates to:
  /// **'Pocket Money'**
  String get achievementCash1k;

  /// No description provided for @achievementCash1kDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn \$1,000 lifetime'**
  String get achievementCash1kDesc;

  /// No description provided for @achievementCash25k.
  ///
  /// In en, this message translates to:
  /// **'Business Miner'**
  String get achievementCash25k;

  /// No description provided for @achievementCash25kDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn \$25,000 lifetime'**
  String get achievementCash25kDesc;

  /// No description provided for @achievementCash250k.
  ///
  /// In en, this message translates to:
  /// **'Ore Baron'**
  String get achievementCash250k;

  /// No description provided for @achievementCash250kDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn \$250,000 lifetime'**
  String get achievementCash250kDesc;

  /// No description provided for @achievementCash1m.
  ///
  /// In en, this message translates to:
  /// **'Diggle Tycoon'**
  String get achievementCash1m;

  /// No description provided for @achievementCash1mDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn \$1,000,000 lifetime'**
  String get achievementCash1mDesc;

  /// No description provided for @achievementLevel5.
  ///
  /// In en, this message translates to:
  /// **'Getting Serious'**
  String get achievementLevel5;

  /// No description provided for @achievementLevel5Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 5'**
  String get achievementLevel5Desc;

  /// No description provided for @achievementLevel10.
  ///
  /// In en, this message translates to:
  /// **'Double Digits'**
  String get achievementLevel10;

  /// No description provided for @achievementLevel10Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10'**
  String get achievementLevel10Desc;

  /// No description provided for @achievementLevel18.
  ///
  /// In en, this message translates to:
  /// **'Deep Veteran'**
  String get achievementLevel18;

  /// No description provided for @achievementLevel18Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 18'**
  String get achievementLevel18Desc;

  /// No description provided for @achievementLevel25.
  ///
  /// In en, this message translates to:
  /// **'Maximum Diggle'**
  String get achievementLevel25;

  /// No description provided for @achievementLevel25Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 25'**
  String get achievementLevel25Desc;

  /// No description provided for @achievementArtifact1.
  ///
  /// In en, this message translates to:
  /// **'Amateur Archaeologist'**
  String get achievementArtifact1;

  /// No description provided for @achievementArtifact1Desc.
  ///
  /// In en, this message translates to:
  /// **'Find your first artifact'**
  String get achievementArtifact1Desc;

  /// No description provided for @achievementArtifact10.
  ///
  /// In en, this message translates to:
  /// **'Museum Donor'**
  String get achievementArtifact10;

  /// No description provided for @achievementArtifact10Desc.
  ///
  /// In en, this message translates to:
  /// **'Find 10 artifacts'**
  String get achievementArtifact10Desc;

  /// No description provided for @achievementArtifact20.
  ///
  /// In en, this message translates to:
  /// **'Master Curator'**
  String get achievementArtifact20;

  /// No description provided for @achievementArtifact20Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete the full collection'**
  String get achievementArtifact20Desc;

  /// No description provided for @achievementBlast5.
  ///
  /// In en, this message translates to:
  /// **'Fire in the Hole'**
  String get achievementBlast5;

  /// No description provided for @achievementBlast5Desc.
  ///
  /// In en, this message translates to:
  /// **'Detonate 5 explosives'**
  String get achievementBlast5Desc;

  /// No description provided for @achievementBlast50.
  ///
  /// In en, this message translates to:
  /// **'Controlled Demolition'**
  String get achievementBlast50;

  /// No description provided for @achievementBlast50Desc.
  ///
  /// In en, this message translates to:
  /// **'Detonate 50 explosives'**
  String get achievementBlast50Desc;

  /// No description provided for @achievementSales10.
  ///
  /// In en, this message translates to:
  /// **'Regular Customer'**
  String get achievementSales10;

  /// No description provided for @achievementSales10Desc.
  ///
  /// In en, this message translates to:
  /// **'Sell ore 10 times'**
  String get achievementSales10Desc;

  /// No description provided for @achievementSales100.
  ///
  /// In en, this message translates to:
  /// **'Market Mover'**
  String get achievementSales100;

  /// No description provided for @achievementSales100Desc.
  ///
  /// In en, this message translates to:
  /// **'Sell ore 100 times'**
  String get achievementSales100Desc;

  /// No description provided for @achievementDeath1.
  ///
  /// In en, this message translates to:
  /// **'Occupational Hazard'**
  String get achievementDeath1;

  /// No description provided for @achievementDeath1Desc.
  ///
  /// In en, this message translates to:
  /// **'Lose your first drill'**
  String get achievementDeath1Desc;

  /// No description provided for @achievementDeath25.
  ///
  /// In en, this message translates to:
  /// **'Never Say Die'**
  String get achievementDeath25;

  /// No description provided for @achievementDeath25Desc.
  ///
  /// In en, this message translates to:
  /// **'Lose 25 drills and keep digging'**
  String get achievementDeath25Desc;

  /// No description provided for @itemBackupFuel.
  ///
  /// In en, this message translates to:
  /// **'Backup Fuel'**
  String get itemBackupFuel;

  /// No description provided for @itemRepairBot.
  ///
  /// In en, this message translates to:
  /// **'Repair Bot'**
  String get itemRepairBot;

  /// No description provided for @itemDynamite.
  ///
  /// In en, this message translates to:
  /// **'Dynamite'**
  String get itemDynamite;

  /// No description provided for @itemC4.
  ///
  /// In en, this message translates to:
  /// **'C4'**
  String get itemC4;

  /// No description provided for @itemSpaceRift.
  ///
  /// In en, this message translates to:
  /// **'Space Rift'**
  String get itemSpaceRift;

  /// No description provided for @itemOreScanner.
  ///
  /// In en, this message translates to:
  /// **'Ore Scanner'**
  String get itemOreScanner;

  /// No description provided for @itemHeatShield.
  ///
  /// In en, this message translates to:
  /// **'Heat Shield'**
  String get itemHeatShield;

  /// No description provided for @tileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get tileEmpty;

  /// No description provided for @tileDirt.
  ///
  /// In en, this message translates to:
  /// **'Dirt'**
  String get tileDirt;

  /// No description provided for @tileRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get tileRock;

  /// No description provided for @tileCoal.
  ///
  /// In en, this message translates to:
  /// **'Coal'**
  String get tileCoal;

  /// No description provided for @tileCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get tileCopper;

  /// No description provided for @tileSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tileSilver;

  /// No description provided for @tileGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tileGold;

  /// No description provided for @tileSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get tileSapphire;

  /// No description provided for @tileEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get tileEmerald;

  /// No description provided for @tileRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get tileRuby;

  /// No description provided for @tileDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get tileDiamond;

  /// No description provided for @tileLava.
  ///
  /// In en, this message translates to:
  /// **'Lava'**
  String get tileLava;

  /// No description provided for @tileGas.
  ///
  /// In en, this message translates to:
  /// **'Gas Pocket'**
  String get tileGas;

  /// No description provided for @tileFrozenDirt.
  ///
  /// In en, this message translates to:
  /// **'Frozen Dirt'**
  String get tileFrozenDirt;

  /// No description provided for @tileMagmaRock.
  ///
  /// In en, this message translates to:
  /// **'Magma Rock'**
  String get tileMagmaRock;

  /// No description provided for @tileCrystalOre.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get tileCrystalOre;

  /// No description provided for @tileUnstableRock.
  ///
  /// In en, this message translates to:
  /// **'Unstable Rock'**
  String get tileUnstableRock;

  /// No description provided for @tileLootCrate.
  ///
  /// In en, this message translates to:
  /// **'Supply Crate'**
  String get tileLootCrate;

  /// No description provided for @tileArtifact.
  ///
  /// In en, this message translates to:
  /// **'Artifact'**
  String get tileArtifact;

  /// No description provided for @tileBedrock.
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get tileBedrock;

  /// No description provided for @questUseExplosivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Detonate {count} explosives'**
  String questUseExplosivesTitle(int count);

  /// No description provided for @questUseExplosivesDesc.
  ///
  /// In en, this message translates to:
  /// **'Use dynamite or C4 {count} times'**
  String questUseExplosivesDesc(int count);

  /// No description provided for @questFindArtifactTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Find an artifact} other{Find {count} artifacts}}'**
  String questFindArtifactTitle(int count);

  /// No description provided for @questFindArtifactDesc.
  ///
  /// In en, this message translates to:
  /// **'Dig up buried artifacts in ruins'**
  String get questFindArtifactDesc;

  /// No description provided for @questOpenCrateTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Open a supply crate} other{Open {count} supply crates}}'**
  String questOpenCrateTitle(int count);

  /// No description provided for @questOpenCrateDesc.
  ///
  /// In en, this message translates to:
  /// **'Crack open supply crates in abandoned shafts'**
  String get questOpenCrateDesc;

  /// No description provided for @rarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// No description provided for @rarityUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get rarityUncommon;

  /// No description provided for @rarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  /// No description provided for @itemBackupFuelDesc.
  ///
  /// In en, this message translates to:
  /// **'Restores 50 fuel'**
  String get itemBackupFuelDesc;

  /// No description provided for @itemRepairBotDesc.
  ///
  /// In en, this message translates to:
  /// **'Repairs 40 hull HP'**
  String get itemRepairBotDesc;

  /// No description provided for @itemDynamiteDesc.
  ///
  /// In en, this message translates to:
  /// **'Blows up 3x3 area'**
  String get itemDynamiteDesc;

  /// No description provided for @itemC4Desc.
  ///
  /// In en, this message translates to:
  /// **'Blows up 5x5 area'**
  String get itemC4Desc;

  /// No description provided for @itemSpaceRiftDesc.
  ///
  /// In en, this message translates to:
  /// **'Teleport to surface'**
  String get itemSpaceRiftDesc;

  /// No description provided for @itemOreScannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveals terrain in a wide radius'**
  String get itemOreScannerDesc;

  /// No description provided for @itemHeatShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'60s of lava immunity'**
  String get itemHeatShieldDesc;

  /// No description provided for @biomeTopsoil.
  ///
  /// In en, this message translates to:
  /// **'TOPSOIL'**
  String get biomeTopsoil;

  /// No description provided for @biomePermafrost.
  ///
  /// In en, this message translates to:
  /// **'PERMAFROST'**
  String get biomePermafrost;

  /// No description provided for @biomeCrystalCaverns.
  ///
  /// In en, this message translates to:
  /// **'CRYSTAL CAVERNS'**
  String get biomeCrystalCaverns;

  /// No description provided for @biomeMagmaCore.
  ///
  /// In en, this message translates to:
  /// **'MAGMA CORE'**
  String get biomeMagmaCore;

  /// No description provided for @museumArtifactsTab.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACTS'**
  String get museumArtifactsTab;

  /// No description provided for @museumRecordsTab.
  ///
  /// In en, this message translates to:
  /// **'RECORDS'**
  String get museumRecordsTab;

  /// No description provided for @leaderboardDepthTab.
  ///
  /// In en, this message translates to:
  /// **'DEPTH'**
  String get leaderboardDepthTab;

  /// No description provided for @leaderboardPointsTab.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get leaderboardPointsTab;

  /// No description provided for @leaderboardWeeklyTab.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get leaderboardWeeklyTab;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
