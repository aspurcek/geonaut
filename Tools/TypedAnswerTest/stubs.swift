import Foundation
struct FlagQuestion {
    enum Direction { case flagToName, nameToFlag, typeName }
    let direction: Direction
    let countryCode: String
    let countryName: String
    let options: [String]
    var flagOptions: [String] = []
}
func D(_ s: String) -> String { s }
func L(_ s: String) -> String { s }
enum FoodType: CaseIterable { case yemek, tatli, icecek }
struct FoodQuestion { enum Style: CaseIterable { case foodImageToCountry, foodNameToCountryFlags, foodNameToCountryText, countryToFood } }
