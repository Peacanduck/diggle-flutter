// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline => 'КОПАЙ ГЛУБЖЕ  •  ДОБЫВАЙ БОГАТСТВА  •  ИДИ ДАЛЬШЕ';

  @override
  String get mineDeepEarnRewards => 'Копай глубоко. Зарабатывай награды.';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => 'НОВАЯ ИГРА';

  @override
  String get continueGame => 'ПРОДОЛЖИТЬ';

  @override
  String get loadGame => 'ЗАГРУЗИТЬ';

  @override
  String get account => 'АККАУНТ';

  @override
  String get settings => 'Настройки';

  @override
  String get howToPlay => 'Как играть';

  @override
  String comingSoon(String feature) {
    return '$feature скоро!';
  }

  @override
  String get helpMiningTitle => '⛏️ Добыча';

  @override
  String get helpMiningBody =>
      'Используйте стрелки для управления буром. Копайте землю и камень, чтобы найти ценные руды.';

  @override
  String get helpFuelTitle => '⛽ Топливо';

  @override
  String get helpFuelBody =>
      'Перемещение и бурение расходуют топливо. Возвращайтесь на поверхность до его окончания!';

  @override
  String get helpHullTitle => '🛡️ Корпус';

  @override
  String get helpHullBody =>
      'Падение с большой высоты повреждает корпус. Следите за HP!';

  @override
  String get helpSellingTitle => '💰 Продажа';

  @override
  String get helpSellingBody =>
      'Вернитесь на поверхность и посетите МАГАЗИН, чтобы продать руду за деньги.';

  @override
  String get helpUpgradesTitle => '🔧 Улучшения';

  @override
  String get helpUpgradesBody =>
      'Используйте деньги для улучшения топливного бака, грузового отсека и брони.';

  @override
  String get helpHazardsTitle => '⚠️ Опасности';

  @override
  String get helpHazardsBody =>
      'Остерегайтесь лавы (мгновенная гибель) и газовых карманов (урон)!';

  @override
  String get gotIt => 'ПОНЯТНО!';

  @override
  String get paused => 'ПАУЗА';

  @override
  String get resume => 'ПРОДОЛЖИТЬ';

  @override
  String get saveGame => 'СОХРАНИТЬ';

  @override
  String get restart => 'ЗАНОВО';

  @override
  String get mainMenu => 'ГЛАВНОЕ МЕНЮ';

  @override
  String savedToSlot(int slot) {
    return 'Сохранено в слот $slot';
  }

  @override
  String get gameOver => 'КОНЕЦ ИГРЫ';

  @override
  String depthReached(int depth) {
    return 'Достигнутая глубина: $depthм';
  }

  @override
  String get tryAgain => 'ПОПРОБОВАТЬ СНОВА';

  @override
  String get loadingDiggle => 'Загрузка Diggle...';

  @override
  String failedToLoadGame(String error) {
    return 'Не удалось загрузить игру:\n$error';
  }

  @override
  String get backToMenu => 'Назад в меню';

  @override
  String get signInWithEmail => 'ВОЙТИ ЧЕРЕЗ E-MAIL';

  @override
  String get signInWithWallet => 'ВОЙТИ ЧЕРЕЗ КОШЕЛЁК';

  @override
  String get playAsGuest => 'Играть как гость';

  @override
  String get or => 'ИЛИ';

  @override
  String get createAccount => 'СОЗДАТЬ АККАУНТ';

  @override
  String get signIn => 'ВОЙТИ';

  @override
  String get emailAddress => 'Адрес электронной почты';

  @override
  String get password => 'Пароль';

  @override
  String get passwordMinChars => 'Пароль (мин. 6 символов)';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get checkEmailConfirm => 'Проверьте почту для подтверждения аккаунта!';

  @override
  String get invalidEmailPassword => 'Неверный e-mail или пароль';

  @override
  String get emailAlreadyRegistered => 'Аккаунт с этим e-mail уже существует';

  @override
  String get pleaseConfirmEmail => 'Сначала подтвердите ваш e-mail';

  @override
  String get networkError => 'Ошибка сети — проверьте подключение';

  @override
  String get tooManyAttempts => 'Слишком много попыток — попробуйте позже';

  @override
  String get cancelled => 'Отменено';

  @override
  String get pleaseFillFields => 'Введите ваш e-mail и пароль';

  @override
  String get passwordTooShort => 'Пароль должен содержать не менее 6 символов';

  @override
  String get passwordsNoMatch => 'Пароли не совпадают';

  @override
  String get accountTitle => 'АККАУНТ';

  @override
  String get accountSubtitle => 'Профиль, способы входа и статистика';

  @override
  String get playerProfile => 'ПРОФИЛЬ ИГРОКА';

  @override
  String get enterDisplayName => 'Введите отображаемое имя';

  @override
  String get anonymousMiner => 'Анонимный шахтёр';

  @override
  String memberSince(String date) {
    return 'Участник с $date';
  }

  @override
  String get playingOffline => 'Игра офлайн';

  @override
  String get playerIdCopied => 'ID игрока скопирован';

  @override
  String get signInMethods => 'СПОСОБЫ ВХОДА';

  @override
  String get signInMethodsSubtitle => 'Как вы можете войти в аккаунт';

  @override
  String get emailSignIn => 'Вход через e-mail';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get solanaWallet => 'Кошелёк Solana';

  @override
  String get linkedWallet => 'Привязанный кошелёк';

  @override
  String get addEmailAlt => 'Добавить e-mail как альтернативный способ входа';

  @override
  String get linkForStore => 'Привязать для покупок и NFT';

  @override
  String get primary => 'ОСНОВНОЙ';

  @override
  String get linked => 'ПРИВЯЗАН';

  @override
  String get add => 'Добавить';

  @override
  String get copyAddress => 'Копировать адрес';

  @override
  String get unlink => 'Отвязать';

  @override
  String get addEmailSignIn => 'Добавить вход через e-mail';

  @override
  String get addEmailSubtitle =>
      'Кошелёк остаётся основным способом входа. E-mail — альтернатива.';

  @override
  String get addEmail => 'ДОБАВИТЬ E-MAIL';

  @override
  String get checkEmailLink => 'Проверьте почту для подтверждения привязки!';

  @override
  String get emailSignInAdded => 'Вход через e-mail добавлен!';

  @override
  String get walletConnectionCancelled => 'Подключение кошелька отменено';

  @override
  String get couldNotGetWalletAddress => 'Не удалось получить адрес кошелька';

  @override
  String get signingCancelled => 'Подпись отменена';

  @override
  String get walletLinked =>
      'Кошелёк привязан! Теперь вы можете входить через него.';

  @override
  String get walletLinkFailed => 'Не удалось привязать кошелёк';

  @override
  String get unlinkWalletTitle => 'Отвязать кошелёк';

  @override
  String get unlinkWalletMessage =>
      'Кошелёк будет удалён из аккаунта. Вы сможете привязать другой кошелёк позже.';

  @override
  String get cancel => 'Отмена';

  @override
  String get walletUnlinked => 'Кошелёк отвязан';

  @override
  String get unlinkFailed => 'Не удалось отвязать кошелёк';

  @override
  String get walletAdapter => 'АДАПТЕР КОШЕЛЬКА';

  @override
  String get walletAdapterGuestSubtitle =>
      'Подключитесь для покупок в этой сессии';

  @override
  String get walletAdapterReconnectSubtitle =>
      'Переподключитесь для подписи транзакций';

  @override
  String get walletAdapterConnectSubtitle =>
      'Подключитесь для использования магазина';

  @override
  String get network => 'Сеть';

  @override
  String get mainnet => 'Mainnet';

  @override
  String get devnet => 'Devnet';

  @override
  String connected(String network) {
    return 'Подключено — $network';
  }

  @override
  String get loadingBalance => 'Загрузка баланса...';

  @override
  String get airdropRequested => 'Аирдроп запрошен!';

  @override
  String get airdropFailed => 'Аирдроп не удался';

  @override
  String get disconnectNote =>
      'Отключение завершает только сессию адаптера. Ваш аккаунт остаётся привязан — переподключитесь в любое время.';

  @override
  String get disconnectAdapter => 'ОТКЛЮЧИТЬ АДАПТЕР';

  @override
  String get connecting => 'Подключение...';

  @override
  String get connectWallet => 'ПОДКЛЮЧИТЬ КОШЕЛЁК';

  @override
  String get phantomTip => '💡 Используйте Phantom для лучшей поддержки devnet';

  @override
  String get addressCopied => 'Адрес скопирован';

  @override
  String get lifetimeStats => 'ОБЩАЯ СТАТИСТИКА';

  @override
  String get statLevel => 'Уровень';

  @override
  String get statTotalXp => 'Всего XP';

  @override
  String get statPoints => 'Очки';

  @override
  String get statOresMined => 'Руды добыто';

  @override
  String get statMaxDepth => 'Макс. глубина';

  @override
  String get statPlayTime => 'Время игры';

  @override
  String get statPointsEarned => 'Очков заработано';

  @override
  String get statPointsSpent => 'Очков потрачено';

  @override
  String get signedInEmail => 'Вход через e-mail';

  @override
  String get signedInWallet => 'Вход через кошелёк';

  @override
  String get playingAsGuest => 'Играет как гость';

  @override
  String get signOut => 'Выход';

  @override
  String get signOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get guestSignOutWarning =>
      'Прогресс гостя сохраняется только на этом устройстве. Выход удалит доступ к текущим сохранениям. Вы уверены?';

  @override
  String get emailAccount => 'Аккаунт e-mail';

  @override
  String get walletAccount => 'Аккаунт кошелька';

  @override
  String get guestLocalOnly => 'Гость — только локальный прогресс';

  @override
  String get offline => 'Офлайн';

  @override
  String get newGameTitle => 'НОВАЯ ИГРА';

  @override
  String get loadGameTitle => 'ЗАГРУЗИТЬ ИГРУ';

  @override
  String get newGameSubtitle => 'Выберите слот для нового приключения';

  @override
  String get loadGameSubtitle => 'Выберите сохранение для продолжения';

  @override
  String slotEmpty(int slot) {
    return 'Слот $slot — Пусто';
  }

  @override
  String get tapToStart => 'Нажмите, чтобы начать приключение';

  @override
  String get noSaveData => 'Нет сохранений';

  @override
  String slot(int slot) {
    return 'Слот $slot';
  }

  @override
  String savedAgo(String time) {
    return 'Сохранено $time';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return 'Удалить слот $slot?';
  }

  @override
  String get cannotBeUndone => 'Это действие нельзя отменить.';

  @override
  String get delete => 'УДАЛИТЬ';

  @override
  String get overwriteSaveTitle => 'Перезаписать?';

  @override
  String overwriteSaveMessage(int slot) {
    return 'В слоте $slot уже есть сохранение. Новая игра здесь перезапишет его.';
  }

  @override
  String get overwrite => 'ПЕРЕЗАПИСАТЬ';

  @override
  String get noSaves => '(нет сохранений)';

  @override
  String get justNow => 'только что';

  @override
  String minutesAgo(int min) {
    return '$minмин назад';
  }

  @override
  String hoursAgo(int hours) {
    return '$hoursч назад';
  }

  @override
  String daysAgo(int days) {
    return '$daysд назад';
  }

  @override
  String get hp => 'HP';

  @override
  String get fuel => 'ТОПЛИВО';

  @override
  String get items => 'ПРЕДМЕТЫ: ';

  @override
  String get store => 'МАГАЗИН';

  @override
  String get shop => 'МАГАЗИН';

  @override
  String depthMeter(int depth) {
    return '$depthм';
  }

  @override
  String get miningSupplyCo => 'ГОРНОЕ СНАБЖЕНИЕ';

  @override
  String get cash => 'Деньги';

  @override
  String get hull => 'Корпус';

  @override
  String get fuelLabel => 'Топливо';

  @override
  String get cargo => 'Грузовой отсек';

  @override
  String get services => 'Услуги';

  @override
  String get upgrades => 'Улучшения';

  @override
  String get itemsTab => 'Предметы';

  @override
  String get sellOre => 'ПРОДАТЬ РУДУ';

  @override
  String get noOreToSell => 'Нет руды для продажи';

  @override
  String get totalValue => 'Общая стоимость:';

  @override
  String get sellAll => 'ПРОДАТЬ ВСЁ';

  @override
  String get refuel => 'ЗАПРАВИТЬ';

  @override
  String refuelCost(int cost) {
    return 'ЗАПРАВИТЬ (\$$cost)';
  }

  @override
  String get tankFull => 'Бак полон!';

  @override
  String get repair => 'ПОЧИНИТЬ';

  @override
  String repairHullCost(int cost) {
    return 'ПОЧИНИТЬ КОРПУС (\$$cost)';
  }

  @override
  String get hullFullyRepaired => 'Корпус полностью починен!';

  @override
  String inventorySlots(int used, int max) {
    return 'Инвентарь: $used/$max слотов';
  }

  @override
  String upgradeCost(int cost) {
    return 'УЛУЧШИТЬ - \$$cost';
  }

  @override
  String get maxed => 'МАКС';

  @override
  String get drillBit => 'Бур';

  @override
  String get engine => 'Двигатель';

  @override
  String get cooling => 'Охлаждение';

  @override
  String get fuelTank => 'Топливный бак';

  @override
  String get cargoBay => 'Грузовой отсек';

  @override
  String get hullArmor => 'Броня корпуса';

  @override
  String capacityValue(int value) {
    return 'Ёмкость: $value';
  }

  @override
  String speedPercent(int percent) {
    return 'Скорость: $percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return 'Экономия топлива: $percent%';
  }

  @override
  String get noFuelSavings => 'Нет экономии топлива';

  @override
  String maxHpValue(int value) {
    return 'Макс HP: $value';
  }

  @override
  String get returnToMining => 'ВЕРНУТЬСЯ К ДОБЫЧЕ';

  @override
  String soldOreFor(int amount) {
    return 'Руда продана за \$$amount!';
  }

  @override
  String get tankRefueled => 'Бак заправлен!';

  @override
  String get fuelTankUpgraded => 'Топливный бак улучшен!';

  @override
  String get cargoBayUpgraded => 'Грузовой отсек улучшен!';

  @override
  String get hullRepaired => 'Корпус починен!';

  @override
  String get hullArmorUpgraded => 'Броня корпуса улучшена!';

  @override
  String get drillBitUpgraded => 'Бур улучшен!';

  @override
  String get engineUpgraded => 'Двигатель улучшен!';

  @override
  String get coolingUpgraded => 'Охлаждение улучшено!';

  @override
  String purchased(String item) {
    return '$item куплен!';
  }

  @override
  String get premiumStore => 'ПРЕМИУМ-МАГАЗИН';

  @override
  String get onChainLoaded => 'Цены on-chain загружены';

  @override
  String get usingDefaultPrices => 'Используются стандартные цены';

  @override
  String get level => 'Уровень';

  @override
  String get xp => 'XP';

  @override
  String get points => 'Очки';

  @override
  String get activeBoosts => 'АКТИВНЫЕ БУСТЫ';

  @override
  String get permanent => 'Постоянный';

  @override
  String get pointsTab => 'Очки';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => 'Требуется кошелёк';

  @override
  String get walletRequiredMessage =>
      'Подключите кошелёк Solana для доступа к премиум-предметам.\nВсе покупки — транзакции on-chain.';

  @override
  String get storePricesUnavailable => 'Цены недоступны';

  @override
  String get storePricesUnavailableMessage =>
      'Не удалось загрузить цены on-chain.\nПроверьте подключение и попробуйте снова.';

  @override
  String get retry => 'ПОВТОРИТЬ';

  @override
  String get buy => 'КУПИТЬ';

  @override
  String get notEnoughPoints => 'Недостаточно очков!';

  @override
  String activated(String item) {
    return '$item активирован!';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$item куплен! TX: $tx...';
  }

  @override
  String get purchaseFailed => 'Покупка не удалась';

  @override
  String get closeStore => 'ЗАКРЫТЬ МАГАЗИН';

  @override
  String get diggleDrillMachine => 'БУР DIGGLE';

  @override
  String get permanentBoostNft => 'NFT с постоянным бустом — один на игрока';

  @override
  String get holderBenefits => 'ПРЕИМУЩЕСТВА ВЛАДЕЛЬЦА';

  @override
  String get permanentXpBoost => 'Постоянный буст XP';

  @override
  String get permanentPointsBoost => 'Постоянный буст очков';

  @override
  String get limitedSupply => 'Ограниченный тираж';

  @override
  String get soldOut => 'РАСПРОДАНО';

  @override
  String get allNftsMinted => 'Все NFT Diggle Drill были отчеканены!';

  @override
  String get mintOpensSoon => 'МИНТ СКОРО ОТКРОЕТСЯ';

  @override
  String startsAt(String date) {
    return 'Начало: $date';
  }

  @override
  String get checkBackLater => 'Загляните позже!';

  @override
  String get mintNft => 'МИНТИТЬ NFT';

  @override
  String mintCost(String cost) {
    return 'МИНТ — $cost SOL';
  }

  @override
  String get nftMinted => 'NFT отчеканен! 🎉';

  @override
  String get refresh => 'Обновить';

  @override
  String get boostsActive => 'Ваши бусты активны навсегда!';

  @override
  String get mintStatusPreparing => 'Подготовка транзакции...';

  @override
  String get mintStatusApprove => 'Подтвердите в кошельке...';

  @override
  String get mintStatusSending => 'Отправка транзакции...';

  @override
  String get mintStatusConfirming => 'Подтверждение on-chain...';

  @override
  String get mintStatusSuccess => 'Успешно отчеканено!';

  @override
  String get mintStatusError => 'Минт не удался';

  @override
  String xpLabel(int current, int next) {
    return 'XP: $current/$next';
  }

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsSubtitle => 'Игровые настройки';

  @override
  String get language => 'Язык';

  @override
  String get languageSubtitle => 'Выберите предпочтительный язык';

  @override
  String get systemDefault => 'Системный по умолчанию';

  @override
  String get vfxQualitySection => 'Визуальные эффекты';

  @override
  String get vfxQualitySubtitle => 'Частицы, тряска экрана и вспышки от ударов';

  @override
  String get vfxQualityFull => 'Полные';

  @override
  String get vfxQualityFullDesc => 'Все эффекты с максимальной плотностью';

  @override
  String get vfxQualityLow => 'Сниженные';

  @override
  String get vfxQualityLowDesc => 'Меньше частиц — дольше держит батарея';

  @override
  String get vfxQualityOff => 'Выключены';

  @override
  String get vfxQualityOffDesc => 'Без частиц и тряски экрана';

  @override
  String get pleaseFillAllFields => 'Заполните все поля';

  @override
  String errorPrefix(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String get updateRequiredTitle => 'Требуется обновление';

  @override
  String get updateRequiredMessage =>
      'Эта версия Diggle больше не поддерживается. Обновите, чтобы продолжить игру.';

  @override
  String get currentVersionLabel => 'Текущая';

  @override
  String get latestVersionLabel => 'Последняя';

  @override
  String get requiredVersionLabel => 'Необходимая';

  @override
  String get updateNow => 'ОБНОВИТЬ';

  @override
  String get updateLater => 'Позже';

  @override
  String get updateOpenStoreFailed =>
      'Не удалось открыть dApp Store. Обновите вручную.';

  @override
  String get light => 'Свет';

  @override
  String get lightUpgraded => 'Система освещения улучшена!';

  @override
  String revealRadiusValue(int radius) {
    return 'Обзор: $radius клеток';
  }

  @override
  String get questsTitle => 'ЗАДАНИЯ';

  @override
  String get questsSubtitle => 'Выполняйте задания, чтобы заработать XP и очки';

  @override
  String get questsDailyTab => 'Ежедневные';

  @override
  String get questsSocialTab => 'Социальные';

  @override
  String get questsClaim => 'ЗАБРАТЬ';

  @override
  String get questsClaimed => '✓ Забрано';

  @override
  String get questsGo => 'ПЕРЕЙТИ';

  @override
  String get questsClose => 'ЗАКРЫТЬ';

  @override
  String get questsNoDailyQuests => 'Нет доступных ежедневных заданий';

  @override
  String get questsSocialInfo =>
      'Выполняйте социальные действия, чтобы получить разовые награды. Нажмите ПЕРЕЙТИ, чтобы открыть ссылку.';

  @override
  String get quests => 'ЗАДАНИЯ';

  @override
  String questMineOreTitle(int count) {
    return 'Добудьте $count руд';
  }

  @override
  String questMineOreDesc(int count) {
    return 'Добудьте $count клеток руды за один день';
  }

  @override
  String questReachDepthTitle(int depth) {
    return 'Достигните $depthм';
  }

  @override
  String questReachDepthDesc(int depth) {
    return 'Достигните глубины $depthм или более';
  }

  @override
  String questSellOreTitle(int value) {
    return 'Продайте на \$$value';
  }

  @override
  String questSellOreDesc(int value) {
    return 'Продайте руду на общую сумму \$$value';
  }

  @override
  String questRepairTitle(int amount) {
    return 'Почините $amount HP';
  }

  @override
  String questRepairDesc(int amount) {
    return 'Почините в сумме $amount HP корпуса';
  }

  @override
  String questUseItemsTitle(int count) {
    return 'Используйте $count предметов';
  }

  @override
  String questUseItemsDesc(int count) {
    return 'Используйте $count предметов из инвентаря';
  }

  @override
  String get questFollowTwitterTitle => 'Подписаться в X';

  @override
  String get questFollowTwitterDesc =>
      'Подпишитесь на @DiggleGame в X (Twitter)';

  @override
  String get questJoinDiscordTitle => 'Присоединиться к Discord';

  @override
  String get questJoinDiscordDesc =>
      'Присоединяйтесь к сообществу Diggle в Discord';

  @override
  String get questPostTweetTitle => 'Поделиться в X';

  @override
  String get questPostTweetDesc => 'Опубликуйте твит о Diggle';

  @override
  String get questVerifyButton => 'Подтвердить';

  @override
  String get questPasteTweetUrl => 'Вставьте URL вашего твита сюда';

  @override
  String get questVerifying => 'Проверка...';

  @override
  String get questVerified => 'Задание подтверждено и выполнено!';

  @override
  String get questVerificationFailed =>
      'Не удалось подтвердить. Попробуйте снова.';

  @override
  String get loginStreak => 'Серия входов';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
      zero: 'Серии пока нет',
    );
    return '$_temp0';
  }

  @override
  String get streakClaimedToday => 'Получено сегодня';

  @override
  String get streakPlayToday => 'Сыграйте сегодня, чтобы продолжить';

  @override
  String get streakStartToday => 'Сыграйте сегодня, чтобы начать серию';

  @override
  String streakNextReward(int xp, int points) {
    return 'Далее: +$xp XP, +$points оч.';
  }

  @override
  String get streakJackpotReached =>
      'Максимальная ступень — награда максимальна';

  @override
  String streakToJackpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней до джекпота',
      few: '$count дня до джекпота',
      one: '$count день до джекпота',
    );
    return '$_temp0';
  }

  @override
  String get menuWeeklyChallenge => 'Недельный вызов';

  @override
  String get menuLeaderboard => 'Рейтинг';

  @override
  String get menuHangar => 'Ангар';

  @override
  String get museumTitle => 'МУЗЕЙ';

  @override
  String get achievementsTab => 'ДОСТИЖЕНИЯ';

  @override
  String get leaderboardHeading => '🏆 РЕЙТИНГ';

  @override
  String get leaderboardEmpty =>
      'Записей пока нет.\nСтаньте первым в рейтинге!';

  @override
  String get hangarHeading => '🛠️ АНГАР';

  @override
  String hangarMachineCount(int count) {
    return 'Diggle Machines в этом кошельке: $count — экипировать можно только одну.';
  }

  @override
  String get hangarSeekerVerified => 'SEEKER GENESIS ПОДТВЕРЖДЁН';

  @override
  String get hangarSeekerBlurb =>
      'Пионер Solana Mobile — +5% XP и очков, всегда активно.';

  @override
  String get hangarSealedCrate => 'ЗАПЕЧАТАННЫЙ ЯЩИК';

  @override
  String get hangarSealedBlurb =>
      'Эта машина ещё не раскрыта. До этого она даёт фиксированный буст владельца: +25% XP и очков.\n\nПосле раскрытия её пять частей снаряжения (корпус, двигатель, топливный бак, бур, грузовой отсек) можно будет экипировать с бонусами по редкости. В день раскрытия нажмите «Обновить»!';

  @override
  String get hangarEquipped =>
      '✅ Экипировано — бонусы активны в обычных заходах.\nВ недельном вызове используется стандартное снаряжение (без гира).';

  @override
  String get quantity => 'Количество';

  @override
  String get airdrop => 'Аирдроп';

  @override
  String get questsWeeklyTab => 'Недельные';

  @override
  String get questsWeeklyInfo =>
      'Большие испытания — большие награды. Сброс каждый понедельник (UTC).';

  @override
  String questsNotEnoughPoints(int cost) {
    return 'Недостаточно очков (нужно $cost). Купите набор очков в магазине!';
  }

  @override
  String get questJoinDiscordServer => 'Вступить в Discord-сервер';

  @override
  String get questCheckingMembership => 'Проверяем участие...';

  @override
  String get questVerifyMembership => 'Проверить участие';

  @override
  String get questDiscordHint =>
      'Сначала вступите в сервер, затем нажмите «Проверить», чтобы подтвердить через Discord';

  @override
  String get questPostOnX => 'Опубликовать в X';

  @override
  String get questTweetHint =>
      'Опубликуйте твит выше, затем вставьте ссылку для проверки';

  @override
  String get questDiscordUnavailable =>
      'Проверка через Discord недоступна. Попробуйте позже.';

  @override
  String get questDiscordOpenFailed =>
      'Не удалось открыть Discord. Попробуйте снова.';

  @override
  String get questDiscordVerified => 'Участие в Discord подтверждено! 🎉';

  @override
  String get questDiscordVerifyFailed =>
      'Не удалось подтвердить участие. Убедитесь, что вы вступили в сервер и авторизовали Discord.';

  @override
  String get signNewContract => 'Подписать новый контракт';

  @override
  String get corporateContract => '⭐ Корпоративный контракт';

  @override
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  ) {
    return 'Подписать контракт №$level?\n\nСБРОС: мир, деньги, улучшения корабля\nСОХРАНЯЕТСЯ: XP, очки, NFT, достижения, коллекция\n\nПОСТОЯННЫЕ БОНУСЫ:\n• +$sellBonus% к цене продажи руды\n• \$$startCash стартовых денег + набор новичка\n$hardcore• Значок $badge в рейтинге';
  }

  @override
  String get prestigeHardcoreLine =>
      '• Хардкорные жилы: руда богаче, опасности смертоноснее\n';

  @override
  String get notYet => 'Пока нет';

  @override
  String get signContract => 'Подписать контракт';

  @override
  String get recoveryFailedPoints => 'Спасение не удалось — недостаточно очков';

  @override
  String emergencyRecoveryCost(int cost) {
    return 'Экстренное спасение ($cost оч.)';
  }

  @override
  String emergencyRecoveryNeed(int cost) {
    return 'Нужно $cost оч. — откройте магазин';
  }

  @override
  String keepsCargo(int value) {
    return 'Груз на \$$value останется при вас!';
  }

  @override
  String titleUnlocked(String title) {
    return 'Открыт титул: $title';
  }

  @override
  String get titleProspector => 'Изыскатель';

  @override
  String get titleExcavator => 'Землекоп';

  @override
  String get titleDemolitionist => 'Подрывник';

  @override
  String get titleDeepMiner => 'Глубинный шахтёр';

  @override
  String get titleVoidwalker => 'Ходок Пустоты';

  @override
  String get titleCoreBreaker => 'Сокрушитель Ядра';

  @override
  String get titleDiggleLegend => 'Легенда Diggle';

  @override
  String get artifactTsFossilFern => 'Окаменелый папоротник';

  @override
  String get artifactTsFossilFernDesc =>
      'Идеальный отпечаток древнего папоротника.';

  @override
  String get artifactTsOldBoot => 'Сапог изыскателя';

  @override
  String get artifactTsOldBootDesc => 'Кто-то копал здесь задолго до вас.';

  @override
  String get artifactTsClayJar => 'Глиняный сосуд';

  @override
  String get artifactTsClayJarDesc => 'Древняя тара, чудом целая.';

  @override
  String get artifactTsArrowhead => 'Кремнёвый наконечник';

  @override
  String get artifactTsArrowheadDesc =>
      'Обработан руками, ушедшими десять тысяч лет назад.';

  @override
  String get artifactTsCoinHoard => 'Клад монет';

  @override
  String get artifactTsCoinHoardDesc =>
      'Изъеденные монеты забытого монетного двора.';

  @override
  String get artifactPfMammothTusk => 'Клык мамонта';

  @override
  String get artifactPfMammothTuskDesc => 'Изогнутая кость, холодная на ощупь.';

  @override
  String get artifactPfIceLens => 'Ледяная линза';

  @override
  String get artifactPfIceLensDesc =>
      'Линза, естественно намёрзшая из древнего льда.';

  @override
  String get artifactPfFrozenFlower => 'Замёрзший цветок';

  @override
  String get artifactPfFrozenFlowerDesc =>
      'Бутон, застывший в цвету на тысячелетия.';

  @override
  String get artifactPfSledRunner => 'Полоз от нарт';

  @override
  String get artifactPfSledRunnerDesc =>
      'Часть экспедиции, которая не вернулась.';

  @override
  String get artifactPfAmberInsect => 'Насекомое в янтаре';

  @override
  String get artifactPfAmberInsectDesc =>
      'Крошечный пассажир, застывший в золотой смоле.';

  @override
  String get artifactCcSingingGeode => 'Поющая жеода';

  @override
  String get artifactCcSingingGeodeDesc => 'Гудит на ноте чуть ниже слышимой.';

  @override
  String get artifactCcPrismCore => 'Призменное ядро';

  @override
  String get artifactCcPrismCoreDesc =>
      'Разлагает свет лампы на цвета без названий.';

  @override
  String get artifactCcPetrifiedEye => 'Окаменевший глаз';

  @override
  String get artifactCcPetrifiedEyeDesc => 'Вы уверены: он за вами следил.';

  @override
  String get artifactCcResonantShard => 'Резонирующий осколок';

  @override
  String get artifactCcResonantShardDesc =>
      'Дрожит, когда рядом другие кристаллы.';

  @override
  String get artifactCcHollowBell => 'Пустотелый колокол';

  @override
  String get artifactCcHollowBellDesc =>
      'Кристальный колокол, звенящий в тишине.';

  @override
  String get artifactMcObsidianBlade => 'Обсидиановый клинок';

  @override
  String get artifactMcObsidianBladeDesc =>
      'Вулканическое стекло острее любого бура.';

  @override
  String get artifactMcFireOpal => 'Огненный опал';

  @override
  String get artifactMcFireOpalDesc => 'Камень с живым угольком внутри.';

  @override
  String get artifactMcBasaltIdol => 'Базальтовый идол';

  @override
  String get artifactMcBasaltIdolDesc => 'Вырезан кем-то, кто любил жару.';

  @override
  String get artifactMcMeteorFragment => 'Обломок метеорита';

  @override
  String get artifactMcMeteorFragmentDesc =>
      'Упал сверху и погрузился так глубоко.';

  @override
  String get artifactMcHeartOfCore => 'Сердце Ядра';

  @override
  String get artifactMcHeartOfCoreDesc => 'Всё ещё тёплое. Всё ещё бьётся?';

  @override
  String get achievementOre10 => 'Первая добыча';

  @override
  String get achievementOre10Desc => 'Добудьте 10 руд';

  @override
  String get achievementOre100 => 'Рудная гончая';

  @override
  String get achievementOre100Desc => 'Добудьте 100 руд';

  @override
  String get achievementOre500 => 'Охотник за жилами';

  @override
  String get achievementOre500Desc => 'Добудьте 500 руд';

  @override
  String get achievementOre2000 => 'Карьерщик';

  @override
  String get achievementOre2000Desc => 'Добудьте 2 000 руд';

  @override
  String get achievementOre10000 => 'Пожиратель планет';

  @override
  String get achievementOre10000Desc => 'Добудьте 10 000 руд';

  @override
  String get achievementDepth50 => 'Ниже корней';

  @override
  String get achievementDepth50Desc => 'Достигните глубины 50';

  @override
  String get achievementDepth120 => 'В мерзлоту';

  @override
  String get achievementDepth120Desc => 'Дойдите до Мерзлоты (глубина 120)';

  @override
  String get achievementDepth240 => 'Смотрящий в кристалл';

  @override
  String get achievementDepth240Desc =>
      'Дойдите до Кристальных пещер (глубина 240)';

  @override
  String get achievementDepth360 => 'Ныряльщик в магму';

  @override
  String get achievementDepth360Desc =>
      'Дойдите до Магмового ядра (глубина 360)';

  @override
  String get achievementDepth445 => 'Самое дно';

  @override
  String get achievementDepth445Desc => 'Коснитесь дна мира (глубина 445)';

  @override
  String get achievementCash1k => 'Карманные деньги';

  @override
  String get achievementCash1kDesc => 'Заработайте \$1 000 за всё время';

  @override
  String get achievementCash25k => 'Шахтёр-коммерсант';

  @override
  String get achievementCash25kDesc => 'Заработайте \$25 000 за всё время';

  @override
  String get achievementCash250k => 'Рудный барон';

  @override
  String get achievementCash250kDesc => 'Заработайте \$250 000 за всё время';

  @override
  String get achievementCash1m => 'Магнат Diggle';

  @override
  String get achievementCash1mDesc => 'Заработайте \$1 000 000 за всё время';

  @override
  String get achievementLevel5 => 'Всё серьёзнее';

  @override
  String get achievementLevel5Desc => 'Достигните 5 уровня';

  @override
  String get achievementLevel10 => 'Двузначный';

  @override
  String get achievementLevel10Desc => 'Достигните 10 уровня';

  @override
  String get achievementLevel18 => 'Ветеран глубин';

  @override
  String get achievementLevel18Desc => 'Достигните 18 уровня';

  @override
  String get achievementLevel25 => 'Максимальный Diggle';

  @override
  String get achievementLevel25Desc => 'Достигните 25 уровня';

  @override
  String get achievementArtifact1 => 'Археолог-любитель';

  @override
  String get achievementArtifact1Desc => 'Найдите свой первый артефакт';

  @override
  String get achievementArtifact10 => 'Даритель музея';

  @override
  String get achievementArtifact10Desc => 'Найдите 10 артефактов';

  @override
  String get achievementArtifact20 => 'Главный куратор';

  @override
  String get achievementArtifact20Desc => 'Соберите всю коллекцию';

  @override
  String get achievementBlast5 => 'Ложись, рвём!';

  @override
  String get achievementBlast5Desc => 'Взорвите 5 зарядов';

  @override
  String get achievementBlast50 => 'Контролируемый взрыв';

  @override
  String get achievementBlast50Desc => 'Взорвите 50 зарядов';

  @override
  String get achievementSales10 => 'Постоянный клиент';

  @override
  String get achievementSales10Desc => 'Продайте руду 10 раз';

  @override
  String get achievementSales100 => 'Двигатель рынка';

  @override
  String get achievementSales100Desc => 'Продайте руду 100 раз';

  @override
  String get achievementDeath1 => 'Профессиональный риск';

  @override
  String get achievementDeath1Desc => 'Потеряйте свой первый бур';

  @override
  String get achievementDeath25 => 'Никогда не сдавайся';

  @override
  String get achievementDeath25Desc =>
      'Потеряйте 25 буров и продолжайте копать';

  @override
  String get itemBackupFuel => 'Запасное топливо';

  @override
  String get itemRepairBot => 'Ремонтный бот';

  @override
  String get itemDynamite => 'Динамит';

  @override
  String get itemC4 => 'C4';

  @override
  String get itemSpaceRift => 'Пространственный разлом';

  @override
  String get itemOreScanner => 'Сканер руды';

  @override
  String get itemHeatShield => 'Термощит';

  @override
  String get tileEmpty => 'Пусто';

  @override
  String get tileDirt => 'Земля';

  @override
  String get tileRock => 'Камень';

  @override
  String get tileCoal => 'Уголь';

  @override
  String get tileCopper => 'Медь';

  @override
  String get tileSilver => 'Серебро';

  @override
  String get tileGold => 'Золото';

  @override
  String get tileSapphire => 'Сапфир';

  @override
  String get tileEmerald => 'Изумруд';

  @override
  String get tileRuby => 'Рубин';

  @override
  String get tileDiamond => 'Алмаз';

  @override
  String get tileLava => 'Лава';

  @override
  String get tileGas => 'Газовый карман';

  @override
  String get tileFrozenDirt => 'Мёрзлая земля';

  @override
  String get tileMagmaRock => 'Магмовая порода';

  @override
  String get tileCrystalOre => 'Кристалл';

  @override
  String get tileUnstableRock => 'Нестабильная порода';

  @override
  String get tileLootCrate => 'Ящик с припасами';

  @override
  String get tileArtifact => 'Артефакт';

  @override
  String get tileBedrock => 'Скальное основание';

  @override
  String questUseExplosivesTitle(int count) {
    return 'Взорвите $count зарядов';
  }

  @override
  String questUseExplosivesDesc(int count) {
    return 'Используйте динамит или C4 $count раз';
  }

  @override
  String questFindArtifactTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдите $count артефактов',
      few: 'Найдите $count артефакта',
      one: 'Найдите $count артефакт',
    );
    return '$_temp0';
  }

  @override
  String get questFindArtifactDesc => 'Выкапывайте артефакты в руинах';

  @override
  String questOpenCrateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Откройте $count ящиков с припасами',
      few: 'Откройте $count ящика с припасами',
      one: 'Откройте $count ящик с припасами',
    );
    return '$_temp0';
  }

  @override
  String get questOpenCrateDesc =>
      'Вскрывайте ящики с припасами в заброшенных шахтах';

  @override
  String get rarityCommon => 'Обычный';

  @override
  String get rarityUncommon => 'Необычный';

  @override
  String get rarityRare => 'Редкий';

  @override
  String get rarityEpic => 'Эпический';

  @override
  String get rarityLegendary => 'Легендарный';

  @override
  String get itemBackupFuelDesc => 'Восстанавливает 50 топлива';

  @override
  String get itemRepairBotDesc => 'Восстанавливает 40 HP корпуса';

  @override
  String get itemDynamiteDesc => 'Взрывает область 3×3';

  @override
  String get itemC4Desc => 'Взрывает область 5×5';

  @override
  String get itemSpaceRiftDesc => 'Телепорт на поверхность';

  @override
  String get itemOreScannerDesc => 'Открывает рельеф в широком радиусе';

  @override
  String get itemHeatShieldDesc => '60 с невосприимчивости к лаве';

  @override
  String get biomeTopsoil => 'ВЕРХНИЙ СЛОЙ';

  @override
  String get biomePermafrost => 'МЕРЗЛОТА';

  @override
  String get biomeCrystalCaverns => 'КРИСТАЛЬНЫЕ ПЕЩЕРЫ';

  @override
  String get biomeMagmaCore => 'МАГМОВОЕ ЯДРО';

  @override
  String get museumArtifactsTab => 'АРТЕФАКТЫ';

  @override
  String get museumRecordsTab => 'РЕКОРДЫ';

  @override
  String get leaderboardDepthTab => 'МЕТРЫ';

  @override
  String get leaderboardPointsTab => 'ОЧКИ';

  @override
  String get leaderboardWeeklyTab => 'ЗА НЕДЕЛЮ';
}
