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
}
