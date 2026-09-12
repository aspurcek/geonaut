import SwiftUI

/// Text styles from Figma "Design System / 3. Tipografi".
/// Display/Heading/Title/Label use "Baloo 2" (rounded, playful — headers).
/// Body/Caption use "Nunito" (body copy).
///
/// TODO: Baloo 2 and Nunito are Google Fonts, not preinstalled on iOS — the .ttf files
/// need to be added to the Xcode target and registered in Info.plist (UIAppFonts) before
/// `Font.custom` below resolves to the real typeface instead of falling back.
enum KasifFontName {
    static let balooExtraBold = "Baloo2-ExtraBold"
    static let balooBold = "Baloo2-Bold"
    static let nunitoExtraBold = "Nunito-ExtraBold"
    static let nunitoBold = "Nunito-Bold"
}

enum KasifTypography {
    static let display = Font.custom(KasifFontName.balooExtraBold, size: 40)
    static let headingL = Font.custom(KasifFontName.balooExtraBold, size: 24)
    static let headingM = Font.custom(KasifFontName.balooExtraBold, size: 19)
    static let title = Font.custom(KasifFontName.balooBold, size: 17)
    static let label = Font.custom(KasifFontName.balooBold, size: 14)

    static let bodyBoldL = Font.custom(KasifFontName.nunitoExtraBold, size: 16)
    static let bodyBold = Font.custom(KasifFontName.nunitoExtraBold, size: 14)
    static let bodySemibold = Font.custom(KasifFontName.nunitoBold, size: 13)
    static let caption = Font.custom(KasifFontName.nunitoBold, size: 11)
    static let captionSmall = Font.custom(KasifFontName.nunitoBold, size: 10)
}
