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
}
