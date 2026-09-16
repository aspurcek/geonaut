import SwiftUI

/// Figma "Ana Sayfa - Kıta Yolu" (node 271:5428) — Bayrak Tahmin kategorisinin ana
/// ekranı: üst istatistikler, kategori seçim kartları, kıta yolu.
struct HomeView: View {
    @Binding var selectedTab: KasifTab
    /// RootTabView'de tutulur (bkz. RootTabView.swift'teki mimari notu) — sekme
    /// değiştirince sıfırlanmaması için burada @State değil @Binding/referans.
    @Binding var points: Int
    @State var streak: Int
    /// Dün oynanmış, bugün henüz oynanmamış — bkz. Streak.swift/StreakStatus.atRisk.
    var streakAtRisk: Bool = false
    /// RootTabView'in sahip olduğu paylaşılan örnek — HomeView kendi kopyasını
    /// oluşturmuyor (bkz. RootTabView.swift'teki mimari notu).
    var progress: GameProgress
    var isGuest: Bool = false
    var onRequireSignIn: () -> Void = {}
    /// Bir etap bitince çağrılır — AppState.recordStageCompletion'a kadar iletilir (bkz.
    /// RootTabView.swift). Seri güncellemesi ve ilerleme senkronizasyonunu ayrı ayrı
    /// çağırmamak bilinçli: ikisi de aynı anda ayrı CloudKit save() tetiklerse aynı kayıt
    /// üzerinde yarışıp biri diğerini sessizce geçersiz kılabilirdi.
    var onStageCompleted: () -> Void = {}
    @State private var path = NavigationPath()

