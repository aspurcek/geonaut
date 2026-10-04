import UIKit

/// iPad'e özel yerleşim sabitleri (30 Eyl 2026). Arayüz iPhone genişliğinde
/// tasarlandığı için iPad'de merkezi bir sütun olarak gösteriliyor — ama sütun
/// genişliği artık cihaza göre değişiyor: iPad'de daha geniş bir sütun, kendi
/// kendine sarmalanan (flow) bileşenlerin (kategori kartları, rozet ızgarası)
/// tek satırda/ekranda daha fazla öğe göstermesini sağlıyor.
enum KasifLayout {
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// KasifApp.swift'teki ortalanmış sütunun üst genişlik sınırı.
    static var columnMaxWidth: CGFloat { isPad ? 900 : 640 }
}
