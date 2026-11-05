import Foundation

/// Oturum boyunca kalıcı ilerleme durumu — hangi etap/kıta bitirilmiş. RootTabView'in
/// init'i PlayerProfile.completedStageKeys'ten geri yükler, onStageCompleted da
/// PlayerCloudKitService'e yazar (bkz. AppState.recordStageCompletion) — bellek-içi değil.
///
/// Bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir etap ancak öncekinin bitirilmesiyle açılır."
@Observable
final class GameProgress {
    private(set) var completedStages: [String: Set<Int>] = [:]
    /// "Öğrenilen Ülke" istatistiği (bkz. Kaşif Uygulama Kural Kitabı böl. 08) — bir
    /// ülke, bir soruda (Bayrak Tahmin, Harita Bilmece ya da Ana Diller — doğru/yanlış fark etmez)
    /// gösterilip cevaplandığında bu kümeye eklenir. Kullanıcı kararı: "görüp cevap
    /// verdiği ülkeler" = öğrenilen ülkeler.
    private(set) var learnedCountryCodes: Set<String> = []
    /// "kıta|etapIndex" → o etapta şimdiye kadar kazanılan en yüksek puan. Bkz.
    /// pointsToAward: "bir etap tekrar oynanırsa puan yalnızca en iyi sonuca göre
    /// güncellenir" kuralını uygulamak için gerekli — tek başına completedStages
    /// (bitti/bitmedi) bunu yapmaya yetmiyor, çünkü etap tekrar oynanabiliyor.
    private(set) var bestPointsByStage: [String: Int] = [:]

    private static let keySeparator = "|"

    /// Uygulama içeriğinden çıkarılan ülke kodları — eski kayıtlardaki izleri sayımlardan düşülür.
    static let removedCountryCodes: Set<String> = ["IL"]

    init() {}

    /// PlayerProfile'dan geri yükler (bkz. "kıta|etapIndex" biçimi completedStageKeys için).
    init(completedStageKeys: Set<String>, learnedCountryCodes: Set<String> = [], bestPointsByStage: [String] = []) {
        for key in completedStageKeys {
            let parts = key.components(separatedBy: Self.keySeparator)
            guard parts.count == 2, let index = Int(parts[1]) else { continue }
            completedStages[parts[0], default: []].insert(index)
        }
        // İçerikten çıkarılan ülkeler (bkz. removedCountryCodes) eski kayıtlarda kalmış olabilir; sayıma girmesin.
        self.learnedCountryCodes = learnedCountryCodes.subtracting(Self.removedCountryCodes)
        for entry in bestPointsByStage {
            let parts = entry.components(separatedBy: "=")
            guard parts.count == 2, let value = Int(parts[1]) else { continue }
            self.bestPointsByStage[parts[0]] = value
        }
    }

    /// Bir oturumda (bir etabın tamamı) gösterilip cevaplanan ülke kodlarını ekler —
    /// bkz. HomeView'in onFinished handler'ları: `session.questions` üzerinden.
    func markCountriesSeen(_ codes: [String]) {
        learnedCountryCodes.formUnion(codes)
        learnedCountryCodes.subtract(Self.removedCountryCodes)
    }

    /// CloudKit'e yazılmak üzere düz bir küme hâline getirir — bkz. PlayerProfile.completedStageKeys.
    var completedStageKeysExport: Set<String> {
        var result: Set<String> = []
        for (continent, indices) in completedStages {
            for index in indices {
                result.insert("\(continent)\(Self.keySeparator)\(index)")
            }
        }
        return result
    }

    /// CloudKit'e yazılmak üzere düz bir dizi hâline getirir — bkz. PlayerProfile.bestPointsByStage.
    var bestPointsExport: [String] {
        bestPointsByStage.map { "\($0.key)=\($0.value)" }
    }

    /// Şimdiye kadar KAZANILAN toplam puan (başlangıç puanı + her etabın en iyi sonucu) —
    /// harcamalardan ("Puanla Devam Et", seri canlandırma) etkilenmez, hiç azalmaz. Seviye
    /// adı (GeoLevel) bakiyeye değil buna bağlı: aksi hâlde puan harcamak seviyeyi düşürürdü.
    var lifetimePoints: Int {
        GameRules.newPlayerStartingPoints + bestPointsByStage.values.reduce(0, +)
    }

    func markStageCompleted(continent: String, stageIndex: Int) {
        completedStages[continent, default: []].insert(stageIndex)
    }

    /// Bir etap bitiminde toplam puana EKLENMESİ gereken miktarı hesaplar — bkz. Harita
    /// Bilmece Kural Kitabı böl. 08: "Bir etap tekrar oynanırsa puan ve yıldız yalnızca
    /// en iyi sonuca göre güncellenir." İlk kez oynanıyorsa ya da önceki rekor kırıldıysa
    /// farkı döndürür; aksi hâlde 0 — aksi takdirde bir etabı tekrar tekrar oynayarak
    /// puan biriktirmek (farming) mümkün olurdu.
    func pointsToAward(continent: String, stageIndex: Int, earnedPoints: Int) -> Int {
        let key = "\(continent)\(Self.keySeparator)\(stageIndex)"
        let previousBest = bestPointsByStage[key] ?? 0
        guard earnedPoints > previousBest else { return 0 }
        bestPointsByStage[key] = earnedPoints
        return earnedPoints - previousBest
    }

    func isStageCompleted(continent: String, stageIndex: Int) -> Bool {
        completedStages[continent]?.contains(stageIndex) ?? false
    }

