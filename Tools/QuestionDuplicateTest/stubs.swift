import Foundation
struct GeoEtapNode { enum State { case completed, active, locked } }
struct GeoContinentNode { enum State { case completed, active, locked } }
struct FlagQuestion { enum Direction { case flagToName, nameToFlag, typeName }
    let direction: Direction; let countryCode: String; let countryName: String; let options: [String]; var flagOptions: [String] = [] }
class UIImage { init?(named: String) {} }
/// İngilizce görünüm benzetimi: farklı Türkçe adların aynı görünen ada dönüştüğü durumlar.
func D(_ s: String) -> String {
    switch s {
    case "Flamanca": return "Dutch"
    case "Hollandaca": return "Dutch"
    case "Rumca": return "Greek"
    case "Yunanca": return "Greek"
    case "Karadağca": return "Serbian"
    case "Sırpça": return "Serbian"
    default: return s
    }
}
func L(_ s: String) -> String { s }
