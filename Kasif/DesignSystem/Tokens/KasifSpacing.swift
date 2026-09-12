import CoreGraphics

/// Spacing scale from Figma "Design System / 2. Boşluk & Köşe". Values in points.
enum KasifSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let xxxxl: CGFloat = 40
}

/// Corner radius scale from the same Figma section.
enum KasifRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}
