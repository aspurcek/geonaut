import Foundation
struct GeoEtapNode { enum State { case completed, active, locked } }
struct GeoContinentNode { enum State { case completed, active, locked } }
struct FlagQuestion {
    enum Direction { case flagToName, nameToFlag, typeName }
    let direction: Direction
    let countryCode: String
    let countryName: String
    let options: [String]
    var flagOptions: [String] = []
}
enum FoodType: CaseIterable { case yemek, tatli, icecek }
struct FoodQuestion { enum Style: CaseIterable { case foodImageToCountry, foodNameToCountryFlags, foodNameToCountryText, countryToFood } }
func D(_ s: String) -> String { s }
func L(_ s: String) -> String { s }
import SwiftUI
struct AvatarCharacter: Equatable {
    var skinTone: SkinTone = .acik
    var hairStyle: HairStyle = .kisa
    var hairColorHex: UInt32 = 0x222938
    var accessory: AvatarAccessory? = nil
    var facialFeature: AvatarFacialFeature? = nil
}