    /// Bir kıtanın 8 etaplık durumunu hesaplar: bitmiş → completed, ilk bitmemiş → active,
    /// sonrakiler → locked.
    func etapStates(continent: String, stageCount: Int) -> [GeoEtapNode.State] {
        let done = completedStages[continent] ?? []
        var states: [GeoEtapNode.State] = []
        var nextIsActive = true
        for index in 0..<stageCount {
            if done.contains(index) {
                states.append(.completed)
            } else if nextIsActive {
                states.append(.active)
                nextIsActive = false
            } else {
                states.append(.locked)
            }
        }
        return states
    }

    func isContinentCompleted(_ continent: String, stageCount: Int) -> Bool {
        (completedStages[continent]?.count ?? 0) >= stageCount
    }

    // MARK: - Tur sistemi (Tur 1 / Tur 2 / Tur 3)
    //
    // Kullanıcı kararı: her kategorinin 3 turu var. Tur 1 bitince hem Tur 2 hem DİĞER
    // kategoriler açılır; kategori kupası ancak 3 turun HEPSİ bitince verilir. Kıta/bölüm
    // rozetleri Tur 1'e bağlı kalır (bkz. BadgeCatalog).

    /// Bir kategorinin verilen turdaki (0 = Tur 1) tüm bölümleri bitti mi.
    func isCategoryCompleted(_ category: TourCategory, tour: Int) -> Bool {
        func done(_ key: String, _ count: Int) -> Bool {
            isContinentCompleted(TourStructure.progressKey(key, tour: tour), stageCount: count)
        }
        switch category {
        case .flags:
            return ContinentPathNode.order.allSatisfy { done($0.name, FlagGuessStructure.stagesPerSection) }
        case .maps:
            return done(MapPuzzleStructure.progressKey, MapPuzzleStructure.stageCount)
                && done(CountryPuzzleStructure.progressKey, CountryPuzzleStructure.stageCount)
        case .languages:
            return ContinentPathNode.order.allSatisfy { done(MainLanguageStructure.progressKey(for: $0.name), MainLanguageStructure.stagesPerSection) }
        case .foods:
            return WorldFoodStructure.sections.allSatisfy { done(WorldFoodStructure.progressKey(for: $0), WorldFoodStructure.stagesPerSection) }
        }
    }

    /// Tur 2/3, bir önceki tur bitince açılır; Tur 1 hep açık.
    /// Demo/misafir modu için: tüm kategorilerin tüm turlarındaki tüm etapları "bitmiş"
    /// işaretler — böylece her kilit açık olur ve her etap yeniden oynanabilir.
    static var allStageKeys: Set<String> {
        var keys = Set<String>()
        for tour in 0..<TourStructure.count {
            func add(_ base: String, _ count: Int) {
                for stage in 0..<count { keys.insert("\(TourStructure.progressKey(base, tour: tour))|\(stage)") }
            }
            for entry in ContinentPathNode.order {
                add(entry.name, FlagGuessStructure.stagesPerSection)
                add(MainLanguageStructure.progressKey(for: entry.name), MainLanguageStructure.stagesPerSection)
            }
            add(MapPuzzleStructure.progressKey, MapPuzzleStructure.stageCount)
            add(CountryPuzzleStructure.progressKey, CountryPuzzleStructure.stageCount)
            for section in WorldFoodStructure.sections {
                add(WorldFoodStructure.progressKey(for: section), WorldFoodStructure.stagesPerSection)
            }
        }
        return keys
    }

    func isTourUnlocked(_ category: TourCategory, tour: Int) -> Bool {
        tour <= 0 || isCategoryCompleted(category, tour: tour - 1)
    }

    /// Kategori kupası — 3 turun HEPSİ bitince.
    func isCategoryTrophyEarned(_ category: TourCategory) -> Bool {
        (0..<TourStructure.count).allSatisfy { isCategoryCompleted(category, tour: $0) }
    }

    /// Bayrak Tahmin Tur 1 (7 kıta + Karışık) bitti mi — sonraki kategorinin kilidini açar.
    func isFlagGuessCategoryCompleted() -> Bool { isCategoryCompleted(.flags, tour: 0) }

    /// Harita Bilmece'nin Kıtalar bölümü bitti mi (bkz. MapPuzzleStructure) — Tur 1.
    func isMapPuzzleContinentsCompleted() -> Bool {
        isContinentCompleted(MapPuzzleStructure.progressKey, stageCount: MapPuzzleStructure.stageCount)
    }

    /// Harita Bilmece'nin Ülkeler bölümü bitti mi (bkz. CountryPuzzleStructure) — Tur 1.
    func isMapPuzzleCountriesCompleted() -> Bool {
        isContinentCompleted(CountryPuzzleStructure.progressKey, stageCount: CountryPuzzleStructure.stageCount)
    }

    /// Haritalar Tur 1 (Kıtalar + Ülkeler) bitti mi.
    func isMapPuzzleCategoryCompleted() -> Bool { isCategoryCompleted(.maps, tour: 0) }

    /// Diller Tur 1 (7 kıta + Karışık) bitti mi.
    func isMainLanguageCategoryCompleted() -> Bool { isCategoryCompleted(.languages, tour: 0) }

    /// Lezzetler Tur 1 (Yemekler/İçecekler/Tatlılar + Karışık) bitti mi.
    func isWorldFoodCategoryCompleted() -> Bool { isCategoryCompleted(.foods, tour: 0) }
}
