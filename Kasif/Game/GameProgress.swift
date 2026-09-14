import Foundation

/// Oturum boyunca kalıcı ilerleme durumu — hangi etap/kıta bitirilmiş. RootTabView'in
/// init'i PlayerProfile.completedStageKeys'ten geri yükler, onProgressChanged da
/// PlayerCloudKitService'e yazar (bkz. AppState.syncGameProgress) — bellek-içi değil.
///
/// Bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir etap ancak öncekinin bitirilmesiyle açılır."
@Observable
final class GameProgress {
    private(set) var completedStages: [String: Set<Int>] = [:]
    /// "Öğrenilen Ülke" istatistiği (bkz. Kaşif Uygulama Kural Kitabı böl. 08) — bir
    /// ülke, bir soruda (Bayrak Tahmin ya da Harita Bilmece, doğru/yanlış fark etmez)
    /// gösterilip cevaplandığında bu kümeye eklenir. Kullanıcı kararı: "görüp cevap
    /// verdiği ülkeler" = öğrenilen ülkeler.
    private(set) var learnedCountryCodes: Set<String> = []
    /// "kıta|etapIndex" → o etapta şimdiye kadar kazanılan en yüksek puan. Bkz.
    /// pointsToAward: "bir etap tekrar oynanırsa puan yalnızca en iyi sonuca göre
    /// güncellenir" kuralını uygulamak için gerekli — tek başına completedStages
    /// (bitti/bitmedi) bunu yapmaya yetmiyor, çünkü etap tekrar oynanabiliyor.
    private(set) var bestPointsByStage: [String: Int] = [:]

    private static let keySeparator = "|"

    init() {}

    /// PlayerProfile'dan geri yükler (bkz. "kıta|etapIndex" biçimi completedStageKeys için).
    init(completedStageKeys: Set<String>, learnedCountryCodes: Set<String> = [], bestPointsByStage: [String] = []) {
        for key in completedStageKeys {
            let parts = key.components(separatedBy: Self.keySeparator)
            guard parts.count == 2, let index = Int(parts[1]) else { continue }
            completedStages[parts[0], default: []].insert(index)
        }
        self.learnedCountryCodes = learnedCountryCodes
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
    func etapStates(continent: String, stageCount: Int) -> [KasifEtapNode.State] {
        let done = completedStages[continent] ?? []
        var states: [KasifEtapNode.State] = []
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

    /// Bayrak Tahmin kategorisinin tamamı (7 kıta + Karışık) bitti mi — bkz. Bayrak
    /// Tahmin Kural Kitabı böl. 07: "8 bölümün hepsi bitince kategori kupası verilir."
    func isFlagGuessCategoryCompleted() -> Bool {
        ContinentPathNode.order.allSatisfy { isContinentCompleted($0.name, stageCount: FlagGuessStructure.stagesPerSection) }
    }

    /// Harita Bilmece'nin Kıtalar bölümü bitti mi (bkz. MapPuzzleStructure).
    func isMapPuzzleContinentsCompleted() -> Bool {
        isContinentCompleted(MapPuzzleStructure.progressKey, stageCount: MapPuzzleStructure.stageCount)
    }

    /// Harita Bilmece'nin Ülkeler bölümü bitti mi (bkz. CountryPuzzleStructure).
    func isMapPuzzleCountriesCompleted() -> Bool {
        isContinentCompleted(CountryPuzzleStructure.progressKey, stageCount: CountryPuzzleStructure.stageCount)
    }

    /// Harita Bilmece Kupası — Figma'nın "Rozetler & Kupalar" ekranı (bkz. BadgeCatalog)
    /// bu kategori için 2 ayrı rozet (Kıtalar + Ülkeler) gösteriyor; Bayrak Tahmin'de
    /// kupa nasıl tüm kıta rozetlerini gerektiriyorsa, burada da kupa ikisinin de
    /// bitirilmesini gerektirir — tek bölüm bitince kupa vermek rozet ayrımını anlamsızlaştırırdı.
    func isMapPuzzleCategoryCompleted() -> Bool {
        isMapPuzzleContinentsCompleted() && isMapPuzzleCountriesCompleted()
    }
}
