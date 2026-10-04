import Foundation
struct KasifEtapNode { enum State { case completed, active, locked } }
struct KasifContinentNode { enum State { case completed, active, locked } }
struct FlagQuestion { enum Direction { case flagToName, nameToFlag }
    let direction: Direction; let countryCode: String; let countryName: String; let options: [String]; var flagOptions: [String] = [] }
class UIImage { init?(named: String) {} }
func D(_ s: String) -> String { s }
func L(_ s: String) -> String { s }
