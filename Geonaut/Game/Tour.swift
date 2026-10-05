import Foundation

/// Her kategorinin 3 turu ("Tur 1 / Tur 2 / Tur 3") — kullanıcı kararı: aynı kıta/etap
/// yolu, ama her turda FARKLI sorular (zorlaşmaz, yalnızca farklılaşır). Tur 1 = eski
/// anahtarlar (mevcut ilerleme bozulmaz, CloudKit şeması değişmez); Tur 2/3 anahtarın
/// önüne "Tur2-"/"Tur3-" eklenir.
enum TourCategory: Hashable, CaseIterable {
    case flags, maps, languages, foods
}

enum TourStructure {
    static let count = 3
    static var lastTour: Int { count - 1 }

    /// Ham ilerleme anahtarına tur ön eki ekler — tur 0 (Tur 1) anahtarı değiştirmez.
    static func progressKey(_ base: String, tour: Int) -> String {
        tour <= 0 ? base : "Tur\(tour + 1)-\(base)"
    }

    /// Bir etapta o tura özgü "öncelikli" ülke penceresi. Havuz kod sırasına dizilir,
    /// pencerenin başlangıcı tura ve etaba göre kayar — böylece aynı etap Tur 1'de,
    /// Tur 2'de ve Tur 3'te büyük ölçüde FARKLI ülkelerle sorulur. Havuz küçükse
    /// (pencereden büyük değilse) hepsi öncelikli sayılır.
    static func preferredCodes(_ codes: [String], tour: Int, stageIndex: Int, size: Int = GameRules.questionsPerStage) -> Set<String> {
        let sorted = Array(Set(codes)).sorted()
        let n = sorted.count
        guard n > size else { return Set(sorted) }
        let start = (max(tour, 0) * n / count + max(stageIndex, 0) * size) % n
        return Set((0..<size).map { sorted[(start + $0) % n] })
    }

    /// Adaylar arasından, varsa pencere içindekilerden rastgele seçer; pencere içinde aday
    /// kalmadıysa (örn. havuz tükendi) tüm adaylara düşer.
    static func pick<T>(_ candidates: [T], code: (T) -> String, preferred: Set<String>) -> T? {
        let inWindow = candidates.filter { preferred.contains(code($0)) }
        return (inWindow.isEmpty ? candidates : inWindow).randomElement()
    }

    /// Karılmış bir deste — önce pencere içindekiler, sonra gerisi (her iki grup kendi içinde karışık).
    static func deck<T>(_ items: [T], code: (T) -> String, preferred: Set<String>) -> [T] {
        let shuffled = items.shuffled()
        return shuffled.filter { preferred.contains(code($0)) } + shuffled.filter { !preferred.contains(code($0)) }
    }
}
