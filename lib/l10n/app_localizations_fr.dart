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
  String get menuWeeklyChallenge => 'Défi hebdomadaire';

  @override
  String get menuLeaderboard => 'Classement';

  @override
  String get menuHangar => 'Hangar';

  @override
  String get museumTitle => 'MUSÉE';

  @override
  String get achievementsTab => 'SUCCÈS';

  @override
  String get leaderboardHeading => '🏆 CLASSEMENT';

  @override
  String get leaderboardEmpty =>
      'Aucune entrée pour l\'instant.\nSoyez le premier au classement !';

  @override
  String get hangarHeading => '🛠️ HANGAR';

  @override
  String hangarMachineCount(int count) {
    return '$count Diggle Machines dans ce wallet — une seule peut être équipée à la fois.';
  }

  @override
  String get hangarSeekerVerified => 'SEEKER GENESIS VÉRIFIÉ';

  @override
  String get hangarSeekerBlurb =>
      'Pionnier Solana Mobile — +5% XP et points, toujours actif.';

  @override
  String get hangarSealedCrate => 'CAISSE SCELLÉE';

  @override
  String get hangarSealedBlurb =>
      'Cette machine n\'a pas encore été révélée. En attendant, elle accorde le boost de détenteur fixe de +25% XP et points.\n\nAprès la révélation, ses cinq traits (coque, propulseur, réservoir, foret, soute) deviennent équipables avec des bonus liés à leur rareté. Touchez Actualiser le jour de la révélation !';

  @override
  String get hangarEquipped =>
      '✅ Équipée — bonus actifs en parties normales.\nLe défi hebdomadaire utilise un équipement standardisé (sans gear).';

  @override
  String get quantity => 'Quantité';

  @override
  String get airdrop => 'Airdrop';

  @override
  String get questsWeeklyTab => 'Hebdomadaires';

  @override
  String get questsWeeklyInfo =>
      'Grands défis, grandes récompenses. Réinitialisé chaque lundi (UTC).';

  @override
  String questsNotEnoughPoints(int cost) {
    return 'Points insuffisants ($cost requis). Prenez un pack de points dans la boutique !';
  }

  @override
  String get questJoinDiscordServer => 'Rejoindre le serveur Discord';

  @override
  String get questCheckingMembership => 'Vérification de l\'adhésion...';

  @override
  String get questVerifyMembership => 'Vérifier l\'adhésion';

  @override
  String get questDiscordHint =>
      'Rejoignez d\'abord le serveur, puis touchez Vérifier pour confirmer avec Discord';

  @override
  String get questPostOnX => 'Publier sur X';

  @override
  String get questTweetHint =>
      'Publiez le tweet ci-dessus, puis collez l\'URL pour vérifier';

  @override
  String get questDiscordUnavailable =>
      'La vérification Discord n\'est pas disponible. Réessayez plus tard.';

  @override
  String get questDiscordOpenFailed =>
      'Impossible d\'ouvrir Discord. Veuillez réessayer.';

  @override
  String get questDiscordVerified => 'Adhésion Discord vérifiée ! 🎉';

  @override
  String get questDiscordVerifyFailed =>
      'Impossible de vérifier l\'adhésion. Assurez-vous d\'avoir rejoint le serveur et autorisé Discord.';

  @override
  String get signNewContract => 'Signer un nouveau contrat';

  @override
  String get corporateContract => '⭐ Contrat corporatif';

  @override
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  ) {
    return 'Signer le contrat n° $level ?\n\nRÉINITIALISÉ : monde, argent, améliorations du vaisseau\nCONSERVÉ : XP, points, NFT, succès, collection\n\nAVANTAGES PERMANENTS :\n• +$sellBonus% sur le prix de vente du minerai\n• $startCash\$ de départ + kit de démarrage\n$hardcore• Badge $badge au classement';
  }

  @override
  String get prestigeHardcoreLine =>
      '• Filons hardcore : minerai plus riche, dangers plus mortels\n';

  @override
  String get notYet => 'Pas encore';

  @override
  String get signContract => 'Signer le contrat';

  @override
  String get recoveryFailedPoints => 'Sauvetage échoué — points insuffisants';

  @override
  String emergencyRecoveryCost(int cost) {
    return 'Sauvetage d\'urgence ($cost pts)';
  }

  @override
  String emergencyRecoveryNeed(int cost) {
    return 'Il faut $cost pts — ouvrez la boutique';
  }

  @override
  String keepsCargo(int value) {
    return 'Vous gardez votre chargement de $value\$ !';
  }

  @override
  String titleUnlocked(String title) {
    return 'Titre débloqué : $title';
  }

  @override
  String get titleProspector => 'Prospecteur';

  @override
  String get titleExcavator => 'Excavateur';

  @override
  String get titleDemolitionist => 'Démolisseur';

  @override
  String get titleDeepMiner => 'Mineur des profondeurs';

  @override
  String get titleVoidwalker => 'Marcheur du vide';

  @override
  String get titleCoreBreaker => 'Briseur de noyau';

  @override
  String get titleDiggleLegend => 'Légende de Diggle';

  @override
  String get artifactTsFossilFern => 'Fougère fossilisée';

  @override
  String get artifactTsFossilFernDesc =>
      'L\'empreinte parfaite d\'une fougère préhistorique.';

  @override
  String get artifactTsOldBoot => 'Botte de prospecteur';

  @override
  String get artifactTsOldBootDesc =>
      'Quelqu\'un a creusé ici bien avant vous.';

  @override
  String get artifactTsClayJar => 'Jarre d\'argile';

  @override
  String get artifactTsClayJarDesc =>
      'Un récipient ancien, miraculeusement intact.';

  @override
  String get artifactTsArrowhead => 'Pointe de flèche en silex';

  @override
  String get artifactTsArrowheadDesc =>
      'Taillée par des mains disparues depuis dix mille ans.';

  @override
  String get artifactTsCoinHoard => 'Trésor de pièces';

  @override
  String get artifactTsCoinHoardDesc =>
      'Pièces corrodées d\'un atelier monétaire oublié.';

  @override
  String get artifactPfMammothTusk => 'Défense de mammouth';

  @override
  String get artifactPfMammothTuskDesc => 'Ivoire courbé, froid au toucher.';

  @override
  String get artifactPfIceLens => 'Lentille de glace';

  @override
  String get artifactPfIceLensDesc =>
      'Une lentille formée naturellement dans une glace ancienne.';

  @override
  String get artifactPfFrozenFlower => 'Fleur gelée';

  @override
  String get artifactPfFrozenFlowerDesc =>
      'Une fleur figée en pleine éclosion depuis des millénaires.';

  @override
  String get artifactPfSledRunner => 'Patin de traîneau';

  @override
  String get artifactPfSledRunnerDesc =>
      'Vestige d\'une expédition qui n\'est jamais revenue.';

  @override
  String get artifactPfAmberInsect => 'Insecte dans l\'ambre';

  @override
  String get artifactPfAmberInsectDesc =>
      'Un minuscule passager figé dans une résine dorée.';

  @override
  String get artifactCcSingingGeode => 'Géode chantante';

  @override
  String get artifactCcSingingGeodeDesc =>
      'Elle fredonne une note juste sous le seuil de l\'audible.';

  @override
  String get artifactCcPrismCore => 'Cœur de prisme';

  @override
  String get artifactCcPrismCoreDesc =>
      'Divise la lumière de la lampe en couleurs sans nom.';

  @override
  String get artifactCcPetrifiedEye => 'Œil pétrifié';

  @override
  String get artifactCcPetrifiedEyeDesc =>
      'Vous êtes certain qu\'il vous observait.';

  @override
  String get artifactCcResonantShard => 'Éclat résonnant';

  @override
  String get artifactCcResonantShardDesc =>
      'Vibre lorsque d\'autres cristaux sont proches.';

  @override
  String get artifactCcHollowBell => 'Cloche creuse';

  @override
  String get artifactCcHollowBellDesc =>
      'Une cloche de cristal qui sonne dans le silence.';

  @override
  String get artifactMcObsidianBlade => 'Lame d\'obsidienne';

  @override
  String get artifactMcObsidianBladeDesc =>
      'Verre volcanique, plus tranchant que n\'importe quel foret.';

  @override
  String get artifactMcFireOpal => 'Opale de feu';

  @override
  String get artifactMcFireOpalDesc =>
      'Une pierre avec une braise vivante à l\'intérieur.';

  @override
  String get artifactMcBasaltIdol => 'Idole de basalte';

  @override
  String get artifactMcBasaltIdolDesc =>
      'Sculptée par quelque chose qui aimait la chaleur.';

  @override
  String get artifactMcMeteorFragment => 'Fragment de météore';

  @override
  String get artifactMcMeteorFragmentDesc =>
      'Tombé d\'en haut, il a sombré jusqu\'ici.';

  @override
  String get artifactMcHeartOfCore => 'Cœur du noyau';

  @override
  String get artifactMcHeartOfCoreDesc => 'Encore chaud. Bat-il encore ?';

  @override
  String get achievementOre10 => 'Premier chargement';

  @override
  String get achievementOre10Desc => 'Minez 10 minerais';

  @override
  String get achievementOre100 => 'Limier du minerai';

  @override
  String get achievementOre100Desc => 'Minez 100 minerais';

  @override
  String get achievementOre500 => 'Chasseur de filons';

  @override
  String get achievementOre500Desc => 'Minez 500 minerais';

  @override
  String get achievementOre2000 => 'Mineur à ciel ouvert';

  @override
  String get achievementOre2000Desc => 'Minez 2 000 minerais';

  @override
  String get achievementOre10000 => 'Dévoreur de planète';

  @override
  String get achievementOre10000Desc => 'Minez 10 000 minerais';

  @override
  String get achievementDepth50 => 'Sous les racines';

  @override
  String get achievementDepth50Desc => 'Atteignez la profondeur 50';

  @override
  String get achievementDepth120 => 'Dans le givre';

  @override
  String get achievementDepth120Desc =>
      'Atteignez le Pergélisol (profondeur 120)';

  @override
  String get achievementDepth240 => 'Liseur de cristal';

  @override
  String get achievementDepth240Desc =>
      'Atteignez les Cavernes de Cristal (profondeur 240)';

  @override
  String get achievementDepth360 => 'Plongeur de magma';

  @override
  String get achievementDepth360Desc =>
      'Atteignez le Noyau de Magma (profondeur 360)';

  @override
  String get achievementDepth445 => 'Le fond du fond';

  @override
  String get achievementDepth445Desc =>
      'Touchez le plancher du monde (profondeur 445)';

  @override
  String get achievementCash1k => 'Argent de poche';

  @override
  String get achievementCash1kDesc => 'Gagnez 1 000 \$ au total';

  @override
  String get achievementCash25k => 'Mineur d\'affaires';

  @override
  String get achievementCash25kDesc => 'Gagnez 25 000 \$ au total';

  @override
  String get achievementCash250k => 'Baron du minerai';

  @override
  String get achievementCash250kDesc => 'Gagnez 250 000 \$ au total';

  @override
  String get achievementCash1m => 'Magnat de Diggle';

  @override
  String get achievementCash1mDesc => 'Gagnez 1 000 000 \$ au total';

  @override
  String get achievementLevel5 => 'Ça devient sérieux';

  @override
  String get achievementLevel5Desc => 'Atteignez le niveau 5';

  @override
  String get achievementLevel10 => 'Deux chiffres';

  @override
  String get achievementLevel10Desc => 'Atteignez le niveau 10';

  @override
  String get achievementLevel18 => 'Vétéran des profondeurs';

  @override
  String get achievementLevel18Desc => 'Atteignez le niveau 18';

  @override
  String get achievementLevel25 => 'Diggle au maximum';

  @override
  String get achievementLevel25Desc => 'Atteignez le niveau 25';

  @override
  String get achievementArtifact1 => 'Archéologue amateur';

  @override
  String get achievementArtifact1Desc => 'Trouvez votre premier artefact';

  @override
  String get achievementArtifact10 => 'Donateur du musée';

  @override
  String get achievementArtifact10Desc => 'Trouvez 10 artefacts';

  @override
  String get achievementArtifact20 => 'Conservateur en chef';

  @override
  String get achievementArtifact20Desc => 'Complétez toute la collection';

  @override
  String get achievementBlast5 => 'Attention, ça explose !';

  @override
  String get achievementBlast5Desc => 'Faites exploser 5 explosifs';

  @override
  String get achievementBlast50 => 'Démolition contrôlée';

  @override
  String get achievementBlast50Desc => 'Faites exploser 50 explosifs';

  @override
  String get achievementSales10 => 'Client fidèle';

  @override
  String get achievementSales10Desc => 'Vendez du minerai 10 fois';

  @override
  String get achievementSales100 => 'Faiseur de marché';

  @override
  String get achievementSales100Desc => 'Vendez du minerai 100 fois';

  @override
  String get achievementDeath1 => 'Risque du métier';

  @override
  String get achievementDeath1Desc => 'Perdez votre première foreuse';

  @override
  String get achievementDeath25 => 'Jamais abattu';

  @override
  String get achievementDeath25Desc =>
      'Perdez 25 foreuses et continuez à creuser';

  @override
  String get itemBackupFuel => 'Carburant de secours';

  @override
  String get itemRepairBot => 'Robot de réparation';

  @override
  String get itemDynamite => 'Dynamite';

  @override
  String get itemC4 => 'C4';

  @override
  String get itemSpaceRift => 'Faille spatiale';

  @override
  String get itemOreScanner => 'Scanner de minerai';

  @override
  String get itemHeatShield => 'Bouclier thermique';

  @override
  String get tileEmpty => 'Vide';

  @override
  String get tileDirt => 'Terre';

  @override
  String get tileRock => 'Roche';

  @override
  String get tileCoal => 'Charbon';

  @override
  String get tileCopper => 'Cuivre';

  @override
  String get tileSilver => 'Argent';

  @override
  String get tileGold => 'Or';

  @override
  String get tileSapphire => 'Saphir';

  @override
  String get tileEmerald => 'Émeraude';

  @override
  String get tileRuby => 'Rubis';

  @override
  String get tileDiamond => 'Diamant';

  @override
  String get tileLava => 'Lave';

  @override
  String get tileGas => 'Poche de gaz';

  @override
  String get tileFrozenDirt => 'Terre gelée';

  @override
  String get tileMagmaRock => 'Roche de magma';

  @override
  String get tileCrystalOre => 'Cristal';

  @override
  String get tileUnstableRock => 'Roche instable';

  @override
  String get tileLootCrate => 'Caisse de ravitaillement';

  @override
  String get tileArtifact => 'Artefact';

  @override
  String get tileBedrock => 'Roche-mère';

  @override
  String questUseExplosivesTitle(int count) {
    return 'Faites exploser $count explosifs';
  }

  @override
  String questUseExplosivesDesc(int count) {
    return 'Utilisez de la dynamite ou du C4 $count fois';
  }

  @override
  String questFindArtifactTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trouvez $count artefacts',
      one: 'Trouvez un artefact',
    );
    return '$_temp0';
  }

  @override
  String get questFindArtifactDesc => 'Déterrez des artefacts dans les ruines';

  @override
  String questOpenCrateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ouvrez $count caisses de ravitaillement',
      one: 'Ouvrez une caisse de ravitaillement',
    );
    return '$_temp0';
  }

  @override
  String get questOpenCrateDesc =>
      'Ouvrez des caisses de ravitaillement dans les puits abandonnés';

  @override
  String get rarityCommon => 'Commun';

  @override
  String get rarityUncommon => 'Peu commun';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Épique';

  @override
  String get rarityLegendary => 'Légendaire';

  @override
  String get itemBackupFuelDesc => 'Restaure 50 de carburant';

  @override
  String get itemRepairBotDesc => 'Répare 40 PV de coque';

  @override
  String get itemDynamiteDesc => 'Fait sauter une zone de 3x3';

  @override
  String get itemC4Desc => 'Fait sauter une zone de 5x5';

  @override
  String get itemSpaceRiftDesc => 'Téléportation vers la surface';

  @override
  String get itemOreScannerDesc => 'Révèle le terrain sur un large rayon';

  @override
  String get itemHeatShieldDesc => '60 s d\'immunité à la lave';

  @override
  String get biomeTopsoil => 'COUCHE DE SURFACE';

  @override
  String get biomePermafrost => 'PERGÉLISOL';

  @override
  String get biomeCrystalCaverns => 'CAVERNES DE CRISTAL';

  @override
  String get biomeMagmaCore => 'NOYAU DE MAGMA';

  @override
  String get museumArtifactsTab => 'ARTEFACTS';

  @override
  String get museumRecordsTab => 'RECORDS';

  @override
  String get leaderboardDepthTab => 'MÈTRES';

  @override
  String get leaderboardPointsTab => 'POINTS';

  @override
  String get leaderboardWeeklyTab => 'CETTE SEMAINE';
}
