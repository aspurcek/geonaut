import SwiftUI

/// Text styles from Figma "Design System / 3. Tipografi".
/// Display/Heading/Title/Label use "Baloo 2" (rounded, playful — headers).
/// Body/Caption use "Nunito" (body copy).
///
/// TODO: Baloo 2 and Nunito are Google Fonts, not preinstalled on iOS — the .ttf files
/// need to be added to the Xcode target and registered in Info.plist (UIAppFonts) before
/// `Font.custom` below resolves to the real typeface instead of falling back.
enum GeoFontName {
    static let balooExtraBold = "Baloo2-ExtraBold"
    static let balooBold = "Baloo2-Bold"
    static let nunitoExtraBold = "Nunito-ExtraBold"
    static let nunitoBold = "Nunito-Bold"
}

enum GeoTypography {
    static let display = Font.custom(GeoFontName.balooExtraBold, size: 40)
    static let headingL = Font.custom(GeoFontName.balooExtraBold, size: 24)
    static let headingM = Font.custom(GeoFontName.balooExtraBold, size: 19)
    static let title = Font.custom(GeoFontName.balooBold, size: 17)
    static let label = Font.custom(GeoFontName.balooBold, size: 14)

    static let bodyBoldL = Font.custom(GeoFontName.nunitoExtraBold, size: 16)
    static let bodyBold = Font.custom(GeoFontName.nunitoExtraBold, size: 14)
    static let bodySemibold = Font.custom(GeoFontName.nunitoBold, size: 13)
    static let caption = Font.custom(GeoFontName.nunitoBold, size: 11)
    static let captionSmall = Font.custom(GeoFontName.nunitoBold, size: 10)
}
