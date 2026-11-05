import SwiftUI

/// Figma "Ana Sayfa - Kıta Yolu" (node 271:5428) — tüm 4 kategorinin ortak ana ekranı.
/// Kullanıcı kararı: kategori kartına dokunmak NavigationStack push'u YAPMAMALI (geri
/// kaydırma jestli, farklı bir "sayfa" hissi veren bir geçiş) — Bayrak Tahmin zaten hep
/// push'suz görünüyordu (bu ekranın kendisi olduğu için), diğer üç kategori de aynı
/// şekilde `selectedCategory` durumuyla YERİNDE değişmeli. Yalnızca bir kıtaya/etaba
/// girmek (EtapMapView, Quiz) hâlâ push kalıyor — Bayrak Tahmin'in kendi kıta/etap
/// geçişleri zaten hep push'tu, buradaki şikayet yalnızca kategori düzeyindeydi.
struct HomeView: View {
    @Binding var selectedTab: GeoTab
    /// RootTabView'de tutulur (bkz. RootTabView.swift'teki mimari notu) — sekme
    /// değiştirince sıfırlanmaması için burada @State değil @Binding/referans.
    @Binding var points: Int
    /// Üst çubuktaki seri sayısı. Eskiden `@State` idi: @State ilk değeri sabitleyip ebeveynden gelen
    /// güncellemeleri yok sayıyordu — bir seviye bitince seri artsa da sayaç sekme değişene kadar eski kalıyordu.
    var streak: Int
    /// Dün oynanmış, bugün henüz oynanmamış — bkz. Streak.swift/StreakStatus.atRisk.
    var streakAtRisk: Bool = false
    /// iCloud/ağ şu an erişilemiyor — ilerleme cihazda saklanıyor ama buluta
    /// gitmiyor (bkz. AppState.cloudReachable/LocalProfileCache). Kullanıcıya
    /// açık bilgi vermek için (bkz. yol haritası "kullanıcıya açık bilgi" maddesi).
    var cloudReachable: Bool = true
    var cloudAccountMissing: Bool = false
    /// RootTabView'in sahip olduğu paylaşılan örnek — HomeView kendi kopyasını
    /// oluşturmuyor (bkz. RootTabView.swift'teki mimari notu).
    var progress: GameProgress
    /// Header'daki profil kısayolu için — bkz. topBar. Kullanıcı hiç avatar
    /// oluşturmadıysa (hasCustomAvatar == false) gerçek renk/karakter yerine sabit
    /// mor + profil ikonu gösterilir (bkz. ProfileView.avatarSection'daki GeoAvatar
    /// kullanımıyla aynı veri, ayrı bir kopya tutulmuyor).
    var avatarColorHex: UInt32 = 0xFF987E
    var avatarCharacter: AvatarCharacter = AvatarCharacter()
    var hasCustomAvatar: Bool = false
    var isGuest: Bool = false
    var onRequireSignIn: () -> Void = {}
    /// Bir etap bitince çağrılır — AppState.recordStageCompletion'a kadar iletilir (bkz.
    /// RootTabView.swift). Seri güncellemesi ve ilerleme senkronizasyonunu ayrı ayrı
    /// çağırmamak bilinçli: ikisi de aynı anda ayrı CloudKit save() tetiklerse aynı kayıt
    /// üzerinde yarışıp biri diğerini sessizce geçersiz kılabilirdi.
    var onStageCompleted: () -> Void = {}
    /// Canlar bitince (başarısız deneme) — seriyi korumak için, bkz. AppState.recordFailedAttempt.
    var onSessionFailed: () -> Void = {}
    @State private var path = NavigationPath()
    /// Seviye BİTTİĞİ an alınan "önce" durumu: kayıt hemen yapılır, yönlendirme (kupa/rozet ekranı kararı)
    /// oyuncu "Devam"a basınca bu anlık görüntüye göre verilir.
    @State private var stageSnapshot: StageSnapshot?
    private struct StageSnapshot { var tourDone: Bool; var continentDone: Bool; var level: GeoLevel }
    /// Ünvan ekranı araya girerse, o ekran kapanınca çalıştırılacak asıl yönlendirme (rozet → kupa).
    @State private var afterLevelUp: (() -> Void)?
    /// İlk seviye sonrası bir kez sorulan hatırlatma izni sayfası (bkz. ReminderPromptSheet).
    @AppStorage("geonaut.reminderPromptShown") private var reminderPromptShown = false
    @State private var showReminderPrompt = false

    private enum HomeCategory {
        case bayrakTahmin, haritaBilmece, anaDiller, dunyaYemekleri

        var tourCategory: TourCategory {
            switch self {
            case .bayrakTahmin: .flags
            case .haritaBilmece: .maps
            case .anaDiller: .languages
            case .dunyaYemekleri: .foods
            }
        }
    }
    @State private var selectedCategory: HomeCategory = .bayrakTahmin
    /// Kategori başına seçili tur (0 = Tur 1) — bkz. tourSelector. Kilitli bir tur seçilemez.
    @State private var selectedTours: [TourCategory: Int] = [:]
    /// Kilitli bir tura dokunulunca altında "önce Tur X'i bitir" ipucu gösterilir.
    @State private var lockedTourHint: Int?

