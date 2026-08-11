// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline =>
      'EXCAVA PROFUNDO  •  EXTRAE RIQUEZAS  •  LLEGA MÁS LEJOS';

  @override
  String get mineDeepEarnRewards => 'Excava profundo. Gana recompensas.';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => 'NUEVA PARTIDA';

  @override
  String get continueGame => 'CONTINUAR';

  @override
  String get loadGame => 'CARGAR';

  @override
  String get account => 'CUENTA';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String comingSoon(String feature) {
    return '¡$feature próximamente!';
  }

  @override
  String get helpMiningTitle => '⛏️ Minería';

  @override
  String get helpMiningBody =>
      'Usa los controles de dirección para mover tu taladro. Excava tierra y roca para encontrar minerales valiosos.';

  @override
  String get helpFuelTitle => '⛽ Combustible';

  @override
  String get helpFuelBody =>
      'Moverse y excavar consume combustible. ¡Regresa a la superficie antes de quedarte sin él!';

  @override
  String get helpHullTitle => '🛡️ Casco';

  @override
  String get helpHullBody => 'Caer demasiado daña tu casco. ¡Vigila tus PV!';

  @override
  String get helpSellingTitle => '💰 Venta';

  @override
  String get helpSellingBody =>
      'Regresa a la superficie y visita la TIENDA para vender tu mineral por dinero.';

  @override
  String get helpUpgradesTitle => '🔧 Mejoras';

  @override
  String get helpUpgradesBody =>
      'Usa el dinero para mejorar tu tanque de combustible, bodega de carga y blindaje.';

  @override
  String get helpHazardsTitle => '⚠️ Peligros';

  @override
  String get helpHazardsBody =>
      '¡Cuidado con la lava (muerte instantánea) y las bolsas de gas (daño)!';

  @override
  String get gotIt => '¡ENTENDIDO!';

  @override
  String get paused => 'PAUSA';

  @override
  String get resume => 'REANUDAR';

  @override
  String get saveGame => 'GUARDAR';

  @override
  String get restart => 'REINICIAR';

  @override
  String get mainMenu => 'MENÚ PRINCIPAL';

  @override
  String savedToSlot(int slot) {
    return 'Guardado en ranura $slot';
  }

  @override
  String get gameOver => 'FIN DEL JUEGO';

  @override
  String depthReached(int depth) {
    return 'Profundidad alcanzada: ${depth}m';
  }

  @override
  String get tryAgain => 'REINTENTAR';

  @override
  String get loadingDiggle => 'Cargando Diggle...';

  @override
  String failedToLoadGame(String error) {
    return 'Error al cargar:\n$error';
  }

  @override
  String get backToMenu => 'Volver al menú';

  @override
  String get signInWithEmail => 'INICIAR CON E-MAIL';

  @override
  String get signInWithWallet => 'INICIAR CON WALLET';

  @override
  String get playAsGuest => 'Jugar como invitado';

  @override
  String get or => 'O';

  @override
  String get createAccount => 'CREAR CUENTA';

  @override
  String get signIn => 'INICIAR SESIÓN';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordMinChars => 'Contraseña (mín. 6 caracteres)';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get checkEmailConfirm => '¡Revisa tu correo para confirmar tu cuenta!';

  @override
  String get invalidEmailPassword => 'Correo o contraseña inválidos';

  @override
  String get emailAlreadyRegistered => 'Ya existe una cuenta con este correo';

  @override
  String get pleaseConfirmEmail => 'Por favor confirma tu correo primero';

  @override
  String get networkError => 'Error de red — revisa tu conexión';

  @override
  String get tooManyAttempts => 'Demasiados intentos — inténtalo más tarde';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get pleaseFillFields => 'Ingresa tu correo y contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsNoMatch => 'Las contraseñas no coinciden';

  @override
  String get accountTitle => 'CUENTA';

  @override
  String get accountSubtitle =>
      'Perfil, métodos de inicio de sesión y estadísticas';

  @override
  String get playerProfile => 'PERFIL DEL JUGADOR';

  @override
  String get enterDisplayName => 'Ingresa un nombre para mostrar';

  @override
  String get anonymousMiner => 'Minero anónimo';

  @override
  String memberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get playingOffline => 'Jugando sin conexión';

  @override
  String get playerIdCopied => 'ID del jugador copiado';

  @override
  String get signInMethods => 'MÉTODOS DE INICIO';

  @override
  String get signInMethodsSubtitle => 'Cómo puedes acceder a tu cuenta';

  @override
  String get emailSignIn => 'Inicio por correo';

  @override
  String get emailLabel => 'Correo';

  @override
  String get solanaWallet => 'Wallet Solana';

  @override
  String get linkedWallet => 'Wallet vinculada';

  @override
  String get addEmailAlt =>
      'Añadir correo como forma alternativa de iniciar sesión';

  @override
  String get linkForStore => 'Vincular para compras y NFTs';

  @override
  String get primary => 'PRINCIPAL';

  @override
  String get linked => 'VINCULADO';

  @override
  String get add => 'Añadir';

  @override
  String get copyAddress => 'Copiar dirección';

  @override
  String get unlink => 'Desvincular';

  @override
  String get addEmailSignIn => 'Añadir inicio por correo';

  @override
  String get addEmailSubtitle =>
      'Tu wallet sigue siendo tu inicio principal. El correo es una alternativa.';

  @override
  String get addEmail => 'AÑADIR CORREO';

  @override
  String get checkEmailLink => '¡Revisa tu correo para confirmar el vínculo!';

  @override
  String get emailSignInAdded => '¡Inicio por correo añadido!';

  @override
  String get walletConnectionCancelled => 'Conexión de wallet cancelada';

  @override
  String get couldNotGetWalletAddress =>
      'No se pudo obtener la dirección de la wallet';

  @override
  String get signingCancelled => 'Firma cancelada';

  @override
  String get walletLinked =>
      '¡Wallet vinculada! Ahora puedes iniciar sesión con ella.';

  @override
  String get walletLinkFailed => 'Error al vincular la wallet';

  @override
  String get unlinkWalletTitle => 'Desvincular wallet';

  @override
  String get unlinkWalletMessage =>
      'Tu wallet será eliminada de tu cuenta. Puedes vincular otra wallet después.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get walletUnlinked => 'Wallet desvinculada';

  @override
  String get unlinkFailed => 'Error al desvincular la wallet';

  @override
  String get walletAdapter => 'ADAPTADOR DE WALLET';

  @override
  String get walletAdapterGuestSubtitle =>
      'Conéctate para compras en esta sesión';

  @override
  String get walletAdapterReconnectSubtitle =>
      'Reconéctate para firmar transacciones';

  @override
  String get walletAdapterConnectSubtitle => 'Conéctate para usar la tienda';

  @override
  String get network => 'Red';

  @override
  String get mainnet => 'Mainnet';

  @override
  String get devnet => 'Devnet';

  @override
  String connected(String network) {
    return 'Conectado — $network';
  }

  @override
  String get loadingBalance => 'Cargando saldo...';

  @override
  String get airdropRequested => '¡Airdrop solicitado!';

  @override
  String get airdropFailed => 'Airdrop fallido';

  @override
  String get disconnectNote =>
      'Desconectar solo finaliza la sesión del adaptador. Tu cuenta sigue vinculada — reconéctate en cualquier momento.';

  @override
  String get disconnectAdapter => 'DESCONECTAR ADAPTADOR';

  @override
  String get connecting => 'Conectando...';

  @override
  String get connectWallet => 'CONECTAR WALLET';

  @override
  String get phantomTip => '💡 Usa Phantom para mejor soporte en devnet';

  @override
  String get addressCopied => 'Dirección copiada';

  @override
  String get lifetimeStats => 'ESTADÍSTICAS GLOBALES';

  @override
  String get statLevel => 'Nivel';

  @override
  String get statTotalXp => 'XP Total';

  @override
  String get statPoints => 'Puntos';

  @override
  String get statOresMined => 'Minerales extraídos';

  @override
  String get statMaxDepth => 'Profundidad máx.';

  @override
  String get statPlayTime => 'Tiempo de juego';

  @override
  String get statPointsEarned => 'Puntos ganados';

  @override
  String get statPointsSpent => 'Puntos gastados';

  @override
  String get signedInEmail => 'Sesión con correo';

  @override
  String get signedInWallet => 'Sesión con wallet';

  @override
  String get playingAsGuest => 'Jugando como invitado';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get guestSignOutWarning =>
      'El progreso de invitado solo está en este dispositivo. Cerrar sesión eliminará el acceso a tus partidas guardadas. ¿Estás seguro?';

  @override
  String get emailAccount => 'Cuenta de correo';

  @override
  String get walletAccount => 'Cuenta de wallet';

  @override
  String get guestLocalOnly => 'Invitado — progreso solo local';

  @override
  String get offline => 'Sin conexión';

  @override
  String get newGameTitle => 'NUEVA PARTIDA';

  @override
  String get loadGameTitle => 'CARGAR PARTIDA';

  @override
  String get newGameSubtitle => 'Elige una ranura para tu nueva aventura';

  @override
  String get loadGameSubtitle =>
      'Selecciona una partida guardada para continuar';

  @override
  String slotEmpty(int slot) {
    return 'Ranura $slot — Vacía';
  }

  @override
  String get tapToStart => 'Toca para iniciar una nueva aventura';

  @override
  String get noSaveData => 'Sin datos guardados';

  @override
  String slot(int slot) {
    return 'Ranura $slot';
  }

  @override
  String savedAgo(String time) {
    return 'Guardado $time';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return '¿Eliminar ranura $slot?';
  }

  @override
  String get cannotBeUndone => 'Esto no se puede deshacer.';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get overwriteSaveTitle => '¿Sobrescribir?';

  @override
  String overwriteSaveMessage(int slot) {
    return 'La ranura $slot ya tiene una partida. Empezar aquí la sobrescribirá.';
  }

  @override
  String get overwrite => 'SOBRESCRIBIR';

  @override
  String get noSaves => '(sin partidas)';

  @override
  String get justNow => 'ahora mismo';

  @override
  String minutesAgo(int min) {
    return 'hace ${min}min';
  }

  @override
  String hoursAgo(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String daysAgo(int days) {
    return 'hace ${days}d';
  }

  @override
  String get hp => 'PV';

  @override
  String get fuel => 'COMBUSTIBLE';

  @override
  String get items => 'OBJETOS: ';

  @override
  String get store => 'TIENDA';

  @override
  String get shop => 'TIENDA';

  @override
  String depthMeter(int depth) {
    return '${depth}m';
  }

  @override
  String get miningSupplyCo => 'SUMINISTROS MINEROS';

  @override
  String get cash => 'Dinero';

  @override
  String get hull => 'Casco';

  @override
  String get fuelLabel => 'Combustible';

  @override
  String get cargo => 'Bodega';

  @override
  String get services => 'Servicios';

  @override
  String get upgrades => 'Mejoras';

  @override
  String get itemsTab => 'Objetos';

  @override
  String get sellOre => 'VENDER MINERAL';

  @override
  String get noOreToSell => 'No hay mineral para vender';

  @override
  String get totalValue => 'Valor total:';

  @override
  String get sellAll => 'VENDER TODO';

  @override
  String get refuel => 'RECARGAR';

  @override
  String refuelCost(int cost) {
    return 'RECARGAR (\$$cost)';
  }

  @override
  String get tankFull => '¡Tanque lleno!';

  @override
  String get repair => 'REPARAR';

  @override
  String repairHullCost(int cost) {
    return 'REPARAR CASCO (\$$cost)';
  }

  @override
  String get hullFullyRepaired => '¡Casco totalmente reparado!';

  @override
  String inventorySlots(int used, int max) {
    return 'Inventario: $used/$max espacios';
  }

  @override
  String upgradeCost(int cost) {
    return 'MEJORAR - \$$cost';
  }

  @override
  String get maxed => 'AL MÁXIMO';

  @override
  String get drillBit => 'Broca';

  @override
  String get engine => 'Motor';

  @override
  String get cooling => 'Refrigeración';

  @override
  String get fuelTank => 'Tanque';

  @override
  String get cargoBay => 'Bodega';

  @override
  String get hullArmor => 'Blindaje';

  @override
  String capacityValue(int value) {
    return 'Capacidad: $value';
  }

  @override
  String speedPercent(int percent) {
    return 'Velocidad: $percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return 'Ahorro de combustible: $percent%';
  }

  @override
  String get noFuelSavings => 'Sin ahorro de combustible';

  @override
  String maxHpValue(int value) {
    return 'PV máx: $value';
  }

  @override
  String get returnToMining => 'VOLVER A MINAR';

  @override
  String soldOreFor(int amount) {
    return '¡Mineral vendido por \$$amount!';
  }

  @override
  String get tankRefueled => '¡Tanque recargado!';

  @override
  String get fuelTankUpgraded => '¡Tanque mejorado!';

  @override
  String get cargoBayUpgraded => '¡Bodega mejorada!';

  @override
  String get hullRepaired => '¡Casco reparado!';

  @override
  String get hullArmorUpgraded => '¡Blindaje mejorado!';

  @override
  String get drillBitUpgraded => '¡Broca mejorada!';

  @override
  String get engineUpgraded => '¡Motor mejorado!';

  @override
  String get coolingUpgraded => '¡Refrigeración mejorada!';

  @override
  String purchased(String item) {
    return '¡$item comprado!';
  }

  @override
  String get premiumStore => 'TIENDA PREMIUM';

  @override
  String get onChainLoaded => 'Precios on-chain cargados';

  @override
  String get usingDefaultPrices => 'Usando precios por defecto';

  @override
  String get level => 'Nivel';

  @override
  String get xp => 'XP';

  @override
  String get points => 'Puntos';

  @override
  String get activeBoosts => 'MEJORAS ACTIVAS';

  @override
  String get permanent => 'Permanente';

  @override
  String get pointsTab => 'Puntos';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => 'Wallet requerida';

  @override
  String get walletRequiredMessage =>
      'Conecta tu wallet Solana para acceder a artículos premium.\nTodas las compras son transacciones on-chain.';

  @override
  String get storePricesUnavailable => 'Precios no disponibles';

  @override
  String get storePricesUnavailableMessage =>
      'No se pudieron cargar los precios on-chain.\nRevisa tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get buy => 'COMPRAR';

  @override
  String get notEnoughPoints => '¡Puntos insuficientes!';

  @override
  String activated(String item) {
    return '¡$item activado!';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '¡$item comprado! TX: $tx...';
  }

  @override
  String get purchaseFailed => 'Compra fallida';

  @override
  String get closeStore => 'CERRAR TIENDA';

  @override
  String get diggleDrillMachine => 'TALADRO DIGGLE';

  @override
  String get permanentBoostNft => 'NFT de mejora permanente — uno por jugador';

  @override
  String get holderBenefits => 'BENEFICIOS DEL TITULAR';

  @override
  String get permanentXpBoost => 'Mejora de XP permanente';

  @override
  String get permanentPointsBoost => 'Mejora de puntos permanente';

  @override
  String get limitedSupply => 'Suministro limitado';

  @override
  String get soldOut => 'AGOTADO';

  @override
  String get allNftsMinted => '¡Todos los NFT Diggle Drill han sido acuñados!';

  @override
  String get mintOpensSoon => 'ACUÑACIÓN PRÓXIMAMENTE';

  @override
  String startsAt(String date) {
    return 'Inicio: $date';
  }

  @override
  String get checkBackLater => '¡Vuelve más tarde!';

  @override
  String get mintNft => 'ACUÑAR NFT';

  @override
  String mintCost(String cost) {
    return 'ACUÑAR — $cost SOL';
  }

  @override
  String get nftMinted => '¡NFT acuñado! 🎉';

  @override
  String get refresh => 'Actualizar';

  @override
  String get boostsActive => '¡Tus mejoras están activas permanentemente!';

  @override
  String get mintStatusPreparing => 'Preparando transacción...';

  @override
  String get mintStatusApprove => 'Aprueba en tu wallet...';

  @override
  String get mintStatusSending => 'Enviando transacción...';

  @override
  String get mintStatusConfirming => 'Confirmando en cadena...';

  @override
  String get mintStatusSuccess => '¡Acuñado con éxito!';

  @override
  String get mintStatusError => 'Error al acuñar';

  @override
  String xpLabel(int current, int next) {
    return 'XP: $current/$next';
  }

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get settingsSubtitle => 'Preferencias del juego';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Elige tu idioma preferido';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get vfxQualitySection => 'Efectos visuales';

  @override
  String get vfxQualitySubtitle =>
      'Partículas, vibración de pantalla y destellos de impacto';

  @override
  String get vfxQualityFull => 'Completos';

  @override
  String get vfxQualityFullDesc => 'Todos los efectos a máxima densidad';

  @override
  String get vfxQualityLow => 'Reducidos';

  @override
  String get vfxQualityLowDesc => 'Menos partículas — menor consumo de batería';

  @override
  String get vfxQualityOff => 'Desactivados';

  @override
  String get vfxQualityOffDesc => 'Sin partículas ni vibración de pantalla';

  @override
  String get pleaseFillAllFields => 'Por favor completa todos los campos';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String get updateRequiredTitle => 'Actualización requerida';

  @override
  String get updateRequiredMessage =>
      'Esta versión de Diggle ya no es compatible. Actualiza para seguir jugando.';

  @override
  String get currentVersionLabel => 'Actual';

  @override
  String get latestVersionLabel => 'Última';

  @override
  String get requiredVersionLabel => 'Requerida';

  @override
  String get updateNow => 'ACTUALIZAR';

  @override
  String get updateLater => 'Más tarde';

  @override
  String get updateOpenStoreFailed =>
      'No se pudo abrir el dApp Store. Actualiza manualmente.';

  @override
  String get light => 'Luz';

  @override
  String get lightUpgraded => '¡Sistema de luz mejorado!';

  @override
  String revealRadiusValue(int radius) {
    return 'Alcance: $radius casillas';
  }

  @override
  String get questsTitle => 'MISIONES';

  @override
  String get questsSubtitle => 'Completa misiones para ganar XP y puntos';

  @override
  String get questsDailyTab => 'Diarias';

  @override
  String get questsSocialTab => 'Sociales';

  @override
  String get questsClaim => 'RECLAMAR';

  @override
  String get questsClaimed => '✓ Reclamado';

  @override
  String get questsGo => 'IR';

  @override
  String get questsClose => 'CERRAR';

  @override
  String get questsNoDailyQuests => 'No hay misiones diarias disponibles';

  @override
  String get questsSocialInfo =>
      'Completa acciones sociales para ganar recompensas únicas. Toca IR para abrir el enlace.';

  @override
  String get quests => 'MISIONES';

  @override
  String questMineOreTitle(int count) {
    return 'Minar $count minerales';
  }

  @override
  String questMineOreDesc(int count) {
    return 'Mina $count casillas de mineral en un solo día';
  }

  @override
  String questReachDepthTitle(int depth) {
    return 'Alcanzar ${depth}m';
  }

  @override
  String questReachDepthDesc(int depth) {
    return 'Alcanza una profundidad de ${depth}m o más';
  }

  @override
  String questSellOreTitle(int value) {
    return 'Vender por \$$value';
  }

  @override
  String questSellOreDesc(int value) {
    return 'Vende mineral por un total de \$$value';
  }

  @override
  String questRepairTitle(int amount) {
    return 'Reparar $amount PV';
  }

  @override
  String questRepairDesc(int amount) {
    return 'Repara un total de $amount PV de casco';
  }

  @override
  String questUseItemsTitle(int count) {
    return 'Usar $count objetos';
  }

  @override
  String questUseItemsDesc(int count) {
    return 'Usa $count objetos de tu inventario';
  }

  @override
  String get questFollowTwitterTitle => 'Seguir en X';

  @override
  String get questFollowTwitterDesc => 'Sigue a @DiggleGame en X (Twitter)';

  @override
  String get questJoinDiscordTitle => 'Unirse a Discord';

  @override
  String get questJoinDiscordDesc =>
      'Únete a la comunidad de Diggle en Discord';

  @override
  String get questPostTweetTitle => 'Compartir en X';

  @override
  String get questPostTweetDesc => 'Publica un tweet sobre Diggle';

  @override
  String get questVerifyButton => 'Verificar';

  @override
  String get questPasteTweetUrl => 'Pega la URL de tu tweet aquí';

  @override
  String get questVerifying => 'Verificando...';

  @override
  String get questVerified => '¡Misión verificada y completada!';

  @override
  String get questVerificationFailed =>
      'No se pudo verificar. Inténtalo de nuevo.';

  @override
  String get loginStreak => 'Racha diaria';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: 'Sin racha',
    );
    return '$_temp0';
  }

  @override
  String get streakClaimedToday => 'Reclamado hoy';

  @override
  String get streakPlayToday => 'Juega hoy para mantenerla';

  @override
  String get streakStartToday => 'Juega hoy para empezar una racha';

  @override
  String streakNextReward(int xp, int points) {
    return 'Siguiente: +$xp XP, +$points pts';
  }

  @override
  String get streakJackpotReached => 'Nivel máximo: recompensa diaria máxima';

  @override
  String streakToJackpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días para el premio mayor',
      one: '1 día para el premio mayor',
    );
    return '$_temp0';
  }

  @override
  String get menuWeeklyChallenge => 'Desafío semanal';

  @override
  String get menuLeaderboard => 'Clasificación';

  @override
  String get menuHangar => 'Hangar';

  @override
  String get museumTitle => 'MUSEO';

  @override
  String get achievementsTab => 'LOGROS';

  @override
  String get leaderboardHeading => '🏆 CLASIFICACIÓN';

  @override
  String get leaderboardEmpty =>
      'Aún no hay registros.\n¡Sé el primero en la tabla!';

  @override
  String get hangarHeading => '🛠️ HANGAR';

  @override
  String hangarMachineCount(int count) {
    return '$count Diggle Machines en esta wallet: solo una puede estar equipada a la vez.';
  }

  @override
  String get hangarSeekerVerified => 'SEEKER GENESIS VERIFICADO';

  @override
  String get hangarSeekerBlurb =>
      'Pionero de Solana Mobile: +5% de XP y puntos, siempre activo.';

  @override
  String get hangarSealedCrate => 'CAJA SELLADA';

  @override
  String get hangarSealedBlurb =>
      'Esta máquina todavía no se ha revelado. Hasta entonces otorga la mejora fija de titular: +25% de XP y puntos.\n\nTras el reveal, sus cinco rasgos de equipo (casco, propulsor, depósito de combustible, broca y bodega) se podrán equipar con bonificaciones según su rareza. ¡Pulsa actualizar el día del reveal!';

  @override
  String get hangarEquipped =>
      '✅ Equipada: bonificaciones activas en partidas normales.\nEl desafío semanal usa un equipamiento estándar (sin equipo).';

  @override
  String get quantity => 'Cantidad';

  @override
  String get airdrop => 'Airdrop';

  @override
  String get questsWeeklyTab => 'Semanales';

  @override
  String get questsWeeklyInfo =>
      'Grandes retos, grandes recompensas. Se reinicia cada lunes (UTC).';

  @override
  String questsNotEnoughPoints(int cost) {
    return 'Puntos insuficientes (necesitas $cost). ¡Consigue un pack de puntos en la tienda!';
  }

  @override
  String get questJoinDiscordServer => 'Unirse al servidor de Discord';

  @override
  String get questCheckingMembership => 'Comprobando la membresía...';

  @override
  String get questVerifyMembership => 'Verificar membresía';

  @override
  String get questDiscordHint =>
      'Únete primero al servidor y luego pulsa Verificar para confirmarlo con Discord';

  @override
  String get questPostOnX => 'Publicar en X';

  @override
  String get questTweetHint =>
      'Publica el tweet de arriba y luego pega la URL para verificarlo';

  @override
  String get questDiscordUnavailable =>
      'La verificación de Discord no está disponible. Inténtalo más tarde.';

  @override
  String get questDiscordOpenFailed =>
      'No se pudo abrir Discord. Inténtalo de nuevo.';

  @override
  String get questDiscordVerified => '¡Membresía de Discord verificada! 🎉';

  @override
  String get questDiscordVerifyFailed =>
      'No se pudo verificar la membresía. Asegúrate de haberte unido al servidor y de haber autorizado Discord.';

  @override
  String get signNewContract => 'Firmar nuevo contrato';

  @override
  String get corporateContract => '⭐ Contrato corporativo';

  @override
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  ) {
    return '¿Firmar el contrato n.º $level?\n\nSE REINICIA: mundo, dinero, mejoras de la nave\nSE CONSERVA: XP, puntos, NFTs, logros, colección\n\nVENTAJAS PERMANENTES:\n• +$sellBonus% al precio de venta del mineral\n• \$$startCash de dinero inicial + kit de inicio\n$hardcore• Insignia $badge en la clasificación';
  }

  @override
  String get prestigeHardcoreLine =>
      '• Vetas hardcore: mineral más rico, peligros más letales\n';

  @override
  String get notYet => 'Todavía no';

  @override
  String get signContract => 'Firmar contrato';

  @override
  String get recoveryFailedPoints => 'Rescate fallido: puntos insuficientes';

  @override
  String emergencyRecoveryCost(int cost) {
    return 'Rescate de emergencia ($cost pts)';
  }

  @override
  String emergencyRecoveryNeed(int cost) {
    return 'Necesitas $cost pts: abre la tienda';
  }

  @override
  String keepsCargo(int value) {
    return '¡Conservas tu carga de \$$value!';
  }

  @override
  String titleUnlocked(String title) {
    return 'Título desbloqueado: $title';
  }

  @override
  String get titleProspector => 'Buscador';

  @override
  String get titleExcavator => 'Excavador';

  @override
  String get titleDemolitionist => 'Demoledor';

  @override
  String get titleDeepMiner => 'Minero de las profundidades';

  @override
  String get titleVoidwalker => 'Caminante del vacío';

  @override
  String get titleCoreBreaker => 'Rompenúcleos';

  @override
  String get titleDiggleLegend => 'Leyenda de Diggle';

  @override
  String get artifactTsFossilFern => 'Helecho fósil';

  @override
  String get artifactTsFossilFernDesc =>
      'La huella perfecta de un helecho prehistórico.';

  @override
  String get artifactTsOldBoot => 'Bota de buscador';

  @override
  String get artifactTsOldBootDesc => 'Alguien cavó aquí mucho antes que tú.';

  @override
  String get artifactTsClayJar => 'Vasija de barro';

  @override
  String get artifactTsClayJarDesc =>
      'Un recipiente antiguo, milagrosamente intacto.';

  @override
  String get artifactTsArrowhead => 'Punta de flecha de sílex';

  @override
  String get artifactTsArrowheadDesc =>
      'Tallada por manos que se fueron hace diez mil años.';

  @override
  String get artifactTsCoinHoard => 'Tesoro de monedas';

  @override
  String get artifactTsCoinHoardDesc =>
      'Monedas corroídas de una ceca olvidada.';

  @override
  String get artifactPfMammothTusk => 'Colmillo de mamut';

  @override
  String get artifactPfMammothTuskDesc => 'Marfil curvo, frío al tacto.';

  @override
  String get artifactPfIceLens => 'Lente de hielo';

  @override
  String get artifactPfIceLensDesc =>
      'Una lente formada de manera natural con hielo milenario.';

  @override
  String get artifactPfFrozenFlower => 'Flor congelada';

  @override
  String get artifactPfFrozenFlowerDesc =>
      'Un capullo detenido en plena floración durante milenios.';

  @override
  String get artifactPfSledRunner => 'Patín de trineo';

  @override
  String get artifactPfSledRunnerDesc =>
      'Parte de una expedición que nunca regresó.';

  @override
  String get artifactPfAmberInsect => 'Insecto en ámbar';

  @override
  String get artifactPfAmberInsectDesc =>
      'Un pasajero diminuto atrapado en resina dorada.';

  @override
  String get artifactCcSingingGeode => 'Geoda cantora';

  @override
  String get artifactCcSingingGeodeDesc =>
      'Entona una nota justo por debajo del oído.';

  @override
  String get artifactCcPrismCore => 'Núcleo prismático';

  @override
  String get artifactCcPrismCoreDesc =>
      'Divide la luz de la lámpara en colores sin nombre.';

  @override
  String get artifactCcPetrifiedEye => 'Ojo petrificado';

  @override
  String get artifactCcPetrifiedEyeDesc =>
      'Estás seguro de que te estaba mirando.';

  @override
  String get artifactCcResonantShard => 'Fragmento resonante';

  @override
  String get artifactCcResonantShardDesc =>
      'Vibra cuando hay otros cristales cerca.';

  @override
  String get artifactCcHollowBell => 'Campana hueca';

  @override
  String get artifactCcHollowBellDesc =>
      'Una campana de cristal que suena en el silencio.';

  @override
  String get artifactMcObsidianBlade => 'Hoja de obsidiana';

  @override
  String get artifactMcObsidianBladeDesc =>
      'Vidrio volcánico, más afilado que cualquier broca.';

  @override
  String get artifactMcFireOpal => 'Ópalo de fuego';

  @override
  String get artifactMcFireOpalDesc =>
      'Una piedra con un rescoldo vivo dentro.';

  @override
  String get artifactMcBasaltIdol => 'Ídolo de basalto';

  @override
  String get artifactMcBasaltIdolDesc =>
      'Tallado por algo a lo que le gustaba el calor.';

  @override
  String get artifactMcMeteorFragment => 'Fragmento de meteorito';

  @override
  String get artifactMcMeteorFragmentDesc =>
      'Cayó desde arriba y se hundió hasta aquí.';

  @override
  String get artifactMcHeartOfCore => 'Corazón del núcleo';

  @override
  String get artifactMcHeartOfCoreDesc => 'Sigue caliente. ¿Sigue latiendo?';

  @override
  String get achievementOre10 => 'Primer cargamento';

  @override
  String get achievementOre10Desc => 'Extrae 10 minerales';

  @override
  String get achievementOre100 => 'Sabueso del mineral';

  @override
  String get achievementOre100Desc => 'Extrae 100 minerales';

  @override
  String get achievementOre500 => 'Cazavetas';

  @override
  String get achievementOre500Desc => 'Extrae 500 minerales';

  @override
  String get achievementOre2000 => 'Minero a cielo abierto';

  @override
  String get achievementOre2000Desc => 'Extrae 2.000 minerales';

  @override
  String get achievementOre10000 => 'Devoraplanetas';

  @override
  String get achievementOre10000Desc => 'Extrae 10.000 minerales';

  @override
  String get achievementDepth50 => 'Bajo las raíces';

  @override
  String get achievementDepth50Desc => 'Alcanza la profundidad 50';

  @override
  String get achievementDepth120 => 'Hacia la escarcha';

  @override
  String get achievementDepth120Desc => 'Llega al Permafrost (profundidad 120)';

  @override
  String get achievementDepth240 => 'Vidente de cristal';

  @override
  String get achievementDepth240Desc =>
      'Llega a las Cavernas de Cristal (profundidad 240)';

  @override
  String get achievementDepth360 => 'Buceador de magma';

  @override
  String get achievementDepth360Desc =>
      'Llega al Núcleo de Magma (profundidad 360)';

  @override
  String get achievementDepth445 => 'Toque de fondo';

  @override
  String get achievementDepth445Desc =>
      'Toca el fondo del mundo (profundidad 445)';

  @override
  String get achievementCash1k => 'Dinero de bolsillo';

  @override
  String get achievementCash1kDesc => 'Gana \$1.000 en total';

  @override
  String get achievementCash25k => 'Minero de negocios';

  @override
  String get achievementCash25kDesc => 'Gana \$25.000 en total';

  @override
  String get achievementCash250k => 'Barón del mineral';

  @override
  String get achievementCash250kDesc => 'Gana \$250.000 en total';

  @override
  String get achievementCash1m => 'Magnate de Diggle';

  @override
  String get achievementCash1mDesc => 'Gana \$1.000.000 en total';

  @override
  String get achievementLevel5 => 'Esto va en serio';

  @override
  String get achievementLevel5Desc => 'Alcanza el nivel 5';

  @override
  String get achievementLevel10 => 'Dos cifras';

  @override
  String get achievementLevel10Desc => 'Alcanza el nivel 10';

  @override
  String get achievementLevel18 => 'Veterano de las profundidades';

  @override
  String get achievementLevel18Desc => 'Alcanza el nivel 18';

  @override
  String get achievementLevel25 => 'Diggle al máximo';

  @override
  String get achievementLevel25Desc => 'Alcanza el nivel 25';

  @override
  String get achievementArtifact1 => 'Arqueólogo aficionado';

  @override
  String get achievementArtifact1Desc => 'Encuentra tu primer artefacto';

  @override
  String get achievementArtifact10 => 'Donante del museo';

  @override
  String get achievementArtifact10Desc => 'Encuentra 10 artefactos';

  @override
  String get achievementArtifact20 => 'Curador maestro';

  @override
  String get achievementArtifact20Desc => 'Completa toda la colección';

  @override
  String get achievementBlast5 => '¡Fuego en el hoyo!';

  @override
  String get achievementBlast5Desc => 'Detona 5 explosivos';

  @override
  String get achievementBlast50 => 'Demolición controlada';

  @override
  String get achievementBlast50Desc => 'Detona 50 explosivos';

  @override
  String get achievementSales10 => 'Cliente habitual';

  @override
  String get achievementSales10Desc => 'Vende mineral 10 veces';

  @override
  String get achievementSales100 => 'Mueve el mercado';

  @override
  String get achievementSales100Desc => 'Vende mineral 100 veces';

  @override
  String get achievementDeath1 => 'Riesgo laboral';

  @override
  String get achievementDeath1Desc => 'Pierde tu primera perforadora';

  @override
  String get achievementDeath25 => 'Nunca te rindas';

  @override
  String get achievementDeath25Desc => 'Pierde 25 perforadoras y sigue cavando';

  @override
  String get itemBackupFuel => 'Combustible de reserva';

  @override
  String get itemRepairBot => 'Robot de reparación';

  @override
  String get itemDynamite => 'Dinamita';

  @override
  String get itemC4 => 'C4';

  @override
  String get itemSpaceRift => 'Grieta espacial';

  @override
  String get itemOreScanner => 'Escáner de mineral';

  @override
  String get itemHeatShield => 'Escudo térmico';

  @override
  String get tileEmpty => 'Vacío';

  @override
  String get tileDirt => 'Tierra';

  @override
  String get tileRock => 'Roca';

  @override
  String get tileCoal => 'Carbón';

  @override
  String get tileCopper => 'Cobre';

  @override
  String get tileSilver => 'Plata';

  @override
  String get tileGold => 'Oro';

  @override
  String get tileSapphire => 'Zafiro';

  @override
  String get tileEmerald => 'Esmeralda';

  @override
  String get tileRuby => 'Rubí';

  @override
  String get tileDiamond => 'Diamante';

  @override
  String get tileLava => 'Lava';

  @override
  String get tileGas => 'Bolsa de gas';

  @override
  String get tileFrozenDirt => 'Tierra congelada';

  @override
  String get tileMagmaRock => 'Roca de magma';

  @override
  String get tileCrystalOre => 'Cristal';

  @override
  String get tileUnstableRock => 'Roca inestable';

  @override
  String get tileLootCrate => 'Caja de suministros';

  @override
  String get tileArtifact => 'Artefacto';

  @override
  String get tileBedrock => 'Lecho rocoso';

  @override
  String questUseExplosivesTitle(int count) {
    return 'Detona $count explosivos';
  }

  @override
  String questUseExplosivesDesc(int count) {
    return 'Usa dinamita o C4 $count veces';
  }

  @override
  String questFindArtifactTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encuentra $count artefactos',
      one: 'Encuentra un artefacto',
    );
    return '$_temp0';
  }

  @override
  String get questFindArtifactDesc => 'Desentierra artefactos en las ruinas';

  @override
  String questOpenCrateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Abre $count cajas de suministros',
      one: 'Abre una caja de suministros',
    );
    return '$_temp0';
  }

  @override
  String get questOpenCrateDesc =>
      'Abre cajas de suministros en pozos abandonados';

  @override
  String get rarityCommon => 'Común';

  @override
  String get rarityUncommon => 'Poco común';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Épico';

  @override
  String get rarityLegendary => 'Legendario';

  @override
  String get itemBackupFuelDesc => 'Restaura 50 de combustible';

  @override
  String get itemRepairBotDesc => 'Repara 40 PV del casco';

  @override
  String get itemDynamiteDesc => 'Vuela un área de 3x3';

  @override
  String get itemC4Desc => 'Vuela un área de 5x5';

  @override
  String get itemSpaceRiftDesc => 'Te teletransporta a la superficie';

  @override
  String get itemOreScannerDesc => 'Revela el terreno en un amplio radio';

  @override
  String get itemHeatShieldDesc => '60 s de inmunidad a la lava';

  @override
  String get biomeTopsoil => 'CAPA SUPERFICIAL';

  @override
  String get biomePermafrost => 'PERMAFROST';

  @override
  String get biomeCrystalCaverns => 'CAVERNAS DE CRISTAL';

  @override
  String get biomeMagmaCore => 'NÚCLEO DE MAGMA';

  @override
  String get museumArtifactsTab => 'ARTEFACTOS';

  @override
  String get museumRecordsTab => 'RÉCORDS';

  @override
  String get leaderboardDepthTab => 'METROS';

  @override
  String get leaderboardPointsTab => 'PUNTOS';

  @override
  String get leaderboardWeeklyTab => 'ESTA SEMANA';
}
