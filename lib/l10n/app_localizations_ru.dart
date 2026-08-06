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
