// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline =>
      'CREUSEZ PROFOND  •  MINEZ DES RICHESSES  •  ALLEZ PLUS LOIN';

  @override
  String get mineDeepEarnRewards => 'Creusez profond. Gagnez des récompenses.';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => 'NOUVELLE PARTIE';

  @override
  String get continueGame => 'CONTINUER';

  @override
  String get loadGame => 'CHARGER';

  @override
  String get account => 'COMPTE';

  @override
  String get settings => 'Paramètres';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String comingSoon(String feature) {
    return '$feature bientôt disponible !';
  }

  @override
  String get helpMiningTitle => '⛏️ Minage';

  @override
  String get helpMiningBody =>
      'Utilisez les contrôles directionnels pour déplacer votre foreuse. Creusez la terre et la roche pour trouver des minerais précieux.';

  @override
  String get helpFuelTitle => '⛽ Carburant';

  @override
  String get helpFuelBody =>
      'Se déplacer et creuser consomme du carburant. Retournez à la surface avant d\'en manquer !';

  @override
  String get helpHullTitle => '🛡️ Coque';

  @override
  String get helpHullBody =>
      'Tomber de trop haut endommage votre coque. Surveillez vos PV !';

  @override
  String get helpSellingTitle => '💰 Vente';

  @override
  String get helpSellingBody =>
      'Retournez à la surface et visitez la BOUTIQUE pour vendre votre minerai contre de l\'argent.';

  @override
  String get helpUpgradesTitle => '🔧 Améliorations';

  @override
  String get helpUpgradesBody =>
      'Utilisez l\'argent pour améliorer votre réservoir, votre soute et votre blindage.';

  @override
  String get helpHazardsTitle => '⚠️ Dangers';

  @override
  String get helpHazardsBody =>
      'Attention à la lave (mort instantanée) et aux poches de gaz (dégâts) !';

  @override
  String get gotIt => 'COMPRIS !';

  @override
  String get paused => 'PAUSE';

  @override
  String get resume => 'REPRENDRE';

  @override
  String get saveGame => 'SAUVEGARDER';

  @override
  String get restart => 'RECOMMENCER';

  @override
  String get mainMenu => 'MENU PRINCIPAL';

  @override
  String savedToSlot(int slot) {
    return 'Sauvegardé dans l\'emplacement $slot';
  }

  @override
  String get gameOver => 'FIN DE PARTIE';

  @override
  String depthReached(int depth) {
    return 'Profondeur atteinte : ${depth}m';
  }

  @override
  String get tryAgain => 'RÉESSAYER';

  @override
  String get loadingDiggle => 'Chargement de Diggle...';

  @override
  String failedToLoadGame(String error) {
    return 'Échec du chargement :\n$error';
  }

  @override
  String get backToMenu => 'Retour au menu';

  @override
  String get signInWithEmail => 'SE CONNECTER PAR E-MAIL';

  @override
  String get signInWithWallet => 'SE CONNECTER PAR WALLET';

  @override
  String get playAsGuest => 'Jouer en tant qu\'invité';

  @override
  String get or => 'OU';

  @override
  String get createAccount => 'CRÉER UN COMPTE';

  @override
  String get signIn => 'SE CONNECTER';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordMinChars => 'Mot de passe (min. 6 caractères)';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get noAccount => 'Pas de compte ? Inscrivez-vous';

  @override
  String get checkEmailConfirm =>
      'Vérifiez vos e-mails pour confirmer votre compte !';

  @override
  String get invalidEmailPassword => 'E-mail ou mot de passe invalide';

  @override
  String get emailAlreadyRegistered => 'Un compte avec cet e-mail existe déjà';

  @override
  String get pleaseConfirmEmail => 'Veuillez d\'abord confirmer votre e-mail';

  @override
  String get networkError => 'Erreur réseau — vérifiez votre connexion';

  @override
  String get tooManyAttempts => 'Trop de tentatives — réessayez plus tard';

  @override
  String get cancelled => 'Annulé';

  @override
  String get pleaseFillFields =>
      'Veuillez entrer votre e-mail et votre mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordsNoMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get accountTitle => 'COMPTE';

  @override
  String get accountSubtitle => 'Profil, méthodes de connexion et statistiques';

  @override
  String get playerProfile => 'PROFIL DU JOUEUR';

  @override
  String get enterDisplayName => 'Entrez un pseudo';

  @override
  String get anonymousMiner => 'Mineur anonyme';

  @override
  String memberSince(String date) {
    return 'Membre depuis le $date';
  }

  @override
  String get playingOffline => 'Jeu hors ligne';

  @override
  String get playerIdCopied => 'ID du joueur copié';

  @override
  String get signInMethods => 'MÉTHODES DE CONNEXION';

  @override
  String get signInMethodsSubtitle => 'Comment accéder à votre compte';

  @override
  String get emailSignIn => 'Connexion par e-mail';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get solanaWallet => 'Wallet Solana';

  @override
  String get linkedWallet => 'Wallet lié';

  @override
  String get addEmailAlt =>
      'Ajouter un e-mail comme méthode de connexion alternative';

  @override
  String get linkForStore => 'Lier pour les achats et les NFT';

  @override
  String get primary => 'PRINCIPAL';

  @override
  String get linked => 'LIÉ';

  @override
  String get add => 'Ajouter';

  @override
  String get copyAddress => 'Copier l\'adresse';

  @override
  String get unlink => 'Délier';

  @override
  String get addEmailSignIn => 'Ajouter connexion par e-mail';

  @override
  String get addEmailSubtitle =>
      'Votre wallet reste votre connexion principale. L\'e-mail est une alternative.';

  @override
  String get addEmail => 'AJOUTER E-MAIL';

  @override
  String get checkEmailLink => 'Vérifiez vos e-mails pour confirmer le lien !';

  @override
  String get emailSignInAdded => 'Connexion par e-mail ajoutée !';

  @override
  String get walletConnectionCancelled => 'Connexion au wallet annulée';

  @override
  String get couldNotGetWalletAddress =>
      'Impossible d\'obtenir l\'adresse du wallet';

  @override
  String get signingCancelled => 'Signature annulée';

  @override
  String get walletLinked =>
      'Wallet lié ! Vous pouvez maintenant vous connecter avec.';

  @override
  String get walletLinkFailed => 'Échec de la liaison du wallet';

  @override
  String get unlinkWalletTitle => 'Délier le wallet';

  @override
  String get unlinkWalletMessage =>
      'Votre wallet sera retiré de votre compte. Vous pourrez lier un autre wallet ensuite.';

  @override
  String get cancel => 'Annuler';

  @override
  String get walletUnlinked => 'Wallet délié';

  @override
  String get unlinkFailed => 'Échec de la déliaison du wallet';

  @override
  String get walletAdapter => 'ADAPTATEUR WALLET';

  @override
  String get walletAdapterGuestSubtitle =>
      'Connectez-vous pour les achats de cette session';

  @override
  String get walletAdapterReconnectSubtitle =>
      'Reconnectez-vous pour signer les transactions';

  @override
  String get walletAdapterConnectSubtitle =>
      'Connectez-vous pour utiliser la boutique';

  @override
  String get network => 'Réseau';

  @override
  String get mainnet => 'Mainnet';

  @override
  String get devnet => 'Devnet';

  @override
  String connected(String network) {
    return 'Connecté — $network';
  }

  @override
  String get loadingBalance => 'Chargement du solde...';

  @override
  String get airdropRequested => 'Airdrop demandé !';

  @override
  String get airdropFailed => 'Échec de l\'airdrop';

  @override
  String get disconnectNote =>
      'La déconnexion met fin à la session de l\'adaptateur uniquement. Votre compte reste lié — reconnectez-vous à tout moment.';

  @override
  String get disconnectAdapter => 'DÉCONNECTER L\'ADAPTATEUR';

  @override
  String get connecting => 'Connexion...';

  @override
  String get connectWallet => 'CONNECTER LE WALLET';

  @override
  String get phantomTip =>
      '💡 Utilisez Phantom pour un meilleur support devnet';

  @override
  String get addressCopied => 'Adresse copiée';

  @override
  String get lifetimeStats => 'STATISTIQUES GLOBALES';

  @override
  String get statLevel => 'Niveau';

  @override
  String get statTotalXp => 'XP Total';

  @override
  String get statPoints => 'Points';

  @override
  String get statOresMined => 'Minerais extraits';

  @override
  String get statMaxDepth => 'Profondeur max';

  @override
  String get statPlayTime => 'Temps de jeu';

  @override
  String get statPointsEarned => 'Points gagnés';

  @override
  String get statPointsSpent => 'Points dépensés';

  @override
  String get signedInEmail => 'Connecté par e-mail';

  @override
  String get signedInWallet => 'Connecté par wallet';

  @override
  String get playingAsGuest => 'Joue en tant qu\'invité';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get signOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get guestSignOutWarning =>
      'La progression invité est uniquement sur cet appareil. La déconnexion supprimera l\'accès à vos sauvegardes actuelles. Êtes-vous sûr ?';

  @override
  String get emailAccount => 'Compte e-mail';

  @override
  String get walletAccount => 'Compte wallet';

  @override
  String get guestLocalOnly => 'Invité — progression locale uniquement';

  @override
  String get offline => 'Hors ligne';

  @override
  String get newGameTitle => 'NOUVELLE PARTIE';

  @override
  String get loadGameTitle => 'CHARGER UNE PARTIE';

  @override
  String get newGameSubtitle =>
      'Choisissez un emplacement pour votre nouvelle aventure';

  @override
  String get loadGameSubtitle => 'Sélectionnez une sauvegarde pour continuer';

  @override
  String slotEmpty(int slot) {
    return 'Emplacement $slot — Vide';
  }

  @override
  String get tapToStart => 'Appuyez pour commencer une nouvelle aventure';

  @override
  String get noSaveData => 'Pas de sauvegarde';

  @override
  String slot(int slot) {
    return 'Emplacement $slot';
  }

  @override
  String savedAgo(String time) {
    return 'Sauvegardé $time';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return 'Supprimer l\'emplacement $slot ?';
  }

  @override
  String get cannotBeUndone => 'Cette action est irréversible.';

  @override
  String get delete => 'SUPPRIMER';

  @override
  String get overwriteSaveTitle => 'Écraser la sauvegarde ?';

  @override
  String overwriteSaveMessage(int slot) {
    return 'L\'emplacement $slot contient déjà une sauvegarde. Commencer une nouvelle partie ici l\'écrasera.';
  }

  @override
  String get overwrite => 'ÉCRASER';

  @override
  String get noSaves => '(pas de sauvegardes)';

  @override
  String get justNow => 'à l\'instant';

  @override
  String minutesAgo(int min) {
    return 'il y a ${min}min';
  }

  @override
  String hoursAgo(int hours) {
    return 'il y a ${hours}h';
  }

  @override
  String daysAgo(int days) {
    return 'il y a ${days}j';
  }

  @override
  String get hp => 'PV';

  @override
  String get fuel => 'CARBURANT';

  @override
  String get items => 'OBJETS : ';

  @override
  String get store => 'BOUTIQUE';

  @override
  String get shop => 'BOUTIQUE';

  @override
  String depthMeter(int depth) {
    return '${depth}m';
  }

  @override
  String get miningSupplyCo => 'FOURNISSEUR MINIER';

  @override
  String get cash => 'Argent';

  @override
  String get hull => 'Coque';

  @override
  String get fuelLabel => 'Carburant';

  @override
  String get cargo => 'Soute';

  @override
  String get services => 'Services';

  @override
  String get upgrades => 'Améliorations';

  @override
  String get itemsTab => 'Objets';

  @override
  String get sellOre => 'VENDRE LE MINERAI';

  @override
  String get noOreToSell => 'Pas de minerai à vendre';

  @override
  String get totalValue => 'Valeur totale :';

  @override
  String get sellAll => 'TOUT VENDRE';

  @override
  String get refuel => 'RAVITAILLER';

  @override
  String refuelCost(int cost) {
    return 'RAVITAILLER ($cost\$)';
  }

  @override
  String get tankFull => 'Réservoir plein !';

  @override
  String get repair => 'RÉPARER';

  @override
  String repairHullCost(int cost) {
    return 'RÉPARER LA COQUE ($cost\$)';
  }

  @override
  String get hullFullyRepaired => 'Coque entièrement réparée !';

  @override
  String inventorySlots(int used, int max) {
    return 'Inventaire : $used/$max emplacements';
  }

  @override
  String upgradeCost(int cost) {
    return 'AMÉLIORER - $cost\$';
  }

  @override
  String get maxed => 'MAX';

  @override
  String get drillBit => 'Foret';

  @override
  String get engine => 'Moteur';

  @override
  String get cooling => 'Refroidissement';

  @override
  String get fuelTank => 'Réservoir';

  @override
  String get cargoBay => 'Soute';

  @override
  String get hullArmor => 'Blindage';

  @override
  String capacityValue(int value) {
    return 'Capacité : $value';
  }

  @override
  String speedPercent(int percent) {
    return 'Vitesse : $percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return 'Économie de carburant : $percent%';
  }

  @override
  String get noFuelSavings => 'Pas d\'économie de carburant';

  @override
  String maxHpValue(int value) {
    return 'PV max : $value';
  }

  @override
  String get returnToMining => 'RETOUR AU MINAGE';

  @override
  String soldOreFor(int amount) {
    return 'Minerai vendu pour $amount\$ !';
  }

  @override
  String get tankRefueled => 'Réservoir rempli !';

  @override
  String get fuelTankUpgraded => 'Réservoir amélioré !';

  @override
  String get cargoBayUpgraded => 'Soute améliorée !';

  @override
  String get hullRepaired => 'Coque réparée !';

  @override
  String get hullArmorUpgraded => 'Blindage amélioré !';

  @override
  String get drillBitUpgraded => 'Foret amélioré !';

  @override
  String get engineUpgraded => 'Moteur amélioré !';

  @override
  String get coolingUpgraded => 'Refroidissement amélioré !';

  @override
  String purchased(String item) {
    return '$item acheté !';
  }

  @override
  String get premiumStore => 'BOUTIQUE PREMIUM';

  @override
  String get onChainLoaded => 'Prix on-chain chargés';

  @override
  String get usingDefaultPrices => 'Utilisation des prix par défaut';

  @override
  String get level => 'Niveau';

  @override
  String get xp => 'XP';

  @override
  String get points => 'Points';

  @override
  String get activeBoosts => 'BOOSTS ACTIFS';

  @override
  String get permanent => 'Permanent';

  @override
  String get pointsTab => 'Points';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => 'Wallet requis';

  @override
  String get walletRequiredMessage =>
      'Connectez votre wallet Solana pour accéder aux objets premium.\nTous les achats sont des transactions on-chain.';

  @override
  String get storePricesUnavailable => 'Prix indisponibles';

  @override
  String get storePricesUnavailableMessage =>
      'Impossible de charger les prix on-chain.\nVeuillez vérifier votre connexion et réessayer.';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get buy => 'ACHETER';

  @override
  String get notEnoughPoints => 'Pas assez de points !';

  @override
  String activated(String item) {
    return '$item activé !';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$item acheté ! TX : $tx...';
  }

  @override
  String get purchaseFailed => 'Achat échoué';

  @override
  String get closeStore => 'FERMER LA BOUTIQUE';

  @override
  String get diggleDrillMachine => 'FOREUSE DIGGLE';

  @override
  String get permanentBoostNft => 'NFT de boost permanent — un par joueur';

  @override
  String get holderBenefits => 'AVANTAGES DU DÉTENTEUR';

  @override
  String get permanentXpBoost => 'Boost XP permanent';

  @override
  String get permanentPointsBoost => 'Boost de points permanent';

  @override
  String get limitedSupply => 'Quantité limitée';

  @override
  String get soldOut => 'ÉPUISÉ';

  @override
  String get allNftsMinted => 'Tous les NFT Diggle Drill ont été mintés !';

  @override
  String get mintOpensSoon => 'MINT BIENTÔT OUVERT';

  @override
  String startsAt(String date) {
    return 'Début : $date';
  }

  @override
  String get checkBackLater => 'Revenez plus tard !';

  @override
  String get mintNft => 'MINTER LE NFT';

  @override
  String mintCost(String cost) {
    return 'MINT — $cost SOL';
  }

  @override
  String get nftMinted => 'NFT minté ! 🎉';

  @override
  String get refresh => 'Actualiser';

  @override
  String get boostsActive => 'Vos boosts sont actifs en permanence !';

  @override
  String get mintStatusPreparing => 'Préparation de la transaction...';

  @override
  String get mintStatusApprove => 'Approuvez dans votre wallet...';

  @override
  String get mintStatusSending => 'Envoi de la transaction...';

  @override
  String get mintStatusConfirming => 'Confirmation on-chain...';

  @override
  String get mintStatusSuccess => 'Minté avec succès !';

  @override
  String get mintStatusError => 'Échec du mint';

  @override
  String xpLabel(int current, int next) {
    return 'XP : $current/$next';
  }

  @override
  String get settingsTitle => 'PARAMÈTRES';

  @override
  String get settingsSubtitle => 'Préférences de jeu';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez votre langue préférée';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get pleaseFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String errorPrefix(String message) {
    return 'Erreur : $message';
  }

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String get updateRequiredMessage =>
      'Cette version de Diggle n\'est plus prise en charge. Veuillez mettre à jour pour continuer à jouer.';

  @override
  String get currentVersionLabel => 'Actuelle';

  @override
  String get latestVersionLabel => 'Dernière';

  @override
  String get requiredVersionLabel => 'Requise';

  @override
  String get updateNow => 'METTRE À JOUR';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateOpenStoreFailed =>
      'Impossible d\'ouvrir le dApp Store. Veuillez mettre à jour manuellement.';

  @override
  String get light => 'Lumière';

  @override
  String get lightUpgraded => 'Système d\'éclairage amélioré !';

  @override
  String revealRadiusValue(int radius) {
    return 'Révélation : $radius cases';
  }

  @override
  String get questsTitle => 'QUÊTES';

  @override
  String get questsSubtitle => 'Complétez des quêtes pour gagner XP et points';

  @override
  String get questsDailyTab => 'Quotidiennes';

  @override
  String get questsSocialTab => 'Sociales';

  @override
  String get questsClaim => 'RÉCLAMER';

  @override
  String get questsClaimed => '✓ Réclamé';

  @override
  String get questsGo => 'GO';

  @override
  String get questsClose => 'FERMER';

  @override
  String get questsNoDailyQuests => 'Aucune quête quotidienne disponible';

  @override
  String get questsSocialInfo =>
      'Complétez des actions sociales pour gagner des récompenses uniques. Appuyez sur GO pour ouvrir le lien.';

  @override
  String get quests => 'QUÊTES';

  @override
  String questMineOreTitle(int count) {
    return 'Minez $count minerais';
  }

  @override
  String questMineOreDesc(int count) {
    return 'Minez $count cases de minerai en une seule journée';
  }

  @override
  String questReachDepthTitle(int depth) {
    return 'Atteignez ${depth}m';
  }

  @override
  String questReachDepthDesc(int depth) {
    return 'Atteignez une profondeur de ${depth}m ou plus';
  }

  @override
  String questSellOreTitle(int value) {
    return 'Vendez pour $value\$';
  }

  @override
  String questSellOreDesc(int value) {
    return 'Vendez du minerai pour un total de $value\$';
  }

  @override
  String questRepairTitle(int amount) {
    return 'Réparez $amount PV';
  }

  @override
  String questRepairDesc(int amount) {
    return 'Réparez un total de $amount PV de coque';
  }

  @override
  String questUseItemsTitle(int count) {
    return 'Utilisez $count objets';
  }

  @override
  String questUseItemsDesc(int count) {
    return 'Utilisez $count objets de votre inventaire';
  }

  @override
  String get questFollowTwitterTitle => 'Suivez sur X';

  @override
  String get questFollowTwitterDesc => 'Suivez @DiggleGame sur X (Twitter)';

  @override
  String get questJoinDiscordTitle => 'Rejoindre Discord';

  @override
  String get questJoinDiscordDesc =>
      'Rejoignez la communauté Discord de Diggle';

  @override
  String get questPostTweetTitle => 'Partager sur X';

  @override
  String get questPostTweetDesc => 'Publiez un tweet sur Diggle';

  @override
  String get questVerifyButton => 'Vérifier';

  @override
  String get questPasteTweetUrl => 'Collez l\'URL de votre tweet ici';

  @override
  String get questVerifying => 'Vérification...';

  @override
  String get questVerified => 'Quête vérifiée et complétée !';

  @override
  String get questVerificationFailed =>
      'Impossible de vérifier. Veuillez réessayer.';

  @override
  String get loginStreak => 'Série quotidienne';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: 'Aucune série',
    );
    return '$_temp0';
  }

  @override
  String get streakClaimedToday => 'Récupéré aujourd\'hui';

  @override
  String get streakPlayToday => 'Jouez aujourd\'hui pour la conserver';

  @override
  String get streakStartToday => 'Jouez aujourd\'hui pour lancer une série';

  @override
  String streakNextReward(int xp, int points) {
    return 'Prochain : +$xp XP, +$points pts';
  }

  @override
  String get streakJackpotReached =>
      'Palier maximal — récompense quotidienne max';

  @override
  String streakToJackpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours avant le jackpot',
      one: '1 jour avant le jackpot',
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