    private enum Route: Hashable {
        case etapMap(continent: String, tour: Int)
        case quiz(continent: String, stageIndex: Int, tour: Int)
        case continentComplete(continent: String)
        case categoryComplete
        case tourComplete(category: TourCategory, tour: Int)
        case learnFlags
        case learnContinents
        case mapPuzzleEtapMap(tour: Int)
        case mapPuzzleQuiz(stageIndex: Int, tour: Int)
        case countryPuzzleEtapMap(tour: Int)
        case countryPuzzleQuiz(stageIndex: Int, tour: Int)
        case mapCategoryComplete
        case anaDillerEtapMap(continent: String, tour: Int)
        case anaDillerQuiz(continent: String, stageIndex: Int, tour: Int)
        case anaDillerContinentComplete(continent: String)
        case anaDillerCategoryComplete
        case learnLanguages
        case worldFoodsEtapMap(continent: String, tour: Int)
        case worldFoodsQuiz(continent: String, stageIndex: Int, tour: Int)
        case worldFoodsContinentComplete(continent: String)
        case worldFoodsCategoryComplete
        case learnFoods
        case levelUp(from: GeoLevel, to: GeoLevel)
        case mixedComplete(category: TourCategory)
        case mapSectionBadge(isCountries: Bool)
    }

    private func selectedTour(_ category: TourCategory) -> Int {
        let tour = selectedTours[category] ?? 0
        // Güvenlik ağı: seçili tur (ör. hesap değişince) kilitliyse Tur 1'e dön.
        return progress.isTourUnlocked(category, tour: tour) ? tour : 0
    }

    /// Bir seviye biter bitmez (tamamlanma ekranı açılırken) puanı ve ilerlemeyi kaydeder. Oyuncu "Devam"a
    /// basmadan uygulamayı kapatsa ya da geri dönse bile kayıt (ve seri) kaybolmaz.
    private func commitStage(_ category: TourCategory, tour: Int, progressKey: String, stageCount: Int, stageIndex: Int, earnedPoints: Int, seenCodes: [String]) {
        stageSnapshot = StageSnapshot(
            tourDone: progress.isCategoryCompleted(category, tour: tour),
            continentDone: progress.isContinentCompleted(progressKey, stageCount: stageCount),
            level: GeoLevel.level(forPoints: progress.lifetimePoints)
        )
        points += progress.pointsToAward(continent: progressKey, stageIndex: stageIndex, earnedPoints: earnedPoints)
        progress.markStageCompleted(continent: progressKey, stageIndex: stageIndex)
        progress.markCountriesSeen(seenCodes)
        onStageCompleted()
    }

    /// Etap sonrası sıra: ünvan yükseldiyse önce ÜNVAN ekranı, sonra asıl akış (rozet → kupa → ana sayfa).
    /// `levelBefore` etap kaydedilmeden önceki ünvandır (bkz. commitStage'in StageSnapshot'ı).
    private func finishStage(levelBefore: GeoLevel?, proceed: @escaping () -> Void) {
        let levelAfter = GeoLevel.level(forPoints: progress.lifetimePoints)
        if let levelBefore, levelAfter.rank > levelBefore.rank {
            afterLevelUp = proceed
            path.append(Route.levelUp(from: levelBefore, to: levelAfter))
        } else {
            proceed()
        }
    }

