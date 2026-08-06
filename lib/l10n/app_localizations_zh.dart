// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline => '深入挖掘  •  开采财富  •  勇往直前';

  @override
  String get mineDeepEarnRewards => '深入挖掘，赢取奖励。';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => '新游戏';

  @override
  String get continueGame => '继续';

  @override
  String get loadGame => '加载游戏';

  @override
  String get account => '账户';

  @override
  String get settings => '设置';

  @override
  String get howToPlay => '游戏指南';

  @override
  String comingSoon(String feature) {
    return '$feature 即将推出！';
  }

  @override
  String get helpMiningTitle => '⛏️ 采矿';

  @override
  String get helpMiningBody => '使用方向控制移动钻头。挖掘泥土和岩石，寻找珍贵矿石。';

  @override
  String get helpFuelTitle => '⛽ 燃料';

  @override
  String get helpFuelBody => '移动和挖掘会消耗燃料。在燃料耗尽前返回地面！';

  @override
  String get helpHullTitle => '🛡️ 船体';

  @override
  String get helpHullBody => '坠落太远会损坏船体。注意你的HP！';

  @override
  String get helpSellingTitle => '💰 出售';

  @override
  String get helpSellingBody => '返回地面并前往商店出售矿石换取金钱。';

  @override
  String get helpUpgradesTitle => '🔧 升级';

  @override
  String get helpUpgradesBody => '用金钱升级燃料箱、货舱和船体装甲。';

  @override
  String get helpHazardsTitle => '⚠️ 危险';

  @override
  String get helpHazardsBody => '小心岩浆（即死）和毒气（伤害）！';

  @override
  String get gotIt => '明白了！';

  @override
  String get paused => '已暂停';

  @override
  String get resume => '继续';

  @override
  String get saveGame => '保存游戏';

  @override
  String get restart => '重新开始';

  @override
  String get mainMenu => '主菜单';

  @override
  String savedToSlot(int slot) {
    return '已保存到槽位 $slot';
  }

  @override
  String get gameOver => '游戏结束';

  @override
  String depthReached(int depth) {
    return '到达深度：$depth米';
  }

  @override
  String get tryAgain => '再试一次';

  @override
  String get loadingDiggle => '正在加载 Diggle...';

  @override
  String failedToLoadGame(String error) {
    return '加载游戏失败：\n$error';
  }

  @override
  String get backToMenu => '返回菜单';

  @override
  String get signInWithEmail => '邮箱登录';

  @override
  String get signInWithWallet => '钱包登录';

  @override
  String get playAsGuest => '游客模式';

  @override
  String get or => '或';

  @override
  String get createAccount => '创建账户';

  @override
  String get signIn => '登录';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get password => '密码';

  @override
  String get passwordMinChars => '密码（至少6个字符）';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get alreadyHaveAccount => '已有账户？登录';

  @override
  String get noAccount => '没有账户？注册';

  @override
  String get checkEmailConfirm => '请查看邮箱确认您的账户！';

  @override
  String get invalidEmailPassword => '邮箱或密码无效';

  @override
  String get emailAlreadyRegistered => '该邮箱已注册';

  @override
  String get pleaseConfirmEmail => '请先确认您的邮箱';

  @override
  String get networkError => '网络错误 — 请检查连接';

  @override
  String get tooManyAttempts => '尝试次数过多 — 请稍后重试';

  @override
  String get cancelled => '已取消';

  @override
  String get pleaseFillFields => '请输入邮箱和密码';

  @override
  String get passwordTooShort => '密码至少需要6个字符';

  @override
  String get passwordsNoMatch => '密码不匹配';

  @override
  String get accountTitle => '账户';

  @override
  String get accountSubtitle => '个人资料、登录方式和统计';

  @override
  String get playerProfile => '玩家资料';

  @override
  String get enterDisplayName => '输入显示名称';

  @override
  String get anonymousMiner => '匿名矿工';

  @override
  String memberSince(String date) {
    return '注册于 $date';
  }

  @override
  String get playingOffline => '离线游戏中';

  @override
  String get playerIdCopied => '玩家ID已复制';

  @override
  String get signInMethods => '登录方式';

  @override
  String get signInMethodsSubtitle => '您的账户登录方式';

  @override
  String get emailSignIn => '邮箱登录';

  @override
  String get emailLabel => '邮箱';

  @override
  String get solanaWallet => 'Solana 钱包';

  @override
  String get linkedWallet => '已关联钱包';

  @override
  String get addEmailAlt => '添加邮箱作为备选登录方式';

  @override
  String get linkForStore => '关联以进行商店购买和NFT';

  @override
  String get primary => '主要';

  @override
  String get linked => '已关联';

  @override
  String get add => '添加';

  @override
  String get copyAddress => '复制地址';

  @override
  String get unlink => '取消关联';

  @override
  String get addEmailSignIn => '添加邮箱登录';

  @override
  String get addEmailSubtitle => '钱包仍为主要登录方式。邮箱为备选方案。';

  @override
  String get addEmail => '添加邮箱';

  @override
  String get checkEmailLink => '请查看邮箱确认关联！';

  @override
  String get emailSignInAdded => '邮箱登录已添加！';

  @override
  String get walletConnectionCancelled => '钱包连接已取消';

  @override
  String get couldNotGetWalletAddress => '无法获取钱包地址';

  @override
  String get signingCancelled => '签名已取消';

  @override
  String get walletLinked => '钱包已关联！现在可以用它登录。';

  @override
  String get walletLinkFailed => '钱包关联失败';

  @override
  String get unlinkWalletTitle => '取消关联钱包';

  @override
  String get unlinkWalletMessage => '钱包将从您的账户中移除。之后您可以关联其他钱包。';

  @override
  String get cancel => '取消';

  @override
  String get walletUnlinked => '钱包已取消关联';

  @override
  String get unlinkFailed => '取消关联失败';

  @override
  String get walletAdapter => '钱包适配器';

  @override
  String get walletAdapterGuestSubtitle => '连接以进行本次会话的购买';

  @override
  String get walletAdapterReconnectSubtitle => '重新连接以签署交易';

  @override
  String get walletAdapterConnectSubtitle => '连接以使用商店';

  @override
  String get network => '网络';

  @override
  String get mainnet => '主网';

  @override
  String get devnet => '开发网';

  @override
  String connected(String network) {
    return '已连接 — $network';
  }

  @override
  String get loadingBalance => '正在加载余额...';

  @override
  String get airdropRequested => '空投已请求！';

  @override
  String get airdropFailed => '空投失败';

  @override
  String get disconnectNote => '断开连接仅结束适配器会话。您的账户保持关联 — 随时可重新连接。';

  @override
  String get disconnectAdapter => '断开适配器';

  @override
  String get connecting => '连接中...';

  @override
  String get connectWallet => '连接钱包';

  @override
  String get phantomTip => '💡 推荐使用 Phantom 钱包以获得最佳开发网支持';

  @override
  String get addressCopied => '地址已复制';

  @override
  String get lifetimeStats => '累计统计';

  @override
  String get statLevel => '等级';

  @override
  String get statTotalXp => '总经验值';

  @override
  String get statPoints => '积分';

  @override
  String get statOresMined => '已采矿石';

  @override
  String get statMaxDepth => '最大深度';

  @override
  String get statPlayTime => '游戏时间';

  @override
  String get statPointsEarned => '获得积分';

  @override
  String get statPointsSpent => '消耗积分';

  @override
  String get signedInEmail => '已通过邮箱登录';

  @override
  String get signedInWallet => '已通过钱包登录';

  @override
  String get playingAsGuest => '游客模式中';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutConfirm => '确定要退出登录吗？';

  @override
  String get guestSignOutWarning => '游客进度仅保存在此设备上。退出将无法访问当前存档。确定吗？';

  @override
  String get emailAccount => '邮箱账户';

  @override
  String get walletAccount => '钱包账户';

  @override
  String get guestLocalOnly => '游客 — 仅本地进度';

  @override
  String get offline => '离线';

  @override
  String get newGameTitle => '新游戏';

  @override
  String get loadGameTitle => '加载游戏';

  @override
  String get newGameSubtitle => '为新冒险选择一个存档槽位';

  @override
  String get loadGameSubtitle => '选择存档继续旅程';

  @override
  String slotEmpty(int slot) {
    return '槽位 $slot — 空';
  }

  @override
  String get tapToStart => '点击开始新冒险';

  @override
  String get noSaveData => '无存档数据';

  @override
  String slot(int slot) {
    return '槽位 $slot';
  }

  @override
  String savedAgo(String time) {
    return '保存于 $time';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return '删除槽位 $slot？';
  }

  @override
  String get cannotBeUndone => '此操作无法撤销。';

  @override
  String get delete => '删除';

  @override
  String get overwriteSaveTitle => '覆盖存档？';

  @override
  String overwriteSaveMessage(int slot) {
    return '槽位 $slot 已有存档。在此开始新游戏将覆盖它。';
  }

  @override
  String get overwrite => '覆盖';

  @override
  String get noSaves => '（无存档）';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int min) {
    return '$min分钟前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String daysAgo(int days) {
    return '$days天前';
  }

  @override
  String get hp => 'HP';

  @override
  String get fuel => '燃料';

  @override
  String get items => '物品：';

  @override
  String get store => '商店';

  @override
  String get shop => '商店';

  @override
  String depthMeter(int depth) {
    return '$depth米';
  }

  @override
  String get miningSupplyCo => '矿业供应公司';

  @override
  String get cash => '金钱';

  @override
  String get hull => '船体';

  @override
  String get fuelLabel => '燃料';

  @override
  String get cargo => '货舱';

  @override
  String get services => '服务';

  @override
  String get upgrades => '升级';

  @override
  String get itemsTab => '物品';

  @override
  String get sellOre => '出售矿石';

  @override
  String get noOreToSell => '没有可出售的矿石';

  @override
  String get totalValue => '总价值：';

  @override
  String get sellAll => '全部出售';

  @override
  String get refuel => '加油';

  @override
  String refuelCost(int cost) {
    return '加油（\$$cost）';
  }

  @override
  String get tankFull => '油箱已满！';

  @override
  String get repair => '修复';

  @override
  String repairHullCost(int cost) {
    return '修复船体（\$$cost）';
  }

  @override
  String get hullFullyRepaired => '船体已完全修复！';

  @override
  String inventorySlots(int used, int max) {
    return '库存：$used/$max 格';
  }

  @override
  String upgradeCost(int cost) {
    return '升级 - \$$cost';
  }

  @override
  String get maxed => '已满级';

  @override
  String get drillBit => '钻头';

  @override
  String get engine => '引擎';

  @override
  String get cooling => '冷却';

  @override
  String get fuelTank => '燃料箱';

  @override
  String get cargoBay => '货舱';

  @override
  String get hullArmor => '船体装甲';

  @override
  String capacityValue(int value) {
    return '容量：$value';
  }

  @override
  String speedPercent(int percent) {
    return '速度：$percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return '燃料节省：$percent%';
  }

  @override
  String get noFuelSavings => '无燃料节省';

  @override
  String maxHpValue(int value) {
    return '最大HP：$value';
  }

  @override
  String get returnToMining => '返回采矿';

  @override
  String soldOreFor(int amount) {
    return '矿石已售出，获得 \$$amount！';
  }

  @override
  String get tankRefueled => '油箱已加满！';

  @override
  String get fuelTankUpgraded => '燃料箱已升级！';

  @override
  String get cargoBayUpgraded => '货舱已升级！';

  @override
  String get hullRepaired => '船体已修复！';

  @override
  String get hullArmorUpgraded => '船体装甲已升级！';

  @override
  String get drillBitUpgraded => '钻头已升级！';

  @override
  String get engineUpgraded => '引擎已升级！';

  @override
  String get coolingUpgraded => '冷却系统已升级！';

  @override
  String purchased(String item) {
    return '已购买 $item！';
  }

  @override
  String get premiumStore => '高级商店';

  @override
  String get onChainLoaded => '链上价格已加载';

  @override
  String get usingDefaultPrices => '使用默认价格';

  @override
  String get level => '等级';

  @override
  String get xp => '经验值';

  @override
  String get points => '积分';

  @override
  String get activeBoosts => '当前加成';

  @override
  String get permanent => '永久';

  @override
  String get pointsTab => '积分';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => '需要钱包';

  @override
  String get walletRequiredMessage => '连接您的 Solana 钱包以访问高级物品。\n所有购买均为链上交易。';

  @override
  String get storePricesUnavailable => '商店价格不可用';

  @override
  String get storePricesUnavailableMessage => '无法加载链上价格。\n请检查连接后重试。';

  @override
  String get retry => '重试';

  @override
  String get buy => '购买';

  @override
  String get notEnoughPoints => '积分不足！';

  @override
  String activated(String item) {
    return '$item 已激活！';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$item 已购买！TX：$tx...';
  }

  @override
  String get purchaseFailed => '购买失败';

  @override
  String get closeStore => '关闭商店';

  @override
  String get diggleDrillMachine => 'DIGGLE 钻机';

  @override
  String get permanentBoostNft => '永久加成NFT — 每位玩家限一个';

  @override
  String get holderBenefits => '持有者权益';

  @override
  String get permanentXpBoost => '永久经验加成';

  @override
  String get permanentPointsBoost => '永久积分加成';

  @override
  String get limitedSupply => '限量供应';

  @override
  String get soldOut => '已售罄';

  @override
  String get allNftsMinted => '所有 Diggle Drill NFT 已铸造完毕！';

  @override
  String get mintOpensSoon => '铸造即将开始';

  @override
  String startsAt(String date) {
    return '开始时间：$date';
  }

  @override
  String get checkBackLater => '请稍后再来！';

  @override
  String get mintNft => '铸造NFT';

  @override
  String mintCost(String cost) {
    return '铸造 — $cost SOL';
  }

  @override
  String get nftMinted => 'NFT已铸造！🎉';

  @override
  String get refresh => '刷新';

  @override
  String get boostsActive => '您的加成已永久生效！';

  @override
  String get mintStatusPreparing => '正在准备交易...';

  @override
  String get mintStatusApprove => '请在钱包中确认...';

  @override
  String get mintStatusSending => '正在发送交易...';

  @override
  String get mintStatusConfirming => '链上确认中...';

  @override
  String get mintStatusSuccess => '铸造成功！';

  @override
  String get mintStatusError => '铸造失败';

  @override
  String xpLabel(int current, int next) {
    return 'XP：$current/$next';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '游戏偏好';

  @override
  String get language => '语言';

  @override
  String get languageSubtitle => '选择您的首选语言';

  @override
  String get systemDefault => '系统默认';

  @override
  String get pleaseFillAllFields => '请填写所有字段';

  @override
  String errorPrefix(String message) {
    return '错误：$message';
  }

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String get updateRequiredTitle => '需要更新';

  @override
  String get updateRequiredMessage => '此版本的 Diggle 已不再受支持。请更新以继续游戏。';

  @override
  String get currentVersionLabel => '当前版本';

  @override
  String get latestVersionLabel => '最新版本';

  @override
  String get requiredVersionLabel => '所需版本';

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后';

  @override
  String get updateOpenStoreFailed => '无法打开 dApp Store。请手动更新。';

  @override
  String get light => '灯光';

  @override
  String get lightUpgraded => '灯光系统已升级！';

  @override
  String revealRadiusValue(int radius) {
    return '照明范围：$radius 格';
  }

  @override
  String get questsTitle => '任务';

  @override
  String get questsSubtitle => '完成任务赢取经验值和积分';

  @override
  String get questsDailyTab => '每日';

  @override
  String get questsSocialTab => '社交';

  @override
  String get questsClaim => '领取';

  @override
  String get questsClaimed => '✓ 已领取';

  @override
  String get questsGo => '前往';

  @override
  String get questsClose => '关闭';

  @override
  String get questsNoDailyQuests => '暂无每日任务';

  @override
  String get questsSocialInfo => '完成社交操作以获取一次性奖励。点击「前往」打开链接。';

  @override
  String get quests => '任务';

  @override
  String questMineOreTitle(int count) {
    return '采矿 $count 块';
  }

  @override
  String questMineOreDesc(int count) {
    return '一天内采集 $count 块矿石';
  }

  @override
  String questReachDepthTitle(int depth) {
    return '到达 $depth米深度';
  }

  @override
  String questReachDepthDesc(int depth) {
    return '到达 $depth米 或更深处';
  }

  @override
  String questSellOreTitle(int value) {
    return '出售价值 \$$value';
  }

  @override
  String questSellOreDesc(int value) {
    return '出售总价值 \$$value 的矿石';
  }

  @override
  String questRepairTitle(int amount) {
    return '修复 $amount HP';
  }

  @override
  String questRepairDesc(int amount) {
    return '总共修复 $amount 点船体HP';
  }

  @override
  String questUseItemsTitle(int count) {
    return '使用 $count 个物品';
  }

  @override
  String questUseItemsDesc(int count) {
    return '从库存中使用 $count 个物品';
  }

  @override
  String get questFollowTwitterTitle => '关注 X';

  @override
  String get questFollowTwitterDesc => '在 X (Twitter) 上关注 @DiggleGame';

  @override
  String get questJoinDiscordTitle => '加入 Discord';

  @override
  String get questJoinDiscordDesc => '加入 Diggle Discord 社区';

  @override
  String get questPostTweetTitle => '分享到 X';

  @override
  String get questPostTweetDesc => '发布一条关于 Diggle 的推文';

  @override
  String get questVerifyButton => '验证';

  @override
  String get questPasteTweetUrl => '在此粘贴您的推文链接';

  @override
  String get questVerifying => '验证中...';

  @override
  String get questVerified => '任务已验证并完成！';

  @override
  String get questVerificationFailed => '无法验证，请重试。';

  @override
  String get loginStreak => '连续登录';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
      zero: '暂无连续记录',
    );
    return '$_temp0';
  }

  @override
  String get streakClaimedToday => '今日已领取';

  @override
  String get streakPlayToday => '今天来玩一局即可延续';

  @override
  String get streakStartToday => '今天来玩一局即可开始连续记录';

  @override
  String streakNextReward(int xp, int points) {
    return '下次：+$xp 经验，+$points 积分';
  }

  @override
  String get streakJackpotReached => '已达最高档 — 每日奖励最大';

  @override
  String streakToJackpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '距离大奖还有 $count 天',
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
