import Foundation
struct FlagQuestion {
    enum Direction { case flagToName, nameToFlag, typeName }
    let direction: Direction
    let countryCode: String
    let countryName: String
    let options: [String]
    var flagOptions: [String] = []
}
class UIImage { init?(named: String) {} }