    private enum Route: Hashable {
        case etapMap(continent: String)
        case quiz(continent: String, stageIndex: Int)
        case continentComplete(continent: String)
        case categoryComplete
        case learnFlags
        case mapPuzzleEntry
        case mapPuzzleEtapMap
        case mapPuzzleQuiz(stageIndex: Int)
        case countryPuzzleEtapMap
        case countryPuzzleQuiz(stageIndex: Int)
        case mapCategoryComplete
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: KasifSpacing.xxxxl) {
                        // Figma "Ana Sayfa - Seri Uyarısı (Toast)" (node 508:11955).
                        if streakAtRisk {
                            KasifToast(message: "Serini kaybetmek üzeresin! Bugün oyna, seriyi koru. 🔥", tone: .warning)
                                .padding(.horizontal, KasifSpacing.xl)
                        }

                        header

                        // Figma'daki "yolun başındaki bilgi durağı" (node 297:8933) —
                        // mor daire + bayrak ikonu, Bayrakları Öğren'i açar. Bu mor
                        // (#9966E6) bir Figma değişkenine bağlı değil, bu node'a özel
                        // sabit bir renk — KasifColor.accentTertiaryStrong (#9783BE)
                        // ile karıştırılmamalı.
                        GeometryReader { geo in
                            Button { path.append(Route.learnFlags) } label: {
                                VStack(spacing: KasifSpacing.sm) {
                                    Circle()
                                        .fill(Color(hex: 0x9966E6))
                                        .frame(width: 56, height: 56)
                                        .overlay {
                                            Image(systemName: "flag.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(.white)
                                        }
                                    Text("Öğren")
                                        .font(.custom(KasifFontName.balooBold, size: 14))
                                        .foregroundStyle(Color(hex: 0x9966E6))
                                }
                            }
                            .buttonStyle(.plain)
                            .position(x: geo.size.width * 0.62, y: geo.size.height / 2)
                        }
                        .frame(height: 84)
                        .padding(.horizontal, KasifSpacing.xxxxl)

                        ContinentPathView(nodes: ContinentPathNode.flagGuessPath(progress: progress)) { node in
                            guard node.state != .locked else { return }
                            if isGuest && node.name != "Avrupa" {
                                onRequireSignIn()
                            } else {
                                path.append(Route.etapMap(continent: node.name))
                            }
                        }
                        .padding(.horizontal, KasifSpacing.xxxxl)
                    }
                    .padding(.top, KasifSpacing.md)
                    .padding(.bottom, KasifSpacing.xxxl)
                }
                KasifNavBar(selection: $selectedTab)
            }
            .background(KasifColor.bgCanvas)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .etapMap(let continent):
                    EtapMapView(
                        sectionName: continent,
                        categoryName: "Bayrak Tahmin",
                        etapStates: progress.etapStates(continent: continent, stageCount: FlagGuessStructure.stagesPerSection),
                        onSelectEtap: { stageIndex in
                            // Ürün kararı: giriş yapmadan yalnızca Avrupa'nın 1. etabı
                            // oynanabilir — gerisi "Apple ile giriş yap" ile açılır.
                            if isGuest && stageIndex > 0 {
                                onRequireSignIn()
                            } else {
                                path.append(Route.quiz(continent: continent, stageIndex: stageIndex))
                            }
                        },
                        onBack: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .quiz(let continent, let stageIndex):
                    let session = QuizSession(stageIndex: stageIndex, questions: Countries.makeQuestions(from: Countries.pool(forContinent: continent), isRecall: stageIndex >= 5))
                    QuizSessionView(
                        session: session,
                        points: $points,
                        onFinished: { earnedPoints in
                            points += progress.pointsToAward(continent: continent, stageIndex: stageIndex, earnedPoints: earnedPoints)
                            progress.markStageCompleted(continent: continent, stageIndex: stageIndex)
                            progress.markCountriesSeen(session.questions.map(\.countryCode))
                            onStageCompleted()

                            let continentJustFinished = progress.isContinentCompleted(continent, stageCount: FlagGuessStructure.stagesPerSection)
                            // Karışık'ın kendi kupası/tamamlama ekranı yok (bkz. Bayrak
                            // Tahmin Kural Kitabı böl. 07) — direkt kategori kontrolüne geçilir.
                            if continentJustFinished && continent != "Karışık" {
                                path.append(Route.continentComplete(continent: continent))
                            } else if progress.isFlagGuessCategoryCompleted() {
                                path.append(Route.categoryComplete)
                            } else {
                                path.removeLast(path.count)
                            }
                        },
                        onExit: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .continentComplete(let continent):
                    ContinentCompleteView(
                        continentName: continent,
                        continentIcon: ContinentPathNode.icon(for: continent),
                        onContinue: {
                            if progress.isFlagGuessCategoryCompleted() {
                                path.append(Route.categoryComplete)
                            } else {
                                path.removeLast(path.count)
                            }
                        }
                    )
                    .navigationBarHidden(true)

                case .categoryComplete:
                    CategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .navigationBarHidden(true)

                case .learnFlags:
                    LearnFlagsView(onBack: { path.removeLast() })
                        .navigationBarHidden(true)

                case .mapPuzzleEntry:
                    MapPuzzleEntryView(
                        onBack: { path.removeLast() },
                        onSelectContinentsStage: { path.append(Route.mapPuzzleEtapMap) },
                        onSelectCountriesStage: { path.append(Route.countryPuzzleEtapMap) }
                    )
                    .navigationBarHidden(true)

                case .mapPuzzleEtapMap:
                    EtapMapView(
                        sectionName: "Kıtalar",
                        categoryName: "Harita Bilmece",
                        etapStates: progress.etapStates(continent: MapPuzzleStructure.progressKey, stageCount: MapPuzzleStructure.stageCount),
                        onSelectEtap: { stageIndex in path.append(Route.mapPuzzleQuiz(stageIndex: stageIndex)) },
                        onBack: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .mapPuzzleQuiz(let stageIndex):
                    let mapSession = MapQuizSession(stageIndex: stageIndex, questions: MapQuizGenerator.makeQuestions(stageIndex: stageIndex))
                    MapQuizSessionView(
                        session: mapSession,
                        points: $points,
                        onFinished: { earnedPoints in
                            points += progress.pointsToAward(continent: MapPuzzleStructure.progressKey, stageIndex: stageIndex, earnedPoints: earnedPoints)
                            progress.markStageCompleted(continent: MapPuzzleStructure.progressKey, stageIndex: stageIndex)
                            progress.markCountriesSeen(mapSession.questions.map { $0.country.code })
                            onStageCompleted()
                            if progress.isMapPuzzleCategoryCompleted() {
                                path.append(Route.mapCategoryComplete)
                            } else {
                                path.removeLast(path.count)
                            }
                        },
                        onExit: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .countryPuzzleEtapMap:
                    EtapMapView(
                        sectionName: "Ülkeler",
                        categoryName: "Harita Bilmece",
                        etapStates: progress.etapStates(continent: CountryPuzzleStructure.progressKey, stageCount: CountryPuzzleStructure.stageCount),
                        onSelectEtap: { stageIndex in path.append(Route.countryPuzzleQuiz(stageIndex: stageIndex)) },
                        onBack: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .countryPuzzleQuiz(let stageIndex):
                    let countrySession = CountryQuizSession(stageIndex: stageIndex, questions: CountryQuizGenerator.makeQuestions(stageIndex: stageIndex))
                    CountryQuizSessionView(
                        session: countrySession,
                        points: $points,
                        onFinished: { earnedPoints in
                            points += progress.pointsToAward(continent: CountryPuzzleStructure.progressKey, stageIndex: stageIndex, earnedPoints: earnedPoints)
                            progress.markStageCompleted(continent: CountryPuzzleStructure.progressKey, stageIndex: stageIndex)
                            progress.markCountriesSeen(countrySession.questions.map { $0.country.code })
                            onStageCompleted()
                            if progress.isMapPuzzleCategoryCompleted() {
                                path.append(Route.mapCategoryComplete)
                            } else {
                                path.removeLast(path.count)
                            }
                        },
                        onExit: { path.removeLast() }
                    )
                    .navigationBarHidden(true)

                case .mapCategoryComplete:
                    MapCategoryCompleteView(onContinue: { path.removeLast(path.count) })
                        .navigationBarHidden(true)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: KasifSpacing.md) {
            HStack {
                HStack(spacing: KasifSpacing.sm) {
                    KasifStatPill(icon: .streak, value: "\(streak)")
                    KasifStatPill(icon: .points, value: "\(points)")
                }
                Spacer()
                // Figma'daki referans görsele göre bu, Profil'e kısayol veren bir
                // avatar simgesi (bildirim zili değil).
                Button { selectedTab = .profile } label: {
                    Circle()
                        .fill(KasifColor.accentTertiary)
                        .frame(width: 38, height: 38)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, KasifSpacing.xl)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dünya Turu")
                    .font(KasifTypography.headingL)
                    .foregroundStyle(KasifColor.textPrimary)
                Text("Kıtaları keşfet, bayrakları öğren!")
                    .font(KasifTypography.bodyBold)
                    .foregroundStyle(KasifColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, KasifSpacing.xl)

            HStack(spacing: KasifSpacing.md) {
                // Ana Sayfa her zaman Bayrak Tahmin'in ekranı olduğu için kartı hep
                // "aktif kategori" görünümünde (coral kenarlık+parlama) — bkz. node
                // 271:5448. Harita Bilmece kendi akışında (344:55301) aynı görünümü
                // taşır ama burada değil, çünkü Ana Sayfa onun ekranı değil.
                Button {} label: {
                    KasifCategoryCard(
                        title: "Bayrak Tahmin", icon: .emoji("🇹🇷"), state: .unlocked,
                        iconCircleColor: KasifColor.accentPrimary,
                        isCurrentCategory: true
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
                        path.append(Route.mapPuzzleEntry)
                    }
                } label: {
                    KasifCategoryCard(
                        title: "Harita Bilmece", icon: .system("map.fill"),
                        state: mapUnlocked ? .unlocked : .locked,
                        iconCircleColor: KasifColor.accentInfo, iconTintColor: KasifColor.accentInfoStrong
                    )
                }
                .buttonStyle(.kasifCategoryCard)

                Button {} label: {
                    KasifCategoryCard(title: "Ana Diller", icon: .system("character.book.closed.fill"), state: .locked)
                }
                .buttonStyle(.kasifCategoryCard)
            }
            .padding(.horizontal, KasifSpacing.xl)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home), points: .constant(340), streak: 12, progress: GameProgress())
}
