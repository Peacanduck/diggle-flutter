// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Diggle';

  @override
  String get tagline => '깊이 파고  •  보물을 캐고  •  더 멀리 가자';

  @override
  String get mineDeepEarnRewards => '깊이 채굴하고, 보상을 획득하세요.';

  @override
  String get pyroLabs => 'PyroLabs';

  @override
  String get version => 'v0.1.0-alpha';

  @override
  String get newGame => '새 게임';

  @override
  String get continueGame => '계속하기';

  @override
  String get loadGame => '불러오기';

  @override
  String get account => '계정';

  @override
  String get settings => '설정';

  @override
  String get howToPlay => '게임 방법';

  @override
  String comingSoon(String feature) {
    return '$feature 곧 출시!';
  }

  @override
  String get helpMiningTitle => '⛏️ 채굴';

  @override
  String get helpMiningBody => '방향 컨트롤로 드릴을 이동하세요. 흙과 바위를 파서 귀중한 광석을 찾으세요.';

  @override
  String get helpFuelTitle => '⛽ 연료';

  @override
  String get helpFuelBody => '이동과 굴착은 연료를 소모합니다. 바닥나기 전에 지상으로 돌아가세요!';

  @override
  String get helpHullTitle => '🛡️ 선체';

  @override
  String get helpHullBody => '너무 높은 곳에서 떨어지면 선체가 손상됩니다. HP를 주시하세요!';

  @override
  String get helpSellingTitle => '💰 판매';

  @override
  String get helpSellingBody => '지상으로 돌아가 상점에서 광석을 팔아 돈을 벌세요.';

  @override
  String get helpUpgradesTitle => '🔧 업그레이드';

  @override
  String get helpUpgradesBody => '돈으로 연료 탱크, 화물칸, 선체 장갑을 업그레이드하세요.';

  @override
  String get helpHazardsTitle => '⚠️ 위험 요소';

  @override
  String get helpHazardsBody => '용암(즉사)과 가스 주머니(피해)를 조심하세요!';

  @override
  String get gotIt => '알겠어요!';

  @override
  String get paused => '일시정지';

  @override
  String get resume => '재개';

  @override
  String get saveGame => '저장';

  @override
  String get restart => '재시작';

  @override
  String get mainMenu => '메인 메뉴';

  @override
  String savedToSlot(int slot) {
    return '슬롯 $slot에 저장됨';
  }

  @override
  String get gameOver => '게임 오버';

  @override
  String depthReached(int depth) {
    return '도달 깊이: ${depth}m';
  }

  @override
  String get tryAgain => '다시 시도';

  @override
  String get loadingDiggle => 'Diggle 로딩 중...';

  @override
  String failedToLoadGame(String error) {
    return '게임 로드 실패:\n$error';
  }

  @override
  String get backToMenu => '메뉴로 돌아가기';

  @override
  String get signInWithEmail => '이메일로 로그인';

  @override
  String get signInWithWallet => '지갑으로 로그인';

  @override
  String get playAsGuest => '게스트로 플레이';

  @override
  String get or => '또는';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get signIn => '로그인';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get password => '비밀번호';

  @override
  String get passwordMinChars => '비밀번호 (최소 6자)';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요? 로그인';

  @override
  String get noAccount => '계정이 없으신가요? 가입하기';

  @override
  String get checkEmailConfirm => '이메일을 확인하여 계정을 인증하세요!';

  @override
  String get invalidEmailPassword => '이메일 또는 비밀번호가 잘못되었습니다';

  @override
  String get emailAlreadyRegistered => '이 이메일로 등록된 계정이 이미 존재합니다';

  @override
  String get pleaseConfirmEmail => '먼저 이메일을 인증해주세요';

  @override
  String get networkError => '네트워크 오류 — 연결을 확인하세요';

  @override
  String get tooManyAttempts => '시도 횟수 초과 — 나중에 다시 시도하세요';

  @override
  String get cancelled => '취소됨';

  @override
  String get pleaseFillFields => '이메일과 비밀번호를 입력해주세요';

  @override
  String get passwordTooShort => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get passwordsNoMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get accountTitle => '계정';

  @override
  String get accountSubtitle => '프로필, 로그인 방법 및 통계';

  @override
  String get playerProfile => '플레이어 프로필';

  @override
  String get enterDisplayName => '표시 이름 입력';

  @override
  String get anonymousMiner => '익명 광부';

  @override
  String memberSince(String date) {
    return '$date부터 회원';
  }

  @override
  String get playingOffline => '오프라인 플레이 중';

  @override
  String get playerIdCopied => '플레이어 ID 복사됨';

  @override
  String get signInMethods => '로그인 방법';

  @override
  String get signInMethodsSubtitle => '계정에 접근하는 방법';

  @override
  String get emailSignIn => '이메일 로그인';

  @override
  String get emailLabel => '이메일';

  @override
  String get solanaWallet => 'Solana 지갑';

  @override
  String get linkedWallet => '연결된 지갑';

  @override
  String get addEmailAlt => '이메일을 대체 로그인 방법으로 추가';

  @override
  String get linkForStore => '상점 구매 및 NFT를 위해 연결';

  @override
  String get primary => '기본';

  @override
  String get linked => '연결됨';

  @override
  String get add => '추가';

  @override
  String get copyAddress => '주소 복사';

  @override
  String get unlink => '연결 해제';

  @override
  String get addEmailSignIn => '이메일 로그인 추가';

  @override
  String get addEmailSubtitle => '지갑이 기본 로그인으로 유지됩니다. 이메일은 대안입니다.';

  @override
  String get addEmail => '이메일 추가';

  @override
  String get checkEmailLink => '이메일을 확인하여 연결을 인증하세요!';

  @override
  String get emailSignInAdded => '이메일 로그인 추가됨!';

  @override
  String get walletConnectionCancelled => '지갑 연결 취소됨';

  @override
  String get couldNotGetWalletAddress => '지갑 주소를 가져올 수 없습니다';

  @override
  String get signingCancelled => '서명이 취소되었습니다';

  @override
  String get walletLinked => '지갑 연결 완료! 이제 지갑으로 로그인할 수 있습니다.';

  @override
  String get walletLinkFailed => '지갑 연결 실패';

  @override
  String get unlinkWalletTitle => '지갑 연결 해제';

  @override
  String get unlinkWalletMessage => '지갑이 계정에서 제거됩니다. 이후 다른 지갑을 연결할 수 있습니다.';

  @override
  String get cancel => '취소';

  @override
  String get walletUnlinked => '지갑 연결 해제됨';

  @override
  String get unlinkFailed => '연결 해제 실패';

  @override
  String get walletAdapter => '지갑 어댑터';

  @override
  String get walletAdapterGuestSubtitle => '이번 세션의 구매를 위해 연결';

  @override
  String get walletAdapterReconnectSubtitle => '거래 서명을 위해 재연결';

  @override
  String get walletAdapterConnectSubtitle => '상점 이용을 위해 연결';

  @override
  String get network => '네트워크';

  @override
  String get mainnet => '메인넷';

  @override
  String get devnet => '개발넷';

  @override
  String connected(String network) {
    return '연결됨 — $network';
  }

  @override
  String get loadingBalance => '잔액 로딩 중...';

  @override
  String get airdropRequested => '에어드롭 요청됨!';

  @override
  String get airdropFailed => '에어드롭 실패';

  @override
  String get disconnectNote =>
      '연결 해제는 어댑터 세션만 종료합니다. 계정은 연결된 상태로 유지됩니다 — 언제든 재연결하세요.';

  @override
  String get disconnectAdapter => '어댑터 연결 해제';

  @override
  String get connecting => '연결 중...';

  @override
  String get connectWallet => '지갑 연결';

  @override
  String get phantomTip => '💡 최고의 개발넷 지원을 위해 Phantom 지갑을 사용하세요';

  @override
  String get addressCopied => '주소 복사됨';

  @override
  String get lifetimeStats => '전체 통계';

  @override
  String get statLevel => '레벨';

  @override
  String get statTotalXp => '총 XP';

  @override
  String get statPoints => '포인트';

  @override
  String get statOresMined => '채굴한 광석';

  @override
  String get statMaxDepth => '최대 깊이';

  @override
  String get statPlayTime => '플레이 시간';

  @override
  String get statPointsEarned => '획득 포인트';

  @override
  String get statPointsSpent => '사용 포인트';

  @override
  String get signedInEmail => '이메일로 로그인됨';

  @override
  String get signedInWallet => '지갑으로 로그인됨';

  @override
  String get playingAsGuest => '게스트로 플레이 중';

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutConfirm => '정말 로그아웃하시겠습니까?';

  @override
  String get guestSignOutWarning =>
      '게스트 진행 상황은 이 기기에만 저장됩니다. 로그아웃하면 현재 저장 데이터에 접근할 수 없습니다. 계속하시겠습니까?';

  @override
  String get emailAccount => '이메일 계정';

  @override
  String get walletAccount => '지갑 계정';

  @override
  String get guestLocalOnly => '게스트 — 로컬 진행만 가능';

  @override
  String get offline => '오프라인';

  @override
  String get newGameTitle => '새 게임';

  @override
  String get loadGameTitle => '게임 불러오기';

  @override
  String get newGameSubtitle => '새 모험을 위한 저장 슬롯을 선택하세요';

  @override
  String get loadGameSubtitle => '여정을 계속할 저장 파일을 선택하세요';

  @override
  String slotEmpty(int slot) {
    return '슬롯 $slot — 비어있음';
  }

  @override
  String get tapToStart => '탭하여 새 모험 시작';

  @override
  String get noSaveData => '저장 데이터 없음';

  @override
  String slot(int slot) {
    return '슬롯 $slot';
  }

  @override
  String savedAgo(String time) {
    return '$time 전 저장';
  }

  @override
  String deleteSlotConfirm(int slot) {
    return '슬롯 $slot을(를) 삭제하시겠습니까?';
  }

  @override
  String get cannotBeUndone => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get delete => '삭제';

  @override
  String get overwriteSaveTitle => '덮어쓰기?';

  @override
  String overwriteSaveMessage(int slot) {
    return '슬롯 $slot에 이미 저장 데이터가 있습니다. 여기서 새 게임을 시작하면 덮어씁니다.';
  }

  @override
  String get overwrite => '덮어쓰기';

  @override
  String get noSaves => '(저장 없음)';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int min) {
    return '$min분 전';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String daysAgo(int days) {
    return '$days일 전';
  }

  @override
  String get hp => 'HP';

  @override
  String get fuel => '연료';

  @override
  String get items => '아이템: ';

  @override
  String get store => '상점';

  @override
  String get shop => '상점';

  @override
  String depthMeter(int depth) {
    return '${depth}m';
  }

  @override
  String get miningSupplyCo => '채굴 용품점';

  @override
  String get cash => '돈';

  @override
  String get hull => '선체';

  @override
  String get fuelLabel => '연료';

  @override
  String get cargo => '화물칸';

  @override
  String get services => '서비스';

  @override
  String get upgrades => '업그레이드';

  @override
  String get itemsTab => '아이템';

  @override
  String get sellOre => '광석 판매';

  @override
  String get noOreToSell => '판매할 광석이 없습니다';

  @override
  String get totalValue => '총 가치:';

  @override
  String get sellAll => '모두 판매';

  @override
  String get refuel => '연료 보급';

  @override
  String refuelCost(int cost) {
    return '연료 보급 (\$$cost)';
  }

  @override
  String get tankFull => '탱크가 가득 찼습니다!';

  @override
  String get repair => '수리';

  @override
  String repairHullCost(int cost) {
    return '선체 수리 (\$$cost)';
  }

  @override
  String get hullFullyRepaired => '선체 완전 수리 완료!';

  @override
  String inventorySlots(int used, int max) {
    return '인벤토리: $used/$max 칸';
  }

  @override
  String upgradeCost(int cost) {
    return '업그레이드 - \$$cost';
  }

  @override
  String get maxed => '최대';

  @override
  String get drillBit => '드릴 비트';

  @override
  String get engine => '엔진';

  @override
  String get cooling => '냉각';

  @override
  String get fuelTank => '연료 탱크';

  @override
  String get cargoBay => '화물칸';

  @override
  String get hullArmor => '선체 장갑';

  @override
  String capacityValue(int value) {
    return '용량: $value';
  }

  @override
  String speedPercent(int percent) {
    return '속도: $percent%';
  }

  @override
  String fuelSavingsPercent(int percent) {
    return '연료 절약: $percent%';
  }

  @override
  String get noFuelSavings => '연료 절약 없음';

  @override
  String maxHpValue(int value) {
    return '최대 HP: $value';
  }

  @override
  String get returnToMining => '채굴로 돌아가기';

  @override
  String soldOreFor(int amount) {
    return '광석을 \$$amount에 판매했습니다!';
  }

  @override
  String get tankRefueled => '연료 보급 완료!';

  @override
  String get fuelTankUpgraded => '연료 탱크 업그레이드!';

  @override
  String get cargoBayUpgraded => '화물칸 업그레이드!';

  @override
  String get hullRepaired => '선체 수리 완료!';

  @override
  String get hullArmorUpgraded => '선체 장갑 업그레이드!';

  @override
  String get drillBitUpgraded => '드릴 비트 업그레이드!';

  @override
  String get engineUpgraded => '엔진 업그레이드!';

  @override
  String get coolingUpgraded => '냉각 시스템 업그레이드!';

  @override
  String purchased(String item) {
    return '$item 구매 완료!';
  }

  @override
  String get premiumStore => '프리미엄 상점';

  @override
  String get onChainLoaded => '온체인 가격 로드됨';

  @override
  String get usingDefaultPrices => '기본 가격 사용 중';

  @override
  String get level => '레벨';

  @override
  String get xp => 'XP';

  @override
  String get points => '포인트';

  @override
  String get activeBoosts => '활성 부스트';

  @override
  String get permanent => '영구';

  @override
  String get pointsTab => '포인트';

  @override
  String get solTab => 'SOL';

  @override
  String get nftTab => 'NFT';

  @override
  String get walletRequired => '지갑 필요';

  @override
  String get walletRequiredMessage =>
      '프리미엄 아이템에 접근하려면 Solana 지갑을 연결하세요.\n모든 구매는 온체인 거래입니다.';

  @override
  String get storePricesUnavailable => '상점 가격 불가';

  @override
  String get storePricesUnavailableMessage =>
      '온체인 가격을 불러올 수 없습니다.\n연결을 확인하고 다시 시도하세요.';

  @override
  String get retry => '재시도';

  @override
  String get buy => '구매';

  @override
  String get notEnoughPoints => '포인트가 부족합니다!';

  @override
  String activated(String item) {
    return '$item 활성화!';
  }

  @override
  String purchasedTx(String item, String tx) {
    return '$item 구매 완료! TX: $tx...';
  }

  @override
  String get purchaseFailed => '구매 실패';

  @override
  String get closeStore => '상점 닫기';

  @override
  String get diggleDrillMachine => 'DIGGLE 드릴 머신';

  @override
  String get permanentBoostNft => '영구 부스트 NFT — 플레이어당 1개';

  @override
  String get holderBenefits => '보유자 혜택';

  @override
  String get permanentXpBoost => '영구 XP 부스트';

  @override
  String get permanentPointsBoost => '영구 포인트 부스트';

  @override
  String get limitedSupply => '한정 수량';

  @override
  String get soldOut => '매진';

  @override
  String get allNftsMinted => '모든 Diggle Drill NFT가 민팅되었습니다!';

  @override
  String get mintOpensSoon => '민팅 곧 시작';

  @override
  String startsAt(String date) {
    return '시작: $date';
  }

  @override
  String get checkBackLater => '나중에 다시 확인하세요!';

  @override
  String get mintNft => 'NFT 민팅';

  @override
  String mintCost(String cost) {
    return '민팅 — $cost SOL';
  }

  @override
  String get nftMinted => 'NFT 민팅 완료! 🎉';

  @override
  String get refresh => '새로고침';

  @override
  String get boostsActive => '부스트가 영구 활성화되었습니다!';

  @override
  String get mintStatusPreparing => '거래 준비 중...';

  @override
  String get mintStatusApprove => '지갑에서 승인하세요...';

  @override
  String get mintStatusSending => '거래 전송 중...';

  @override
  String get mintStatusConfirming => '온체인 확인 중...';

  @override
  String get mintStatusSuccess => '민팅 성공!';

  @override
  String get mintStatusError => '민팅 실패';

  @override
  String xpLabel(int current, int next) {
    return 'XP: $current/$next';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSubtitle => '게임 환경 설정';

  @override
  String get language => '언어';

  @override
  String get languageSubtitle => '선호하는 언어를 선택하세요';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get pleaseFillAllFields => '모든 항목을 입력해주세요';

  @override
  String errorPrefix(String message) {
    return '오류: $message';
  }

  @override
  String get updateAvailableTitle => '업데이트 가능';

  @override
  String get updateRequiredTitle => '업데이트 필요';

  @override
  String get updateRequiredMessage =>
      '이 버전의 Diggle은 더 이상 지원되지 않습니다. 계속 플레이하려면 업데이트하세요.';

  @override
  String get currentVersionLabel => '현재';

  @override
  String get latestVersionLabel => '최신';

  @override
  String get requiredVersionLabel => '필수';

  @override
  String get updateNow => '지금 업데이트';

  @override
  String get updateLater => '나중에';

  @override
  String get updateOpenStoreFailed => 'dApp Store를 열 수 없습니다. 수동으로 업데이트해주세요.';

  @override
  String get light => '조명';

  @override
  String get lightUpgraded => '조명 시스템 업그레이드!';

  @override
  String revealRadiusValue(int radius) {
    return '탐지 범위: $radius 타일';
  }

  @override
  String get questsTitle => '퀘스트';

  @override
  String get questsSubtitle => '퀘스트를 완료하여 XP와 포인트를 획득하세요';

  @override
  String get questsDailyTab => '일일';

  @override
  String get questsSocialTab => '소셜';

  @override
  String get questsClaim => '수령';

  @override
  String get questsClaimed => '✓ 수령됨';

  @override
  String get questsGo => '이동';

  @override
  String get questsClose => '닫기';

  @override
  String get questsNoDailyQuests => '가능한 일일 퀘스트가 없습니다';

  @override
  String get questsSocialInfo => '소셜 활동을 완료하여 일회성 보상을 받으세요. 이동을 탭하여 링크를 여세요.';

  @override
  String get quests => '퀘스트';

  @override
  String questMineOreTitle(int count) {
    return '광석 $count개 채굴';
  }

  @override
  String questMineOreDesc(int count) {
    return '하루에 광석 타일 $count개 채굴';
  }

  @override
  String questReachDepthTitle(int depth) {
    return '${depth}m 도달';
  }

  @override
  String questReachDepthDesc(int depth) {
    return '${depth}m 이상 깊이에 도달';
  }

  @override
  String questSellOreTitle(int value) {
    return '\$$value 어치 판매';
  }

  @override
  String questSellOreDesc(int value) {
    return '총 \$$value 어치의 광석 판매';
  }

  @override
  String questRepairTitle(int amount) {
    return 'HP $amount 수리';
  }

  @override
  String questRepairDesc(int amount) {
    return '총 선체 HP $amount 수리';
  }

  @override
  String questUseItemsTitle(int count) {
    return '아이템 $count개 사용';
  }

  @override
  String questUseItemsDesc(int count) {
    return '인벤토리에서 아이템 $count개 사용';
  }

  @override
  String get questFollowTwitterTitle => 'X 팔로우';

  @override
  String get questFollowTwitterDesc => 'X (Twitter)에서 @DiggleGame 팔로우';

  @override
  String get questJoinDiscordTitle => 'Discord 참여';

  @override
  String get questJoinDiscordDesc => 'Diggle Discord 커뮤니티에 참여';

  @override
  String get questPostTweetTitle => 'X에 공유';

  @override
  String get questPostTweetDesc => 'Diggle에 대한 트윗 게시';

  @override
  String get questVerifyButton => '인증';

  @override
  String get questPasteTweetUrl => '트윗 URL을 여기에 붙여넣으세요';

  @override
  String get questVerifying => '인증 중...';

  @override
  String get questVerified => '퀘스트 인증 및 완료!';

  @override
  String get questVerificationFailed => '인증할 수 없습니다. 다시 시도해주세요.';
}
