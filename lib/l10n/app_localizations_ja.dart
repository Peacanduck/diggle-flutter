// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline => '深く掘れ  •  富を採れ  •  もっと先へ';

  @override
  String get mineDeepEarnRewards => '深く掘って、報酬を獲得しよう。';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => 'ニューゲーム';

  @override
  String get continueGame => 'つづきから';

  @override
  String get loadGame => 'ロード';

  @override
  String get account => 'アカウント';

  @override
  String get settings => '設定';

  @override
  String get howToPlay => '遊び方';

  @override
  String comingSoon(String feature) {
    return '$feature 近日公開！';
  }

  @override
  String get helpMiningTitle => '⛏️ 採掘';

  @override
  String get helpMiningBody => '方向コントロールでドリルを操作します。土や岩を掘って、貴重な鉱石を見つけましょう。';

  @override
  String get helpFuelTitle => '⛽ 燃料';

  @override
  String get helpFuelBody => '移動と掘削で燃料を消費します。なくなる前に地上に戻りましょう！';

  @override
  String get helpHullTitle => '🛡️ 船体';

  @override
  String get helpHullBody => '高所からの落下で船体がダメージを受けます。HPに注意！';

  @override
  String get helpSellingTitle => '💰 売却';

  @override
  String get helpSellingBody => '地上に戻ってショップで鉱石を売ってお金を稼ぎましょう。';

  @override
  String get helpUpgradesTitle => '🔧 アップグレード';

  @override
  String get helpUpgradesBody => 'お金で燃料タンク、貨物室、船体装甲をアップグレードしましょう。';

  @override
  String get helpHazardsTitle => '⚠️ 危険';

  @override
  String get helpHazardsBody => '溶岩（即死）とガスポケット（ダメージ）に注意！';

  @override
  String get gotIt => '了解！';

  @override
  String get paused => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get saveGame => 'セーブ';

  @override
  String get restart => 'やり直す';

  @override
  String get mainMenu => 'メインメニュー';

  @override
  String savedToSlot(int slot) {
    return 'スロット$slotにセーブしました';
  }

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String depthReached(int depth) {
    return '到達深度：${depth}m';
  }

  @override
  String get tryAgain => 'リトライ';

  @override
  String get loadingDiggle => 'Diggle を読み込み中...';

  @override
  String failedToLoadGame(String error) {
    return 'ゲームの読み込みに失敗しました：\n$error';
  }

  @override
  String get backToMenu => 'メニューに戻る';

  @override
  String get signInWithEmail => 'メールでログイン';

  @override
  String get signInWithWallet => 'ウォレットでログイン';

  @override
  String get playAsGuest => 'ゲストでプレイ';

  @override
  String get or => 'または';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get signIn => 'ログイン';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get passwordMinChars => 'パスワード（6文字以上）';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get alreadyHaveAccount => 'アカウントをお持ちですか？ログイン';

  @override
  String get noAccount => 'アカウントがありませんか？登録';

  @override
  String get checkEmailConfirm => 'メールを確認してアカウントを認証してください！';

  @override
  String get invalidEmailPassword => 'メールアドレスまたはパスワードが無効です';

  @override
  String get emailAlreadyRegistered => 'このメールアドレスは既に登録されています';

  @override
  String get pleaseConfirmEmail => 'まずメールアドレスを確認してください';

  @override
  String get networkError => 'ネットワークエラー — 接続を確認してください';

  @override
  String get tooManyAttempts => '試行回数が多すぎます — しばらくしてから再試行してください';

  @override
  String get cancelled => 'キャンセルされました';

  @override
  String get pleaseFillFields => 'メールアドレスとパスワードを入力してください';

  @override
  String get passwordTooShort => 'パスワードは6文字以上必要です';

  @override
  String get passwordsNoMatch => 'パスワードが一致しません';

  @override
  String get accountTitle => 'アカウント';

  @override
  String get accountSubtitle => 'プロフィール、ログイン方法、統計';

  @override
  String get playerProfile => 'プレイヤープロフィール';

  @override
  String get enterDisplayName => '表示名を入力';

  @override
  String get anonymousMiner => '匿名マイナー';

  @override
  String memberSince(String date) {
    return '$dateから登録';
  }

  @override
  String get playingOffline => 'オフラインでプレイ中';

  @override
  String get playerIdCopied => 'プレイヤーIDをコピーしました';

  @override
  String get signInMethods => 'ログイン方法';

  @override
  String get signInMethodsSubtitle => 'アカウントへのアクセス方法';

  @override
  String get emailSignIn => 'メールログイン';

  @override
  String get emailLabel => 'メール';

  @override
  String get solanaWallet => 'Solana ウォレット';

  @override
  String get linkedWallet => 'リンク済みウォレット';

  @override
  String get addEmailAlt => '代替ログイン方法としてメールを追加';

  @override
  String get linkForStore => 'ストア購入とNFT用にリンク';

  @override
  String get primary => 'メイン';

  @override
  String get linked => 'リンク済み';

  @override
  String get add => '追加';

  @override
  String get copyAddress => 'アドレスをコピー';

  @override
  String get unlink => 'リンク解除';

  @override
  String get addEmailSignIn => 'メールログインを追加';

  @override
  String get addEmailSubtitle => 'ウォレットがメインのログイン方法として残ります。メールは代替手段です。';

  @override
  String get addEmail => 'メールを追加';

  @override
  String get checkEmailLink => 'メールを確認してリンクを認証してください！';

  @override
  String get emailSignInAdded => 'メールログインを追加しました！';

  @override
  String get walletConnectionCancelled => 'ウォレット接続がキャンセルされました';

  @override
  String get couldNotGetWalletAddress => 'ウォレットアドレスを取得できませんでした';

  @override
  String get signingCancelled => '署名がキャンセルされました';

  @override
  String get walletLinked => 'ウォレットがリンクされました！これでウォレットでログインできます。';

  @override
  String get walletLinkFailed => 'ウォレットのリンクに失敗しました';

  @override
  String get unlinkWalletTitle => 'ウォレットのリンク解除';

  @override
  String get unlinkWalletMessage => 'ウォレットがアカウントから削除されます。その後、別のウォレットをリンクできます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get walletUnlinked => 'ウォレットのリンクが解除されました';

  @override
  String get unlinkFailed => 'リンク解除に失敗しました';

  @override
  String get walletAdapter => 'ウォレットアダプター';

  @override
  String get walletAdapterGuestSubtitle => 'このセッションの購入用に接続';

  @override
  String get walletAdapterReconnectSubtitle => 'トランザクション署名のために再接続';

  @override
  String get walletAdapterConnectSubtitle => 'ストア利用のために接続';

  @override
  String get network => 'ネットワーク';

  @override
  String get mainnet => 'メインネット';

  @override
  String get devnet => '開発ネット';

  @override
  String connected(String network) {
    return '接続済み — $network';
  }

  @override
  String get loadingBalance => '残高を読み込み中...';

  @override
  String get airdropRequested => 'エアドロップをリクエストしました！';

  @override
  String get airdropFailed => 'エアドロップ失敗';

  @override
  String get disconnectNote =>
      '切断はアダプターセッションのみ終了します。アカウントはリンクされたまま — いつでも再接続できます。';

  @override
  String get disconnectAdapter => 'アダプター切断';

  @override
  String get connecting => '接続中...';

  @override
  String get connectWallet => 'ウォレット接続';

  @override
  String get phantomTip => '💡 Phantom ウォレットで最高の開発ネットサポートを';

  @override
  String get addressCopied => 'アドレスをコピーしました';

  @override
  String get lifetimeStats => '通算統計';

  @override
  String get statLevel => 'レベル';

  @override
  String get statTotalXp => '合計XP';

  @override
  String get statPoints => 'ポイント';

  @override
  String get statOresMined => '採掘した鉱石';

  @override
  String get statMaxDepth => '最大深度';

  @override
  String get statPlayTime => 'プレイ時間';

  @override
  String get statPointsEarned => '獲得ポイント';

  @override
  String get statPointsSpent => '使用ポイント';

  @override
  String get signedInEmail => 'メールでログイン中';

  @override
  String get signedInWallet => 'ウォレットでログイン中';

  @override
  String get playingAsGuest => 'ゲストでプレイ中';

  @override
  String get signOut => 'ログアウト';

  @override
  String get signOutConfirm => 'ログアウトしてもよろしいですか？';

  @override
  String get guestSignOutWarning =>
      'ゲストの進行状況はこのデバイスのみに保存されます。ログアウトすると現在のセーブデータにアクセスできなくなります。よろしいですか？';

  @override
  String get emailAccount => 'メールアカウント';

  @override
  String get walletAccount => 'ウォレットアカウント';

  @override
  String get guestLocalOnly => 'ゲスト — ローカルの進行のみ';

  @override
  String get offline => 'オフライン';

  @override
  String get newGameTitle => 'ニューゲーム';

  @override
  String get loadGameTitle => 'ゲームをロード';

  @override
  String get newGameSubtitle => '新しい冒険のセーブスロットを選んでください';

  @override
  String get loadGameSubtitle => '冒険を続けるセーブデータを選んでください';

  @override
  String slotEmpty(int slot) {
    return 'スロット$slot — 空き';
  }

  @override
  String get tapToStart => 'タップして新しい冒険を始めよう';

  @override
  String get noSaveData => 'セーブデータなし';

  @override
  String slot(int slot) {
    return 'スロット$slot';
  }

  @override
  String savedAgo(String time) {
    return '$time前にセーブ';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return 'スロット$slotを削除しますか？';
  }

  @override
  String get cannotBeUndone => 'この操作は元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get overwriteSaveTitle => '上書きしますか？';

  @override
  String overwriteSaveMessage(int slot) {
    return 'スロット$slotにはすでにセーブデータがあります。ここで新しいゲームを始めると上書きされます。';
  }

  @override
  String get overwrite => '上書き';

  @override
  String get noSaves => '（セーブなし）';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int min) {
    return '$min分前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String daysAgo(int days) {
    return '$days日前';
  }

  @override
  String get hp => 'HP';

  @override
  String get fuel => '燃料';

  @override
  String get items => 'アイテム：';

  @override
  String get store => 'ストア';

  @override
  String get shop => 'ショップ';

  @override
  String depthMeter(int depth) {
    return '${depth}m';
  }

  @override
  String get miningSupplyCo => '採掘用品店';

  @override
  String get cash => 'お金';

  @override
  String get hull => '船体';

  @override
  String get fuelLabel => '燃料';

  @override
  String get cargo => '貨物室';

  @override
  String get services => 'サービス';

  @override
  String get upgrades => 'アップグレード';

  @override
  String get itemsTab => 'アイテム';

  @override
  String get sellOre => '鉱石を売る';

  @override
  String get noOreToSell => '売る鉱石がありません';

  @override
  String get totalValue => '合計金額：';

  @override
  String get sellAll => 'すべて売る';

  @override
  String get refuel => '給油';

  @override
  String refuelCost(int cost) {
    return '給油（\$$cost）';
  }

  @override
  String get tankFull => 'タンクは満タンです！';

  @override
  String get repair => '修理';

  @override
  String repairHullCost(int cost) {
    return '船体修理（\$$cost）';
  }

  @override
  String get hullFullyRepaired => '船体の修理が完了しました！';

  @override
  String inventorySlots(int used, int max) {
    return 'インベントリ：$used/$max スロット';
  }

  @override
  String upgradeCost(int cost) {
    return 'アップグレード - \$$cost';
  }

  @override
  String get maxed => '最大';

  @override
  String get drillBit => 'ドリルビット';

  @override
  String get engine => 'エンジン';

  @override
  String get cooling => '冷却装置';

  @override
  String get fuelTank => '燃料タンク';

  @override
  String get cargoBay => '貨物室';

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
    return '燃料節約：$percent%';
  }

  @override
  String get noFuelSavings => '燃料節約なし';

  @override
  String maxHpValue(int value) {
    return '最大HP：$value';
  }

  @override
  String get returnToMining => '採掘に戻る';

  @override
  String soldOreFor(int amount) {
    return '鉱石を\$$amountで売却しました！';
  }

  @override
  String get tankRefueled => '給油完了！';

  @override
  String get fuelTankUpgraded => '燃料タンクをアップグレード！';

  @override
  String get cargoBayUpgraded => '貨物室をアップグレード！';

  @override
  String get hullRepaired => '船体を修理しました！';

  @override
  String get hullArmorUpgraded => '船体装甲をアップグレード！';

  @override
  String get drillBitUpgraded => 'ドリルビットをアップグレード！';

  @override
  String get engineUpgraded => 'エンジンをアップグレード！';

  @override
  String get coolingUpgraded => '冷却装置をアップグレード！';

  @override
  String purchased(String item) {
    return '$itemを購入しました！';
  }

  @override
  String get premiumStore => 'プレミアムストア';

  @override
  String get onChainLoaded => 'オンチェーン価格を読み込みました';

  @override
  String get usingDefaultPrices => 'デフォルト価格を使用中';

  @override
  String get level => 'レベル';

  @override
  String get xp => 'XP';

  @override
  String get points => 'ポイント';

  @override
  String get activeBoosts => 'アクティブブースト';

  @override
  String get permanent => '永久';

  @override
  String get pointsTab => 'ポイント';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => 'ウォレットが必要です';

  @override
  String get walletRequiredMessage =>
      'プレミアムアイテムにアクセスするにはSolanaウォレットを接続してください。\nすべての購入はオンチェーン取引です。';

  @override
  String get storePricesUnavailable => 'ストア価格が利用できません';

  @override
  String get storePricesUnavailableMessage =>
      'オンチェーン価格を読み込めませんでした。\n接続を確認して再試行してください。';

  @override
  String get retry => 'リトライ';

  @override
  String get buy => '購入';

  @override
  String get notEnoughPoints => 'ポイントが足りません！';

  @override
  String activated(String item) {
    return '$itemを有効化しました！';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$itemを購入しました！TX：$tx...';
  }

  @override
  String get purchaseFailed => '購入失敗';

  @override
  String get closeStore => 'ストアを閉じる';

  @override
  String get diggleDrillMachine => 'DIGGLE ドリルマシン';

  @override
  String get permanentBoostNft => '永久ブーストNFT — プレイヤー1人につき1つ';

  @override
  String get holderBenefits => '保有者特典';

  @override
  String get permanentXpBoost => '永久XPブースト';

  @override
  String get permanentPointsBoost => '永久ポイントブースト';

  @override
  String get limitedSupply => '数量限定';

  @override
  String get soldOut => '完売';

  @override
  String get allNftsMinted => 'すべてのDiggle Drill NFTがミントされました！';

  @override
  String get mintOpensSoon => 'ミント近日開始';

  @override
  String startsAt(String date) {
    return '開始：$date';
  }

  @override
  String get checkBackLater => '後でまた確認してください！';

  @override
  String get mintNft => 'NFTをミント';

  @override
  String mintCost(String cost) {
    return 'ミント — $cost SOL';
  }

  @override
  String get nftMinted => 'NFTミント完了！🎉';

  @override
  String get refresh => '更新';

  @override
  String get boostsActive => 'ブーストが永久に有効です！';

  @override
  String get mintStatusPreparing => 'トランザクションを準備中...';

  @override
  String get mintStatusApprove => 'ウォレットで承認してください...';

  @override
  String get mintStatusSending => 'トランザクションを送信中...';

  @override
  String get mintStatusConfirming => 'オンチェーン確認中...';

  @override
  String get mintStatusSuccess => 'ミント成功！';

  @override
  String get mintStatusError => 'ミント失敗';

  @override
  String xpLabel(int current, int next) {
    return 'XP：$current/$next';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSubtitle => 'ゲーム設定';

  @override
  String get language => '言語';

  @override
  String get languageSubtitle => '使用する言語を選択してください';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get pleaseFillAllFields => 'すべてのフィールドに入力してください';

  @override
  String errorPrefix(String message) {
    return 'エラー：$message';
  }

  @override
  String get updateAvailableTitle => 'アップデートが利用可能です';

  @override
  String get updateRequiredTitle => 'アップデートが必要です';

  @override
  String get updateRequiredMessage =>
      'このバージョンのDiggleはサポートが終了しました。プレイを続けるにはアップデートしてください。';

  @override
  String get currentVersionLabel => '現在';

  @override
  String get latestVersionLabel => '最新';

  @override
  String get requiredVersionLabel => '必須';

  @override
  String get updateNow => '今すぐアップデート';

  @override
  String get updateLater => '後で';

  @override
  String get updateOpenStoreFailed => 'dApp Storeを開けませんでした。手動でアップデートしてください。';

  @override
  String get light => 'ライト';

  @override
  String get lightUpgraded => '照明システムをアップグレード！';

  @override
  String revealRadiusValue(int radius) {
    return '照射範囲：$radius タイル';
  }

  @override
  String get questsTitle => 'クエスト';

  @override
  String get questsSubtitle => 'クエストを完了してXPとポイントを獲得';

  @override
  String get questsDailyTab => 'デイリー';

  @override
  String get questsSocialTab => 'ソーシャル';

  @override
  String get questsClaim => '受け取る';

  @override
  String get questsClaimed => '✓ 受取済み';

  @override
  String get questsGo => 'GO';

  @override
  String get questsClose => '閉じる';

  @override
  String get questsNoDailyQuests => '利用可能なデイリークエストがありません';

  @override
  String get questsSocialInfo => 'ソーシャルアクションを完了して一度限りの報酬を獲得。GOをタップしてリンクを開きます。';

  @override
  String get quests => 'クエスト';

  @override
  String questMineOreTitle(int count) {
    return '鉱石を$count個採掘';
  }

  @override
  String questMineOreDesc(int count) {
    return '1日で鉱石タイルを$count個採掘する';
  }

  @override
  String questReachDepthTitle(int depth) {
    return '${depth}mに到達';
  }

  @override
  String questReachDepthDesc(int depth) {
    return '${depth}m以上の深さに到達する';
  }

  @override
  String questSellOreTitle(int value) {
    return '\$$value分を売却';
  }

  @override
  String questSellOreDesc(int value) {
    return '合計\$$value分の鉱石を売却する';
  }

  @override
  String questRepairTitle(int amount) {
    return 'HP$amountを修理';
  }

  @override
  String questRepairDesc(int amount) {
    return '合計で船体HP$amountを修理する';
  }

  @override
  String questUseItemsTitle(int count) {
    return 'アイテムを$count個使用';
  }

  @override
  String questUseItemsDesc(int count) {
    return 'インベントリからアイテムを$count個使用する';
  }

  @override
  String get questFollowTwitterTitle => 'Xでフォロー';

  @override
  String get questFollowTwitterDesc => 'X (Twitter) で @DiggleGame をフォロー';

  @override
  String get questJoinDiscordTitle => 'Discordに参加';

  @override
  String get questJoinDiscordDesc => 'Diggle Discordコミュニティに参加';

  @override
  String get questPostTweetTitle => 'Xでシェア';

  @override
  String get questPostTweetDesc => 'Diggleについてツイートする';

  @override
  String get questVerifyButton => '認証';

  @override
  String get questPasteTweetUrl => 'ツイートのURLをここに貼り付けてください';

  @override
  String get questVerifying => '認証中...';

  @override
  String get questVerified => 'クエスト認証・完了！';

  @override
  String get questVerificationFailed => '認証できませんでした。もう一度お試しください。';
}