    /// Bir etap bitince: o tur (ya da kategori) YENİ tamamlandıysa kutlama ekranına, aksi
    /// hâlde köke (Ana Sayfa) döner. Kupa yalnızca 3 turun hepsi bitince (bkz. GameProgress).
    ///
    /// Kullanıcı kararı: bir seviye bitince Ana Sayfa'ya değil, o bölümün SEVİYE HARİTASINA dönülür
    /// (`stayInSection`) — oyuncu doğrudan sonraki seviyeye geçebilsin. Bölümün son seviyesi
    /// bittiyse (ya da kutlama gerekmiyorsa ve bölüm bittiyse) Ana Sayfa'ya dönülür.
    private func advanceAfterStage(_ category: TourCategory, tour: Int, wasTourDone: Bool, stayInSection: Bool = false) {
        guard !wasTourDone, progress.isCategoryCompleted(category, tour: tour) else {
            if stayInSection { path.removeLast() } else { path.removeLast(path.count) }
            return
        }
        if progress.isCategoryTrophyEarned(category) {
            switch category {
            case .flags: path.append(Route.categoryComplete)
            case .maps: path.append(Route.mapCategoryComplete)
            case .languages: path.append(Route.anaDillerCategoryComplete)
            case .foods: path.append(Route.worldFoodsCategoryComplete)
            }
        } else {
            path.append(Route.tourComplete(category: category, tour: tour))
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: GeoSpacing.xxxxl) {
                        // Figma "Ana Sayfa - Seri Uyarısı (Toast)" (node 508:11955).
                        if streakAtRisk {
                            GeoToast(message: "Serini kaybetmek üzeresin! Bugün oyna, seriyi koru. 🔥", tone: .warning)
                                .padding(.horizontal, GeoSpacing.xl)
                        }
                        if !cloudReachable && cloudAccountMissing {
                            GeoToast(message: "iCloud'a giriş yapılmamış — ilerlemen yalnızca bu cihazda saklanıyor. Ayarlar > [adın] > iCloud'dan giriş yaparsan yedeklenir ve diğer cihazlarında da görünür.", tone: .warning)
                                .padding(.horizontal, GeoSpacing.xl)
                        } else if !cloudReachable {
                            GeoToast(message: "İnternete ya da iCloud'a ulaşılamıyor — ilerlemen cihazında saklanıyor, bağlantı gelince senkronlanacak.", tone: .info)
                                .padding(.horizontal, GeoSpacing.xl)
                        }

                        topBar

                        switch selectedCategory {
                        case .bayrakTahmin: bayrakTahminContent
                        case .haritaBilmece: haritaBilmeceContent
                        case .anaDiller: anaDillerContent
                        case .dunyaYemekleri: dunyaYemekleriContent
                        }
                    }
                    .padding(.top, GeoSpacing.md)
                    .padding(.bottom, GeoSpacing.xxxl)
                }
                GeoNavBar(selection: $selectedTab)
            }
            .background { ZStack { GeoColor.bgCanvas; GeoStarfield() }.ignoresSafeArea() }
            .ignoresSafeArea(edges: .bottom)
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: selectedCategory) { _, _ in lockedTourHint = nil }
            .onChange(of: path.count) { _, count in
                // Tüm kutlama ekranları kapanıp Ana Sayfa'ya dönülünce, ilk tamamlanan seviyeden sonra bir kez sor.
                guard count == 0, !isGuest, !reminderPromptShown, !progress.completedStageKeysExport.isEmpty,
                      !UserDefaults.standard.bool(forKey: StreakReminderScheduler.enabledDefaultsKey) else { return }
                reminderPromptShown = true
                showReminderPrompt = true
            }
            .sheet(isPresented: $showReminderPrompt) {
                ReminderPromptSheet(
                    streakDays: streak,
                    onAccept: {
                        showReminderPrompt = false
                        Task {
                            if await StreakReminderScheduler.requestAuthorization() {
                                UserDefaults.standard.set(true, forKey: StreakReminderScheduler.enabledDefaultsKey)
                                StreakReminderScheduler.reschedule(streakDays: streak, enabled: true)
                            }
                        }
                    },
                    onDecline: { showReminderPrompt = false }
                )
            }
            #if DEBUG
            // Yalnızca geliştirme: kazanma ekranlarını hızlı görmek için, ör. uygulamayı
            // `-debugRoute tour|continent|trophy|maptrophy` argümanıyla başlat.
            .task {
                switch UserDefaults.standard.string(forKey: "debugRoute") {
                case "tour": path.append(Route.tourComplete(category: .flags, tour: 0))
                case "continent": path.append(Route.continentComplete(continent: "Avrupa"))
                case "trophy": path.append(Route.categoryComplete)
                case "maptrophy": path.append(Route.mapCategoryComplete)
                case "levelup": path.append(Route.levelUp(from: .caylak, to: .gezgin))
                case "levelupmax": path.append(Route.levelUp(from: .dunyaGezgini, to: .efsanevi))
                case "mapbadge": path.append(Route.mapSectionBadge(isCountries: false))
                case "mixed": path.append(Route.mixedComplete(category: .flags))
                default: break
                }
            }
            #endif
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .etapMap(let continent, let tour):
                    EtapMapView(
                        sectionName: continent,
                        categoryName: "Bayraklar",
                        tour: tour,
                        etapStates: progress.etapStates(continent: TourStructure.progressKey(continent, tour: tour), stageCount: FlagGuessStructure.stagesPerSection),
                        onSelectEtap: { stageIndex in
                            // Ürün kararı: giriş yapmadan yalnızca Avrupa'nın 1. etabı
                            // oynanabilir — gerisi "Apple ile giriş yap" ile açılır.
                            if isGuest && stageIndex > 0 {
                                onRequireSignIn()
                            } else {
                                path.append(Route.quiz(continent: continent, stageIndex: stageIndex, tour: tour))
                            }
                        },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .quiz(let continent, let stageIndex, let tour):
                    let progressKey = TourStructure.progressKey(continent, tour: tour)
                    let session = QuizSession(stageIndex: stageIndex, questions: Countries.makeQuestions(from: Countries.pool(forContinent: continent), isRecall: stageIndex >= 5, tour: tour, stageIndex: stageIndex))
                    QuizSessionView(
                        session: session,
                        points: $points,
                        onCompleted: { earnedPoints, seenCodes in
                            commitStage(.flags, tour: tour, progressKey: progressKey, stageCount: FlagGuessStructure.stagesPerSection, stageIndex: stageIndex, earnedPoints: earnedPoints, seenCodes: seenCodes)
                        },
                        onFinished: { _, _ in
                            let wasTourDone = stageSnapshot?.tourDone ?? progress.isCategoryCompleted(.flags, tour: tour)
                            let wasContinentDone = stageSnapshot?.continentDone ?? progress.isContinentCompleted(progressKey, stageCount: FlagGuessStructure.stagesPerSection)
                            let levelBefore = stageSnapshot?.level
                            stageSnapshot = nil

                            let continentJustFinished = !wasContinentDone && progress.isContinentCompleted(progressKey, stageCount: FlagGuessStructure.stagesPerSection)
                            // Kıta rozetleri Tur 1'e bağlı (kullanıcı kararı). Rozet kazanılınca tebrik ekranı
                            // HER ZAMAN gelir; Karışık'ın kupası yok ama rozeti var (bkz. BadgeCatalog).
                            finishStage(levelBefore: levelBefore) {
                                if tour == 0 && continentJustFinished {
                                    path.append(continent == "Karışık" ? Route.mixedComplete(category: .flags) : Route.continentComplete(continent: continent))
                                } else {
                                    advanceAfterStage(.flags, tour: tour, wasTourDone: wasTourDone, stayInSection: !progress.isContinentCompleted(progressKey, stageCount: FlagGuessStructure.stagesPerSection))
                                }
                            }
                        },
                        onExit: { path.removeLast() },
                        onFailed: onSessionFailed
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .continentComplete(let continent):
                    ContinentCompleteView(
                        continentName: continent,
                        onContinue: { advanceAfterStage(.flags, tour: 0, wasTourDone: false) }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .categoryComplete:
                    CategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .toolbar(.hidden, for: .navigationBar)

                case .tourComplete(let category, let tour):
                    TourCompleteView(
                        category: category, tour: tour,
                        onContinue: {
                            // Bitirilen turun yerine bir sonraki tura geçilmiş olarak Ana Sayfa'ya dön.
                            selectedTours[category] = min(tour + 1, TourStructure.lastTour)
                            path.removeLast(path.count)
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .learnFlags:
                    LearnFlagsView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)

                case .learnContinents:
                    LearnContinentsView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)

                case .mapPuzzleEtapMap(let tour):
                    EtapMapView(
                        sectionName: "Kıtalar",
                        categoryName: "Haritalar",
                        tour: tour,
                        etapStates: progress.etapStates(continent: TourStructure.progressKey(MapPuzzleStructure.progressKey, tour: tour), stageCount: MapPuzzleStructure.stageCount),
                        onSelectEtap: { stageIndex in path.append(Route.mapPuzzleQuiz(stageIndex: stageIndex, tour: tour)) },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .mapPuzzleQuiz(let stageIndex, let tour):
                    let progressKey = TourStructure.progressKey(MapPuzzleStructure.progressKey, tour: tour)
                    let mapSession = MapQuizSession(stageIndex: stageIndex, questions: MapQuizGenerator.makeQuestions(stageIndex: stageIndex, tour: tour))
                    MapQuizSessionView(
                        session: mapSession,
                        points: $points,
                        onCompleted: { earnedPoints, seenCodes in
                            commitStage(.maps, tour: tour, progressKey: progressKey, stageCount: MapPuzzleStructure.stageCount, stageIndex: stageIndex, earnedPoints: earnedPoints, seenCodes: seenCodes)
                        },
                        onFinished: { _, _ in
                            let wasTourDone = stageSnapshot?.tourDone ?? progress.isCategoryCompleted(.maps, tour: tour)
                            let wasContinentDone = stageSnapshot?.continentDone ?? progress.isContinentCompleted(progressKey, stageCount: MapPuzzleStructure.stageCount)
                            let levelBefore = stageSnapshot?.level
                            stageSnapshot = nil

                            // Haritalar'da kıta ekranı yok: Kıtalar / Ülkeler bölümü ilk kez bitince rozet tebriği (Tur 1).
                            let sectionJustFinished = tour == 0 && !wasContinentDone && progress.isContinentCompleted(progressKey, stageCount: MapPuzzleStructure.stageCount)
                            finishStage(levelBefore: levelBefore) {
                                if sectionJustFinished {
                                    path.append(Route.mapSectionBadge(isCountries: false))
                                } else {
                                    advanceAfterStage(.maps, tour: tour, wasTourDone: wasTourDone, stayInSection: !progress.isContinentCompleted(progressKey, stageCount: MapPuzzleStructure.stageCount))
                                }
                            }
                        },
                        onExit: { path.removeLast() },
                        onFailed: onSessionFailed
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .countryPuzzleEtapMap(let tour):
                    EtapMapView(
                        sectionName: "Ülkeler",
                        categoryName: "Haritalar",
                        tour: tour,
                        etapStates: progress.etapStates(continent: TourStructure.progressKey(CountryPuzzleStructure.progressKey, tour: tour), stageCount: CountryPuzzleStructure.stageCount),
                        onSelectEtap: { stageIndex in path.append(Route.countryPuzzleQuiz(stageIndex: stageIndex, tour: tour)) },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .countryPuzzleQuiz(let stageIndex, let tour):
                    let progressKey = TourStructure.progressKey(CountryPuzzleStructure.progressKey, tour: tour)
                    let countrySession = CountryQuizSession(stageIndex: stageIndex, questions: CountryQuizGenerator.makeQuestions(stageIndex: stageIndex, tour: tour))
                    CountryQuizSessionView(
                        session: countrySession,
                        points: $points,
                        onCompleted: { earnedPoints, seenCodes in
                            commitStage(.maps, tour: tour, progressKey: progressKey, stageCount: CountryPuzzleStructure.stageCount, stageIndex: stageIndex, earnedPoints: earnedPoints, seenCodes: seenCodes)
                        },
                        onFinished: { _, _ in
                            let wasTourDone = stageSnapshot?.tourDone ?? progress.isCategoryCompleted(.maps, tour: tour)
                            let wasContinentDone = stageSnapshot?.continentDone ?? progress.isContinentCompleted(progressKey, stageCount: CountryPuzzleStructure.stageCount)
                            let levelBefore = stageSnapshot?.level
                            stageSnapshot = nil

                            // Haritalar'da kıta ekranı yok: Kıtalar / Ülkeler bölümü ilk kez bitince rozet tebriği (Tur 1).
                            let sectionJustFinished = tour == 0 && !wasContinentDone && progress.isContinentCompleted(progressKey, stageCount: CountryPuzzleStructure.stageCount)
                            finishStage(levelBefore: levelBefore) {
                                if sectionJustFinished {
                                    path.append(Route.mapSectionBadge(isCountries: true))
                                } else {
                                    advanceAfterStage(.maps, tour: tour, wasTourDone: wasTourDone, stayInSection: !progress.isContinentCompleted(progressKey, stageCount: CountryPuzzleStructure.stageCount))
                                }
                            }
                        },
                        onExit: { path.removeLast() },
                        onFailed: onSessionFailed
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .mapCategoryComplete:
                    MapCategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .toolbar(.hidden, for: .navigationBar)

                case .anaDillerEtapMap(let continent, let tour):
                    EtapMapView(
                        sectionName: continent,
                        categoryName: "Diller",
                        tour: tour,
                        etapStates: progress.etapStates(
                            continent: TourStructure.progressKey(MainLanguageStructure.progressKey(for: continent), tour: tour),
                            stageCount: MainLanguageStructure.stagesPerSection
                        ),
                        onSelectEtap: { stageIndex in path.append(Route.anaDillerQuiz(continent: continent, stageIndex: stageIndex, tour: tour)) },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .anaDillerQuiz(let continent, let stageIndex, let tour):
                    let progressKey = TourStructure.progressKey(MainLanguageStructure.progressKey(for: continent), tour: tour)
                    let languageSession = LanguageQuizSession(
                        stageIndex: stageIndex,
                        questions: Languages.makeQuestions(forContinent: continent, stageIndex: stageIndex, tour: tour)
                    )
                    LanguageQuizSessionView(
                        session: languageSession,
                        points: $points,
                        onCompleted: { earnedPoints, seenCodes in
                            commitStage(.languages, tour: tour, progressKey: progressKey, stageCount: MainLanguageStructure.stagesPerSection, stageIndex: stageIndex, earnedPoints: earnedPoints, seenCodes: seenCodes)
                        },
                        onFinished: { _, _ in
                            let wasTourDone = stageSnapshot?.tourDone ?? progress.isCategoryCompleted(.languages, tour: tour)
                            let wasContinentDone = stageSnapshot?.continentDone ?? progress.isContinentCompleted(progressKey, stageCount: MainLanguageStructure.stagesPerSection)
                            let levelBefore = stageSnapshot?.level
                            stageSnapshot = nil

                            let continentJustFinished = !wasContinentDone && progress.isContinentCompleted(progressKey, stageCount: MainLanguageStructure.stagesPerSection)
                            finishStage(levelBefore: levelBefore) {
                                if tour == 0 && continentJustFinished {
                                    path.append(continent == "Karışık" ? Route.mixedComplete(category: .languages) : Route.anaDillerContinentComplete(continent: continent))
                                } else {
                                    // Her etap sonunda köke (Ana Sayfa) dönülür, ayrı bir Giriş'e değil.
                                    advanceAfterStage(.languages, tour: tour, wasTourDone: wasTourDone, stayInSection: !progress.isContinentCompleted(progressKey, stageCount: MainLanguageStructure.stagesPerSection))
                                }
                            }
                        },
                        onExit: { path.removeLast() },
                        onFailed: onSessionFailed
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .anaDillerContinentComplete(let continent):
                    ContinentCompleteView(
                        continentName: continent,
                        achievementText: String(localized: "\(L(continent))'daki ülkelerin ana dillerini öğrendin. \(L(continent)) Kupasını kazandın!"),
                        onContinue: { advanceAfterStage(.languages, tour: 0, wasTourDone: false) }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .anaDillerCategoryComplete:
                    AnaDillerCategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .toolbar(.hidden, for: .navigationBar)

                case .learnLanguages:
                    LearnLanguagesView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)

                case .worldFoodsEtapMap(let continent, let tour):
                    EtapMapView(
                        sectionName: continent,
                        categoryName: "Lezzetler",
                        tour: tour,
                        etapStates: progress.etapStates(
                            continent: TourStructure.progressKey(WorldFoodStructure.progressKey(for: continent), tour: tour),
                            stageCount: WorldFoodStructure.stagesPerSection
                        ),
                        onSelectEtap: { stageIndex in path.append(Route.worldFoodsQuiz(continent: continent, stageIndex: stageIndex, tour: tour)) },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .worldFoodsQuiz(let continent, let stageIndex, let tour):
                    let progressKey = TourStructure.progressKey(WorldFoodStructure.progressKey(for: continent), tour: tour)
                    let foodSession = FoodQuizSession(
                        stageIndex: stageIndex,
                        questions: WorldFoods.makeQuestions(forSection: continent, stageIndex: stageIndex, tour: tour)
                    )
                    FoodQuizSessionView(
                        session: foodSession,
                        points: $points,
                        onCompleted: { earnedPoints, seenCodes in
                            commitStage(.foods, tour: tour, progressKey: progressKey, stageCount: WorldFoodStructure.stagesPerSection, stageIndex: stageIndex, earnedPoints: earnedPoints, seenCodes: seenCodes)
                        },
                        onFinished: { _, _ in
                            let wasTourDone = stageSnapshot?.tourDone ?? progress.isCategoryCompleted(.foods, tour: tour)
                            let wasContinentDone = stageSnapshot?.continentDone ?? progress.isContinentCompleted(progressKey, stageCount: WorldFoodStructure.stagesPerSection)
                            let levelBefore = stageSnapshot?.level
                            stageSnapshot = nil

                            let continentJustFinished = !wasContinentDone && progress.isContinentCompleted(progressKey, stageCount: WorldFoodStructure.stagesPerSection)
                            finishStage(levelBefore: levelBefore) {
                                if tour == 0 && continentJustFinished {
                                    path.append(continent == "Karışık" ? Route.mixedComplete(category: .foods) : Route.worldFoodsContinentComplete(continent: continent))
                                } else {
                                    advanceAfterStage(.foods, tour: tour, wasTourDone: wasTourDone, stayInSection: !progress.isContinentCompleted(progressKey, stageCount: WorldFoodStructure.stagesPerSection))
                                }
                            }
                        },
                        onExit: { path.removeLast() },
                        onFailed: onSessionFailed
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .worldFoodsContinentComplete(let continent):
                    ContinentCompleteView(
                        continentName: continent,
                        achievementText: worldFoodsAchievementText(for: continent),
                        onContinue: { advanceAfterStage(.foods, tour: 0, wasTourDone: false) }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .worldFoodsCategoryComplete:
                    WorldFoodsCategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .toolbar(.hidden, for: .navigationBar)

                case .learnFoods:
                    LearnFoodsView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)

                case .levelUp(let from, let to):
                    LevelUpView(
                        from: from,
                        to: to,
                        onContinue: {
                            // Ünvan ekranını kapat, sonra bekleyen asıl akışı (rozet → kupa → ana sayfa) çalıştır.
                            path.removeLast()
                            let next = afterLevelUp
                            afterLevelUp = nil
                            next?()
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .mixedComplete(let category):
                    BadgeEarnedView(
                        title: "Karışık",
                        icon: "🔀",
                        accentColor: GeoColor.textSecondary,
                        headline: "Karışık Bölüm Tamamlandı!",
                        message: mixedBadgeMessage(for: category),
                        onContinue: { advanceAfterStage(category, tour: 0, wasTourDone: false) }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .mapSectionBadge(let isCountries):
                    BadgeEarnedView(
                        title: isCountries ? "Ülkeler Rozeti" : "Kıtalar Rozeti",
                        icon: isCountries ? "📍" : "🌍",
                        accentColor: isCountries ? GeoColor.accentInfoStrong : GeoColor.accentInfo,
                        headline: "Yeni rozet kazandın!",
                        message: isCountries
                            ? "Haritalar'da Ülkeler bölümünün 8 seviyesini tamamladın."
                            : "Haritalar'da Kıtalar bölümünün 8 seviyesini tamamladın.",
                        onContinue: { advanceAfterStage(.maps, tour: 0, wasTourDone: false) }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }

    /// Kullanıcı "Avatarını Oluştur"u en az bir kez kaydettiyse (bkz. hasCustomAvatar)
    /// gerçek renk/karakteriyle küçültülmüş bir GeoAvatar — ProfileView.avatarSection'daki
    /// ile AYNI bileşen, burada yalnızca 38pt'e ölçeklenmiş hali. Hiç avatar
    /// oluşturmadıysa eskiden beri kullanılan sabit mor + profil ikonu daire korunur.
    @ViewBuilder
    private var headerAvatar: some View {
        if hasCustomAvatar {
            GeoAvatar(backgroundColor: Color(hex: avatarColorHex), character: avatarCharacter)
                .scaleEffect(38 / 104)
                .frame(width: 38, height: 38)
        } else {
            Circle()
                .fill(GeoColor.accentTertiary)
                .frame(width: 38, height: 38)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
        }
    }

    /// Yalnızca üst istatistikler + kategori kartları — kategoriye özgü başlık/içerik
    /// artık ayrı ekranlarda değil, aşağıdaki `xContent` computed property'lerinde
    /// (bkz. yukarıdaki mimari not). Kullanıcı kararı: iPad'de de yapı birebir aynı
    /// kalsın, yalnızca genişliğe göre responsive olsun (bkz. GeoLayout.columnMaxWidth
    /// ile GeonautApp.swift'teki ortalanmış sütun) — ayrı bir iPad yerleşimi YOK. Tek
    /// istisna: kategori kartları iPad'in geniş sütununda sola yapışık kalmasın diye
    /// ortalanıyor (bkz. categoryRow) — iPhone'da kaydırma davranışı aynı kalıyor.
    private var topBar: some View {
        VStack(spacing: GeoSpacing.md) {
            HStack {
                HStack(spacing: GeoSpacing.sm) {
                    GeoStatPill(icon: .streak, value: "\(streak)")
                    GeoStatPill(icon: .points, value: "\(points)")
                }
                Spacer()
                // Figma'daki referans görsele göre bu, Profil'e kısayol veren bir
                // avatar simgesi (bildirim zili değil).
                Button { selectedTab = .profile } label: {
                    headerAvatar
                        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Profil")
            }
            .padding(.horizontal, GeoSpacing.xl)

            categoryRow
        }
    }

    /// categoryButtons'ı içeren satır — genişliğe göre responsive: kartların toplam
    /// genişliği ekrana (iPad'in geniş sütununa) sığıyorsa kartlar genişliği eşit
    /// paylaşarak sağa-sola dolduruyor (kullanıcı kararı: "kategori cardları sağa
    /// sola fill olsun"), sığmıyorsa (iPhone) eskisi gibi sabit genişlikte, sola
    /// yaslı, kaydırmalı bir satır.
    private var categoryRow: some View {
        GeometryReader { geo in
            let cardsWidth = CGFloat(4) * 106 + CGFloat(3) * GeoSpacing.md
            if cardsWidth <= geo.size.width {
                HStack(alignment: .top, spacing: GeoSpacing.md) {
                    categoryButtons(fillWidth: true)
                }
                .padding(.horizontal, GeoSpacing.xl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: GeoSpacing.md) {
                        categoryButtons(fillWidth: false)
                    }
                    .padding(.horizontal, GeoSpacing.xl)
                }
                .scrollClipDisabled()
            }
        }
        .frame(height: 112)
    }

    /// Ana Sayfa kategori kartları (Bayraklar/Haritalar/Diller/Lezzetler) — categoryRow
    /// içinde kullanılıyor; iPad'de genişliği dolduran (fillWidth), iPhone'da sabit
    /// genişlikte kaydırmalı satırda aynı içerik.
    @ViewBuilder
    private func categoryButtons(fillWidth: Bool) -> some View {
                    Button { selectedCategory = .bayrakTahmin } label: {
                        GeoCategoryCard(
                            title: "Bayraklar", icon: .system("flag.fill"), state: .unlocked,
                            iconCircleColor: GeoColor.accentPrimary, iconTintColor: .white,
                            isCurrentCategory: selectedCategory == .bayrakTahmin,
                            fillWidth: fillWidth
                        )
                    }
                    .buttonStyle(.kasifCategoryCard)

                    let mapUnlocked = progress.isFlagGuessCategoryCompleted()
                    Button {
                        if !mapUnlocked {
                            return
                        } else if isGuest {
                            onRequireSignIn()
                        } else {
                            selectedCategory = .haritaBilmece
                        }
                    } label: {
                        GeoCategoryCard(
                            title: "Haritalar", icon: .system("map.fill"),
                            state: mapUnlocked ? .unlocked : .locked,
                            iconCircleColor: GeoColor.accentInfo, iconTintColor: GeoColor.accentInfoStrong,
                            isCurrentCategory: selectedCategory == .haritaBilmece,
                            fillWidth: fillWidth
                        )
                    }
                    .buttonStyle(.kasifCategoryCard)

                    let languagesUnlocked = progress.isMapPuzzleCategoryCompleted()
                    Button {
                        if !languagesUnlocked {
                            return
                        } else if isGuest {
                            onRequireSignIn()
                        } else {
                            selectedCategory = .anaDiller
                        }
                    } label: {
                        GeoCategoryCard(
                            title: "Diller", icon: .system("character.book.closed.fill"),
                            state: languagesUnlocked ? .unlocked : .locked,
                            iconCircleColor: GeoColor.accentTertiary, iconTintColor: GeoColor.accentTertiaryStrong,
                            isCurrentCategory: selectedCategory == .anaDiller,
                            fillWidth: fillWidth
                        )
                    }
                    .buttonStyle(.kasifCategoryCard)

                    let foodsUnlocked = progress.isMainLanguageCategoryCompleted()
                    Button {
                        if !foodsUnlocked {
                            return
                        } else if isGuest {
                            onRequireSignIn()
                        } else {
                            selectedCategory = .dunyaYemekleri
                        }
                    } label: {
                        GeoCategoryCard(
                            title: "Lezzetler", icon: .system("fork.knife"),
                            state: foodsUnlocked ? .unlocked : .locked,
                            iconCircleColor: GeoColor.accentSuccess, iconTintColor: GeoColor.accentSuccessStrong,
                            isCurrentCategory: selectedCategory == .dunyaYemekleri,
                            fillWidth: fillWidth
                        )
                    }
                    .buttonStyle(.kasifCategoryCard)
    }

    /// Kategori başlığının altındaki Tur 1 / Tur 2 / Tur 3 seçici — kullanıcı kararı: modern,
    /// yumuşak bir "Tur 1 ··· Tur 2 ··· Tur 3" şeridi (kapsül/segment yok). Seçili tur yumuşak
    /// bir mercan zemin alır, biten turda onay işareti + yeşil, kilitli turda kilit + soluk renk;
    /// turlar arasındaki noktalar önceki tur bitince yeşile döner.
    private func tourSelector(for category: TourCategory) -> some View {
        let selected = selectedTour(category)
        return VStack(alignment: .leading, spacing: GeoSpacing.xs) {
            HStack(spacing: 6) {
                ForEach(0..<TourStructure.count, id: \.self) { tour in
                    tourStep(for: category, tour: tour, isSelected: selected == tour)
                    if tour < TourStructure.count - 1 {
                        tourDots(isDone: progress.isCategoryCompleted(category, tour: tour))
                    }
                }
            }

            if let hint = lockedTourHint {
                Text("Tur \(hint + 1)'in kilidini açmak için önce Tur \(hint)'i bitir.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
                    .padding(.horizontal, GeoSpacing.sm)
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
    }

    private func tourStep(for category: TourCategory, tour: Int, isSelected: Bool) -> some View {
        let unlocked = progress.isTourUnlocked(category, tour: tour) && !(isGuest && tour > 0)
        let done = progress.isCategoryCompleted(category, tour: tour)
        let textColor: Color = !unlocked ? GeoColor.textMuted
            : isSelected ? GeoColor.accentPrimary
            : done ? GeoColor.accentSuccessStrong
            : GeoColor.textSecondary
        return Button {
            if unlocked {
                selectedTours[category] = tour
                lockedTourHint = nil
            } else if isGuest {
                onRequireSignIn()
            } else {
                lockedTourHint = tour
            }
        } label: {
            HStack(spacing: 4) {
                if !unlocked {
                    Image(systemName: "lock.fill").font(.system(size: 10))
                } else if done {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 12))
                }
                Text("Tur \(tour + 1)")
                    .lineLimit(1)
            }
            .fixedSize()
            .font(.custom(GeoFontName.balooBold, size: 15))
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? GeoColor.accentPrimary.opacity(0.14) : .clear, in: Capsule())
            .animation(.easeOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Tur \(tour + 1)"))
        .accessibilityValue(!unlocked ? Text("Kilitli") : (done ? Text("Tamamlandı") : Text("")))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// İki tur arasındaki üç nokta — soldaki tur bitince yeşile döner.
    private func tourDots(isDone: Bool) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(isDone ? GeoColor.accentSuccess : GeoColor.textMuted.opacity(0.35))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var bayrakTahminContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 2) {
                Text("Dünya Turu")
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Kıtaları keşfet, bayrakları öğren!")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GeoSpacing.xl)

            tourSelector(for: .flags)

            // Figma'daki "yolun başındaki bilgi durağı" (node 297:8933) — mor daire +
            // bayrak ikonu, Bayrakları Öğren'i açar. Bu mor (#9966E6) bir Figma
            // değişkenine bağlı değil, bu node'a özel sabit bir renk —
            // GeoColor.accentTertiaryStrong (#9783BE) ile karıştırılmamalı.
            GeometryReader { geo in
                Button { path.append(Route.learnFlags) } label: {
                    VStack(spacing: GeoSpacing.sm) {
                        Circle()
                            .fill(Color(hex: 0x9966E6))
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        Text("Öğren")
                            .font(.custom(GeoFontName.balooBold, size: 14))
                            .foregroundStyle(Color(hex: 0x9966E6))
                    }
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * 0.5, y: geo.size.height / 2)
            }
            .frame(height: 84)
            .padding(.horizontal, GeoSpacing.xxxxl)

            ContinentPathView(nodes: ContinentPathNode.flagGuessPath(progress: progress, tour: selectedTour(.flags))) { node in
                guard node.state != .locked else { return }
                if isGuest && node.name != "Avrupa" {
                    onRequireSignIn()
                } else {
                    path.append(Route.etapMap(continent: node.name, tour: selectedTour(.flags)))
                }
            }
            .padding(.horizontal, GeoSpacing.xxxxl)
        }
    }

    private var anaDillerContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 2) {
                Text("Diller")
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Kıtaları keşfet, ana dilleri öğren!")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GeoSpacing.xl)

            tourSelector(for: .languages)

            GeometryReader { geo in
                Button { path.append(Route.learnLanguages) } label: {
                    VStack(spacing: GeoSpacing.sm) {
                        Circle()
                            .fill(Color(hex: 0x9966E6))
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "character.book.closed.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        Text("Öğren")
                            .font(.custom(GeoFontName.balooBold, size: 14))
                            .foregroundStyle(Color(hex: 0x9966E6))
                    }
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * 0.5, y: geo.size.height / 2)
            }
            .frame(height: 84)
            .padding(.horizontal, GeoSpacing.xxxxl)

            ContinentPathView(nodes: ContinentPathNode.mainLanguagePath(progress: progress, tour: selectedTour(.languages))) { node in
                guard node.state != .locked else { return }
                path.append(Route.anaDillerEtapMap(continent: node.name, tour: selectedTour(.languages)))
            }
            .padding(.horizontal, GeoSpacing.xxxxl)
        }
    }

    private var dunyaYemekleriContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lezzetler")
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Yemekleri, içecekleri ve tatlıları öğren!")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GeoSpacing.xl)

            tourSelector(for: .foods)

            GeometryReader { geo in
                Button { path.append(Route.learnFoods) } label: {
                    VStack(spacing: GeoSpacing.sm) {
                        Circle()
                            .fill(GeoColor.accentSuccessStrong)
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        Text("Öğren")
                            .font(.custom(GeoFontName.balooBold, size: 14))
                            .foregroundStyle(GeoColor.accentSuccessStrong)
                    }
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * 0.5, y: geo.size.height / 2)
            }
            .frame(height: 84)
            .padding(.horizontal, GeoSpacing.xxxxl)

            ContinentPathView(nodes: ContinentPathNode.worldFoodsSectionsPath(progress: progress, tour: selectedTour(.foods))) { node in
                guard node.state != .locked else { return }
                path.append(Route.worldFoodsEtapMap(continent: node.name, tour: selectedTour(.foods)))
            }
            .padding(.horizontal, GeoSpacing.xxxxl)
        }
    }

    /// Diğer 3 kategoriyle birebir aynı iskelet (başlık + Öğren durağı + kıta yolu) —
    /// kullanıcı kararı: eskiden burada Kıtalar/Ülkeler sekmeleri + galeri/liste vardı,
    /// o içerik artık Öğren hedefine taşındı (bkz. LearnContinentsView). Altta yatan
    /// MapPuzzleStructure gerçek 7 kıta değil TEK bir 8 etaplık düz havuz olduğu için
    /// (bkz. ContinentPathNode.mapPuzzlePath'teki not) düğüme dokunmak, Bayrak Tahmin'deki
    /// gibi ayrı bir Etap Haritası'na değil, doğrudan o sıradaki etabın sınavına açılıyor.
    private var haritaBilmeceContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 2) {
                Text("Haritalar")
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                Text("7 kıtayı keşfet, ülkeleri haritada bul")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GeoSpacing.xl)

            tourSelector(for: .maps)

            GeometryReader { geo in
                Button { path.append(Route.learnContinents) } label: {
                    VStack(spacing: GeoSpacing.sm) {
                        Circle()
                            .fill(GeoColor.accentInfoStrong)
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        Text("Öğren")
                            .font(.custom(GeoFontName.balooBold, size: 14))
                            .foregroundStyle(GeoColor.accentInfoStrong)
                    }
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * 0.5, y: geo.size.height / 2)
            }
            .frame(height: 84)
            .padding(.horizontal, GeoSpacing.xxxxl)

            ContinentPathView(nodes: ContinentPathNode.mapPuzzleTracksPath(progress: progress, tour: selectedTour(.maps))) { node in
                guard node.state != .locked else { return }
                if node.name == "Kıtalar" {
                    path.append(Route.mapPuzzleEtapMap(tour: selectedTour(.maps)))
                } else {
                    path.append(Route.countryPuzzleEtapMap(tour: selectedTour(.maps)))
                }
            }
            .padding(.horizontal, GeoSpacing.xxxxl)
        }
    }

    /// Dünya Yemekleri artık kıta değil TÜR bazlı ilerlediği için (bkz.
    /// WorldFoodStructure.sections) "X'deki ülkelerin..." kalıbı yerine bölüm adına
    /// göre doğal bir kutlama metni üretir.
    private func mixedBadgeMessage(for category: TourCategory) -> LocalizedStringKey {
        switch category {
        case .flags: "Bayraklar'da Karışık bölümünün 8 seviyesini tamamladın."
        case .languages: "Diller'de Karışık bölümünün 8 seviyesini tamamladın."
        case .foods: "Lezzetler'de Karışık bölümünün 8 seviyesini tamamladın."
        case .maps: "Haritalar'da Karışık bölümünün 8 seviyesini tamamladın."
        }
    }

    private func worldFoodsAchievementText(for section: String) -> String {
        switch section {
        case "Yemekler": return String(localized: "Dünyanın dört bir yanından meşhur yemekleri öğrendin. Yemekler Kupasını kazandın!")
        case "İçecekler": return String(localized: "Dünyanın dört bir yanından meşhur içecekleri öğrendin. İçecekler Kupasını kazandın!")
        case "Tatlılar": return String(localized: "Dünyanın dört bir yanından meşhur tatlıları öğrendin. Tatlılar Kupasını kazandın!")
        default: return String(localized: "\(L(section)) bölümünü tamamladın!")
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home), points: .constant(340), streak: 12, progress: GameProgress())
}
