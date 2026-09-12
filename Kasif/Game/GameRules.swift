import Foundation

/// Can/puan/yıldız mekaniği — Bayrak Tahmin ve Harita Bilmece kategorileri arasında
/// birebir ortak (bkz. Bayrak Tahmin Kural Kitabı böl. 04-06, Harita Bilmece Kural
/// Kitabı böl. 06). Bu sabitler her iki oyun motorunun da tek kaynağı olmalı.
enum GameRules {
    static let questionsPerStage = 10
    static let startingHeartsPerSession = 5
    static let pointsPerCorrectAnswer = 10
    static let pointsPerWrongAnswer = 0

    static let newPlayerStartingPoints = 100

    /// Canlar bittiğinde puanla devam etme bedeli — 5 doğru cevabın karşılığı (5 × 10).
    static let heartRefillCost = 50

    /// Seri kaybedildiğinde canlandırma bedeli — bkz. Figma "Serini Kaybettin" (node
    /// 508:12138): "50 puan harcayarak serini kaldığın yerden canlandırabilirsin."
    static let streakReviveCost = 50

    static let passiveHeartRegenInterval: TimeInterval = 30 * 60
    static let maxHearts = 5

    /// Etap Tamamlandı ekranındaki yıldız eşiği. Doğru sayısı bu eşiklerden büyük/eşit
    /// olduğu en yüksek kademe kazanılır. 6 doğru = alt sınır (can mekaniğinin
    /// matematiksel sonucu: 5. yanlışta oturum zaten bitiyor).
    static func stars(correctCount: Int) -> Int {
        switch correctCount {
        case 9...10: return 3
        case 7...8: return 2
        case 6: return 1
        default: return 0
        }
    }
}

/// Bayrak Tahmin — bölüm/etap/soru yapısı (bkz. Bayrak Tahmin Kural Kitabı böl. 01, 03).
enum FlagGuessStructure {
    static let continents = [
        "Avrupa", "Asya", "Afrika", "Kuzey Amerika",
        "Güney Amerika", "Okyanusya", "Antarktika"
    ]
    /// 7 kıta + Karışık (7 kıtayı bitirince açılan, tüm dünyadan rastgele soran ustalık turu).
    static let sectionCount = continents.count + 1
    static let stagesPerSection = 8
    static let questionsPerStage = GameRules.questionsPerStage

    /// Etap 1-5: bayrak → 4 ülke adı şıkkı (tanıma).
    /// Etap 6-8: yön rastgele — bayrak→isim ya da isim→4 bayrak şıkkı (hatırlama).
    static func isRecallStage(_ stageIndex: Int) -> Bool { stageIndex >= 6 }
}

/// Harita Bilmece — bkz. Harita Bilmece Kural Kitabı böl. 01, 04, 05.
///
/// Kaynak notu: Harita Bilmece kural kitabı PDF'i "Bölüm: 1 (yalnız Kıtalar)" diyor,
/// ama bu güncel değil — Figma'daki gerçek Rozetler ekranı (node 355:13868, kullanıcı
/// tarafından 2026-09-10'da doğrulandı) Kıtalar + Ülkeler olmak üzere 2 ayrı bölüm/rozet
/// olduğunu gösteriyor. PDF'ler tasarımla çelişirse Figma esas alınır.
enum MapPuzzleStructure {
    static let stageCount = 8
    static let questionsPerStage = GameRules.questionsPerStage
    /// GameProgress'in [continent: Set<Int>] deposunda Harita Bilmece'nin tek bölümünü
    /// (Kıtalar) işaretlemek için kullanılan anahtar — gerçek bir kıta adı değil.
    static let progressKey = "HaritaBilmeceKıtalar"

    /// Tip A: haritada vurgulu kıta → isim seç (en kolay, tanıma).
    /// Tip B: bayrak + ipucu harita → kıta seç (yönlendirilmiş hatırlama).
    /// Tip C: bayrak, ipucu/şık yok → haritadan doğru kıtaya dokun (serbest hatırlama).
    /// Etap dağılımı: 1-2 A · 3 A+B · 4 A+B+C · 5 B+C · 6-8 tam rastgele karışım.
    enum QuestionType { case highlightMapSelectName, flagWithHintMap, flagTapMap }

    static func questionTypes(forStage stage: Int) -> [QuestionType] {
        switch stage {
        case 1, 2: return [.highlightMapSelectName]
        case 3: return [.highlightMapSelectName, .flagWithHintMap]
        case 4: return [.highlightMapSelectName, .flagWithHintMap, .flagTapMap]
        case 5: return [.flagWithHintMap, .flagTapMap]
        default: return [.highlightMapSelectName, .flagWithHintMap, .flagTapMap]
        }
    }
}

/// Harita Bilmece'nin ikinci bölümü — Figma "Etap Haritası - Ülkeler" (node 339:15032)
/// ve "Soru - Ülke Seç" ekranları (Tip A: 339:15087, Tip B: 339:15386). Kural kitabı PDF'i
/// bu bölümü tanımlamıyor (yalnızca Kıtalar'ı kapsıyor) — yapı doğrudan bu gerçek Figma
/// ekranlarından çıkarıldı: Kıtalar ile aynı 8 etap/10 soru iskeleti, kendi ilerleme anahtarı.
enum CountryPuzzleStructure {
    static let stageCount = 8
    static let questionsPerStage = GameRules.questionsPerStage
    /// GameProgress'in [continent: Set<Int>] deposunda Ülkeler bölümünü işaretlemek
    /// için kullanılan anahtar — gerçek bir kıta adı değil (bkz. MapPuzzleStructure.progressKey).
    static let progressKey = "HaritaBilmeceÜlkeler"

    /// Tip A: haritada vurgulu ülke → isim seç (en kolay, tanıma).
    /// Tip B: bayrak → 4 ülke haritası şıklı seç (yönlendirilmiş hatırlama).
    enum QuestionType { case highlightMapSelectName, flagWithMapChoices }

    /// Figma yalnızca etap 1-4 (Tip A) ve 5-6 (Tip B) için örnek ekran çizmiş; 7-8 için
    /// açık bir spesifikasyon yok. Kıtalar bölümündeki "sona doğru tam karışım" ilkesi
    /// (bkz. MapPuzzleStructure.questionTypes) burada da uygulandı.
    static func questionTypes(forStage stage: Int) -> [QuestionType] {
        switch stage {
        case 1...4: return [.highlightMapSelectName]
        case 5, 6: return [.flagWithMapChoices]
        default: return [.highlightMapSelectName, .flagWithMapChoices]
        }
    }
}
