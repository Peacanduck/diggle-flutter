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
  String get vfxQualitySection => '视觉特效';

  @override
  String get vfxQualitySubtitle => '粒子、屏幕震动和受击闪光';

  @override
  String get vfxQualityFull => '完整';

  @override
  String get vfxQualityFullDesc => '所有特效以最高密度显示';

  @override
  String get vfxQualityLow => '精简';

  @override
  String get vfxQualityLowDesc => '减少粒子 — 更省电';

  @override
  String get vfxQualityOff => '关闭';

  @override
  String get vfxQualityOffDesc => '不显示粒子和屏幕震动';

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
  String get menuWeeklyChallenge => '每周挑战';

  @override
  String get menuLeaderboard => '排行榜';

  @override
  String get menuHangar => '机库';

  @override
  String get museumTitle => '博物馆';

  @override
  String get achievementsTab => '成就';

  @override
  String get leaderboardHeading => '🏆 排行榜';

  @override
  String get leaderboardEmpty => '暂无记录。\n成为榜上第一人！';

  @override
  String get hangarHeading => '🛠️ 机库';

  @override
  String hangarMachineCount(int count) {
    return '此钱包中有 $count 台 Diggle Machine — 每次只能装备一台。';
  }

  @override
  String get hangarSeekerVerified => 'SEEKER GENESIS 已验证';

  @override
  String get hangarSeekerBlurb => 'Solana Mobile 先驱 — 经验值与积分 +5%，永久生效。';

  @override
  String get hangarSealedCrate => '密封箱';

  @override
  String get hangarSealedBlurb =>
      '这台机器尚未揭晓。在此之前，它提供固定的持有者加成：经验值与积分 +25%。\n\n揭晓后，它的五个装备特性（船体、推进器、燃料箱、钻头、货舱）即可装备，并按稀有度提供属性加成。揭晓当天记得点击刷新！';

  @override
  String get hangarEquipped => '✅ 已装备 — 普通局中加成生效。\n每周挑战使用统一配装（不含装备）。';

  @override
  String get quantity => '数量';

  @override
  String get airdrop => '空投';

  @override
  String get questsWeeklyTab => '每周';

  @override
  String get questsWeeklyInfo => '大挑战，大奖励。每周一（UTC）重置。';

  @override
  String questsNotEnoughPoints(int cost) {
    return '积分不足（需要 $cost）。到商店购买积分包吧！';
  }

  @override
  String get questJoinDiscordServer => '加入 Discord 服务器';

  @override
  String get questCheckingMembership => '正在检查成员身份…';

  @override
  String get questVerifyMembership => '验证成员身份';

  @override
  String get questDiscordHint => '请先加入服务器，然后点击验证以通过 Discord 确认';

  @override
  String get questPostOnX => '在 X 上发帖';

  @override
  String get questTweetHint => '发布上面的推文，然后粘贴链接进行验证';

  @override
  String get questDiscordUnavailable => 'Discord 验证暂不可用。请稍后重试。';

  @override
  String get questDiscordOpenFailed => '无法打开 Discord。请重试。';

  @override
  String get questDiscordVerified => 'Discord 成员身份已验证！🎉';

  @override
  String get questDiscordVerifyFailed => '无法验证成员身份。请确认你已加入服务器并授权 Discord。';

  @override
  String get signNewContract => '签署新合约';

  @override
  String get corporateContract => '⭐ 公司合约';

  @override
  String prestigeDialogBody(
    int level,
    int sellBonus,
    int startCash,
    String hardcore,
    String badge,
  ) {
    return '签署第 $level 号合约？\n\n重置：世界、现金、机体升级\n保留：经验值、积分、NFT、成就、收藏\n\n永久特权：\n• 矿石售价 +$sellBonus%\n• 起始现金 \$$startCash + 新手套件\n$hardcore• 排行榜 $badge 徽章';
  }

  @override
  String get prestigeHardcoreLine => '• 硬核矿脉：矿石更丰富，危险更致命\n';

  @override
  String get notYet => '暂不';

  @override
  String get signContract => '签署合约';

  @override
  String get recoveryFailedPoints => '救援失败 — 积分不足';

  @override
  String emergencyRecoveryCost(int cost) {
    return '紧急救援（$cost 积分）';
  }

  @override
  String emergencyRecoveryNeed(int cost) {
    return '需要 $cost 积分 — 打开商店';
  }

  @override
  String keepsCargo(int value) {
    return '保住你价值 \$$value 的货物！';
  }

  @override
  String titleUnlocked(String title) {
    return '解锁称号：$title';
  }

  @override
  String get titleProspector => '探矿者';

  @override
  String get titleExcavator => '挖掘者';

  @override
  String get titleDemolitionist => '爆破手';

  @override
  String get titleDeepMiner => '深层矿工';

  @override
  String get titleVoidwalker => '虚空行者';

  @override
  String get titleCoreBreaker => '核心破坏者';

  @override
  String get titleDiggleLegend => 'Diggle 传奇';

  @override
  String get artifactTsFossilFern => '蕨类化石';

  @override
  String get artifactTsFossilFernDesc => '一株史前蕨类的完美印痕。';

  @override
  String get artifactTsOldBoot => '探矿者的靴子';

  @override
  String get artifactTsOldBootDesc => '早在你之前，就有人在这里挖过。';

  @override
  String get artifactTsClayJar => '陶罐';

  @override
  String get artifactTsClayJarDesc => '古代的储物容器，竟然毫发无损。';

  @override
  String get artifactTsArrowhead => '燧石箭头';

  @override
  String get artifactTsArrowheadDesc => '出自一万年前早已消逝的双手。';

  @override
  String get artifactTsCoinHoard => '钱币窖藏';

  @override
  String get artifactTsCoinHoardDesc => '来自某座被遗忘铸币厂的锈蚀钱币。';

  @override
  String get artifactPfMammothTusk => '猛犸象牙';

  @override
  String get artifactPfMammothTuskDesc => '弯曲的象牙，触手冰凉。';

  @override
  String get artifactPfIceLens => '冰透镜';

  @override
  String get artifactPfIceLensDesc => '远古冰层天然形成的透镜。';

  @override
  String get artifactPfFrozenFlower => '冰封之花';

  @override
  String get artifactPfFrozenFlowerDesc => '一朵在绽放途中被封存了千年的花。';

  @override
  String get artifactPfSledRunner => '雪橇滑板';

  @override
  String get artifactPfSledRunnerDesc => '一支再未归来的探险队的遗物。';

  @override
  String get artifactPfAmberInsect => '琥珀中的昆虫';

  @override
  String get artifactPfAmberInsectDesc => '被金色树脂封住的小小旅客。';

  @override
  String get artifactCcSingingGeode => '歌唱晶洞';

  @override
  String get artifactCcSingingGeodeDesc => '它哼着一个刚好低于听觉的音。';

  @override
  String get artifactCcPrismCore => '棱镜核心';

  @override
  String get artifactCcPrismCoreDesc => '将灯光分成一些无名之色。';

  @override
  String get artifactCcPetrifiedEye => '石化之眼';

  @override
  String get artifactCcPetrifiedEyeDesc => '你确信它一直在看着你。';

  @override
  String get artifactCcResonantShard => '共鸣碎片';

  @override
  String get artifactCcResonantShardDesc => '当其他晶体靠近时会震动。';

  @override
  String get artifactCcHollowBell => '空心之钟';

  @override
  String get artifactCcHollowBellDesc => '一口在寂静中鸣响的水晶钟。';

  @override
  String get artifactMcObsidianBlade => '黑曜石刃';

  @override
  String get artifactMcObsidianBladeDesc => '火山玻璃，比任何钻头都锋利。';

  @override
  String get artifactMcFireOpal => '火欧泊';

  @override
  String get artifactMcFireOpalDesc => '内里藏着一枚活火炭的石头。';

  @override
  String get artifactMcBasaltIdol => '玄武岩神像';

  @override
  String get artifactMcBasaltIdolDesc => '由某种偏爱高温之物雕成。';

  @override
  String get artifactMcMeteorFragment => '陨石碎片';

  @override
  String get artifactMcMeteorFragmentDesc => '它自天而降，一直沉到了这么深。';

  @override
  String get artifactMcHeartOfCore => '核心之心';

  @override
  String get artifactMcHeartOfCoreDesc => '仍是温热的。还在跳动吗？';

  @override
  String get achievementOre10 => '首次收获';

  @override
  String get achievementOre10Desc => '采集 10 块矿石';

  @override
  String get achievementOre100 => '矿石猎犬';

  @override
  String get achievementOre100Desc => '采集 100 块矿石';

  @override
  String get achievementOre500 => '追脉者';

  @override
  String get achievementOre500Desc => '采集 500 块矿石';

  @override
  String get achievementOre2000 => '露天矿工';

  @override
  String get achievementOre2000Desc => '采集 2,000 块矿石';

  @override
  String get achievementOre10000 => '吞星者';

  @override
  String get achievementOre10000Desc => '采集 10,000 块矿石';

  @override
  String get achievementDepth50 => '根系之下';

  @override
  String get achievementDepth50Desc => '到达深度 50';

  @override
  String get achievementDepth120 => '深入霜冻';

  @override
  String get achievementDepth120Desc => '到达永久冻土（深度 120）';

  @override
  String get achievementDepth240 => '观晶者';

  @override
  String get achievementDepth240Desc => '到达水晶洞窟（深度 240）';

  @override
  String get achievementDepth360 => '岩浆潜者';

  @override
  String get achievementDepth360Desc => '到达岩浆核心（深度 360）';

  @override
  String get achievementDepth445 => '触底';

  @override
  String get achievementDepth445Desc => '触及世界之底（深度 445）';

  @override
  String get achievementCash1k => '零花钱';

  @override
  String get achievementCash1kDesc => '累计赚取 \$1,000';

  @override
  String get achievementCash25k => '生意矿工';

  @override
  String get achievementCash25kDesc => '累计赚取 \$25,000';

  @override
  String get achievementCash250k => '矿石大亨';

  @override
  String get achievementCash250kDesc => '累计赚取 \$250,000';

  @override
  String get achievementCash1m => 'Diggle 巨富';

  @override
  String get achievementCash1mDesc => '累计赚取 \$1,000,000';

  @override
  String get achievementLevel5 => '开始认真了';

  @override
  String get achievementLevel5Desc => '达到等级 5';

  @override
  String get achievementLevel10 => '两位数';

  @override
  String get achievementLevel10Desc => '达到等级 10';

  @override
  String get achievementLevel18 => '深层老手';

  @override
  String get achievementLevel18Desc => '达到等级 18';

  @override
  String get achievementLevel25 => 'Diggle 满级';

  @override
  String get achievementLevel25Desc => '达到等级 25';

  @override
  String get achievementArtifact1 => '业余考古学家';

  @override
  String get achievementArtifact1Desc => '找到你的第一件文物';

  @override
  String get achievementArtifact10 => '博物馆捐赠者';

  @override
  String get achievementArtifact10Desc => '找到 10 件文物';

  @override
  String get achievementArtifact20 => '首席策展人';

  @override
  String get achievementArtifact20Desc => '完成全部收藏';

  @override
  String get achievementBlast5 => '要爆了，快躲！';

  @override
  String get achievementBlast5Desc => '引爆 5 个爆炸物';

  @override
  String get achievementBlast50 => '定向爆破';

  @override
  String get achievementBlast50Desc => '引爆 50 个爆炸物';

  @override
  String get achievementSales10 => '常客';

  @override
  String get achievementSales10Desc => '出售矿石 10 次';

  @override
  String get achievementSales100 => '市场推手';

  @override
  String get achievementSales100Desc => '出售矿石 100 次';

  @override
  String get achievementDeath1 => '职业风险';

  @override
  String get achievementDeath1Desc => '失去你的第一台钻机';

  @override
  String get achievementDeath25 => '永不言败';

  @override
  String get achievementDeath25Desc => '失去 25 台钻机后依然继续挖掘';

  @override
  String get itemBackupFuel => '备用燃料';

  @override
  String get itemRepairBot => '维修机器人';

  @override
  String get itemDynamite => '炸药';

  @override
  String get itemC4 => 'C4';

  @override
  String get itemSpaceRift => '空间裂隙';

  @override
  String get itemOreScanner => '矿石扫描仪';

  @override
  String get itemHeatShield => '隔热护盾';

  @override
  String get tileEmpty => '空洞';

  @override
  String get tileDirt => '泥土';

  @override
  String get tileRock => '岩石';

  @override
  String get tileCoal => '煤';

  @override
  String get tileCopper => '铜';

  @override
  String get tileSilver => '银';

  @override
  String get tileGold => '金';

  @override
  String get tileSapphire => '蓝宝石';

  @override
  String get tileEmerald => '绿宝石';

  @override
  String get tileRuby => '红宝石';

  @override
  String get tileDiamond => '钻石';

  @override
  String get tileLava => '岩浆';

  @override
  String get tileGas => '气穴';

  @override
  String get tileFrozenDirt => '冻土';

  @override
  String get tileMagmaRock => '岩浆岩';

  @override
  String get tileCrystalOre => '水晶';

  @override
  String get tileUnstableRock => '不稳定岩石';

  @override
  String get tileLootCrate => '补给箱';

  @override
  String get tileArtifact => '文物';

  @override
  String get tileBedrock => '基岩';

  @override
  String questUseExplosivesTitle(int count) {
    return '引爆 $count 个爆炸物';
  }

  @override
  String questUseExplosivesDesc(int count) {
    return '使用炸药或 C4 共 $count 次';
  }

  @override
  String questFindArtifactTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 件文物',
    );
    return '$_temp0';
  }

  @override
  String get questFindArtifactDesc => '在遗迹中挖出埋藏的文物';

  @override
  String questOpenCrateTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '打开 $count 个补给箱',
    );
    return '$_temp0';
  }

  @override
  String get questOpenCrateDesc => '在废弃矿井中撬开补给箱';

  @override
  String get rarityCommon => '普通';

  @override
  String get rarityUncommon => '优良';

  @override
  String get rarityRare => '稀有';

  @override
  String get rarityEpic => '史诗';

  @override
  String get rarityLegendary => '传说';

  @override
  String get itemBackupFuelDesc => '恢复 50 点燃料';

  @override
  String get itemRepairBotDesc => '修复 40 点船体 HP';

  @override
  String get itemDynamiteDesc => '炸开 3×3 区域';

  @override
  String get itemC4Desc => '炸开 5×5 区域';

  @override
  String get itemSpaceRiftDesc => '传送回地面';

  @override
  String get itemOreScannerDesc => '揭示大范围地形';

  @override
  String get itemHeatShieldDesc => '60 秒岩浆免疫';

  @override
  String get biomeTopsoil => '表土层';

  @override
  String get biomePermafrost => '永久冻土';

  @override
  String get biomeCrystalCaverns => '水晶洞窟';

  @override
  String get biomeMagmaCore => '岩浆核心';

  @override
  String get museumArtifactsTab => '文物';

  @override
  String get museumRecordsTab => '记录';

  @override
  String get leaderboardDepthTab => '深度';

  @override
  String get leaderboardPointsTab => '积分';

  @override
  String get leaderboardWeeklyTab => '本周';
}
