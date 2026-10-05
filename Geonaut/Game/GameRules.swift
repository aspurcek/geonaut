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

/// Ana Diller — Bayrak Tahmin ile birebir aynı 7 kıta + Karışık / 8 etap / 10 soru
/// iskeleti (bkz. FlagGuessStructure), kullanıcı kararıyla üç farklı etap üslubu:
/// etap 1-4 standart (bayrak → dil), 5-6 "zor ana diller" (bkz. CountryFacts.isTrickyLanguage),
/// 7-8 karışık (bayrak VEYA harita uyarımı, soru başına rastgele).
enum MainLanguageStructure {
    static let continents = FlagGuessStructure.continents
    static let sectionCount = FlagGuessStructure.sectionCount
    static let stagesPerSection = FlagGuessStructure.stagesPerSection
    static let questionsPerStage = GameRules.questionsPerStage

    enum StageStyle { case standard, tricky, mixed }

    static func style(forStage stageIndex: Int) -> StageStyle {
        switch stageIndex {
        case 0...3: return .standard
        case 4, 5: return .tricky
        default: return .mixed
        }
    }

    /// Bayrak Tahmin'in kıta adlarıyla aynı `GameProgress.completedStages` sözlüğünü
    /// paylaşmamak için ad alanı öneki — aksi hâlde "Avrupa" anahtarı iki kategori
    /// arasında çakışıp ilerlemeyi birbirine karıştırırdı.
    static func progressKey(for continent: String) -> String { "AnaDiller-\(continent)" }
}

/// Dünya Yemekleri — diğer 3 kategori kıta bazlı ilerlerken, Dünya Yemekleri TÜR
/// bazlı ilerliyor: "Avrupa/Asya/..." yerine "Yemekler/İçecekler/Tatlılar", en sonda
/// da "Karışık" (bkz. WorldFoods.makeQuestions(forSection:stageIndex:)). Her bölümün
/// kendi 8 etap/10 soru iskeleti Bayrak Tahmin'inkiyle aynı (bkz. FlagGuessStructure),
/// ama etap içeriği kullanıcı kararıyla şu şekilde sabitlendi (kıta bazlı kategorilerin
/// "tanıma → hatırlama" ilerleyişinden farklı, kendine özgü bir desen):
/// Etap 1-4: yemeğin GÖRSELİ + adı birlikte gösterilir ("Görseldeki '...' hangi
/// ülkeye ait?") — ülke adı şıklarından bulunur.
/// Etap 5: yalnızca yemeğin İSMİ verilir (görsel yok) — şıklar ülke adı değil, 4 ülke
/// BAYRAĞI (görsel şık).
/// Etap 6: yalnızca yemeğin İSMİ verilir (görsel yok) — şıklar düz metin ülke adı.
/// Etap 7-8: hepsi karışık — stil de yön de (ülke→yemek dahil) soru başına rastgele.
/// Bkz. FoodQuestion.Style ve WorldFoods.makeQuestions.
enum WorldFoodStructure {
    static let sections = ["Yemekler", "İçecekler", "Tatlılar", "Karışık"]
    static let sectionCount = sections.count
    static let stagesPerSection = FlagGuessStructure.stagesPerSection
    static let questionsPerStage = GameRules.questionsPerStage

    /// Bir bölüm adını o bölümde sorulacak sabit türe çevirir — "Karışık" için nil
    /// (soru başına rastgele tür, bkz. WorldFoods.makeQuestions).
    static func foodType(for section: String) -> FoodType? {
        switch section {
        case "Yemekler": .yemek
        case "İçecekler": .icecek
        case "Tatlılar": .tatli
        default: nil
        }
    }

    /// Bir etap için sabit soru stili — "Karışık" bölümdeki tür seçimiyle aynı desen:
    /// nil dönerse WorldFoods.makeQuestions soru başına rastgele bir Style seçer
    /// (etap 7-8, stageIndex 6-7).
    static func style(forStage stageIndex: Int) -> FoodQuestion.Style? {
        switch stageIndex {
        case 0, 1, 2, 3: .foodImageToCountry
        case 4: .foodNameToCountryFlags
        case 5: .foodNameToCountryText
        default: nil
        }
    }

    /// Diğer kategorilerin ad-alanlı anahtarlarıyla çakışmaması için önek — bkz.
    /// MainLanguageStructure.progressKey'deki aynı gerekçe.
    static func progressKey(for section: String) -> String { "DunyaYemekleri-\(section)" }
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
