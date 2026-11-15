import SwiftUI

/// "Dünya Yemeklerini Öğren" satırlarına dokununca çıkan bilgi kartı — GeoCountryInfoCard
/// ile aynı görsel dil (bkz. o dosyadaki kullanıcı geri bildirimi notu: native .sheet),
/// ama Dili/Kıtası yerine üç yemek türü (Yemek/Tatlı/İçecek) gösterir — bkz. FoodFacts.
struct FoodCardInfo: Identifiable, Equatable {
    let code: String
    let name: String
    let dish: String
    let dessert: String
    let drink: String
    var id: String { code }
}

private extension FoodType {
    var fixedIcon: String {
        switch self {
        case .yemek: "fork.knife"
        case .tatli: "birthday.cake.fill"
        case .icecek: "cup.and.saucer.fill"
        }
    }

    /// Seçili kutunun kenarı.
    var strongTint: Color {
        switch self {
        case .yemek: GeoColor.accentPrimaryStrong
        case .tatli: GeoColor.accentHighlightStrong
        case .icecek: GeoColor.accentInfoStrong
        }
    }

    var iconBackground: Color {
        switch self {
        case .yemek: GeoColor.accentPrimary
        case .tatli: GeoColor.accentHighlight
        case .icecek: GeoColor.accentInfo
        }
    }
}

/// Kullanıcı kararı (2026-11-14): yemek fotoğrafları listede/vitrinde DEĞİL, yalnızca bu alt
/// sayfada. Ülkenin KAÇ fotoğrafı varsa (1-3) o kadarı üstte kaydırmalı büyük galeride gösterilir;
/// altta üç kutu durur, fotoğrafı olanlar sekme gibi çalışır. Hiç fotoğraf yoksa eski düzen
/// (büyük bayrak + üç kutu).
struct GeoFoodInfoCard: View {
    let info: FoodCardInfo
    @State private var selection: FoodType?

    static let types: [FoodType] = [.yemek, .tatli, .icecek]

    /// Fotoğrafı olan türler (Yemek/Tatlı/İçecek sırasıyla).
    static func photoTypes(_ code: String) -> [FoodType] {
        types.filter { WorldFoods.image(for: code, type: $0) != nil }
    }

    /// En az bir fotoğraf varsa galeri gösterilir.
    static func hasPhotos(_ code: String) -> Bool {
        !photoTypes(code).isEmpty
    }

    private var photoTypes: [FoodType] { Self.photoTypes(info.code) }

    /// Seçili fotoğraf; başlangıçta ilk fotoğraflı tür.
    private var selected: Binding<FoodType> {
        Binding(
            get: { selection ?? photoTypes.first ?? .yemek },
            set: { selection = $0 }
        )
    }

    private func value(_ type: FoodType) -> String {
        switch type {
        case .yemek: info.dish
        case .tatli: info.dessert
        case .icecek: info.drink
        }
    }

    private func label(_ type: FoodType) -> String {
        switch type {
        case .yemek: "Yemek"
        case .tatli: "Tatlı"
        case .icecek: "İçecek"
        }
    }

    var body: some View {
        if Self.hasPhotos(info.code) {
            photoLayout
        } else {
            classicLayout
        }
    }

    // MARK: Fotoğraflı

    private var photoLayout: some View {
        VStack(spacing: GeoSpacing.md) {
            HStack(spacing: GeoSpacing.sm) {
                Text(GeoFlagAnswerOption.flagEmoji(for: info.code))
                    .font(.system(size: 30))
                Text(info.name)
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }

            TabView(selection: selected) {
                ForEach(photoTypes, id: \.self) { type in
                    photo(type).tag(type)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: GeoRadius.xl))

            if photoTypes.count > 1 {
                HStack(spacing: 6) {
                    ForEach(photoTypes, id: \.self) { type in
                        Capsule()
                            .fill(type == selected.wrappedValue ? GeoColor.accentPrimaryStrong : GeoColor.borderSubtle)
                            .frame(width: type == selected.wrappedValue ? 20 : 7, height: 7)
                    }
                }
                .animation(.spring(duration: 0.3), value: selected.wrappedValue)
                .accessibilityHidden(true)
            }

            HStack(spacing: GeoSpacing.md) {
                ForEach(Self.types, id: \.self) { type in
                    if photoTypes.contains(type) {
                        Button {
                            withAnimation(.spring(duration: 0.35)) { selection = type }
                        } label: {
                            chip(type: type, value: value(type), label: label(type), isSelected: type == selected.wrappedValue)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(type == selected.wrappedValue ? .isSelected : [])
                    } else {
                        // Fotoğrafı olmayan tür: yalnızca bilgi kutusu (dokunulmaz).
                        chip(type: type, value: value(type), label: label(type), isSelected: false)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: selection)
    }

    @ViewBuilder
    private func photo(_ type: FoodType) -> some View {
        if let name = WorldFoods.image(for: info.code, type: type) {
            Color.clear
                .overlay {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 6) {
                        GeoGlyphCircle(symbol: type.fixedIcon, background: type.iconBackground, size: 22)
                        Text(LocalizedStringKey(label(type)))
                            .foregroundStyle(GeoColor.textSecondary)
                        Text(verbatim: "·")
                            .foregroundStyle(GeoColor.textMuted)
                        Text(D(value(type)))
                            .foregroundStyle(GeoColor.textPrimary)
                            .lineLimit(1)
                    }
                    .font(GeoTypography.bodyBold)
                    .padding(.leading, 5)
                    .padding(.trailing, GeoSpacing.md)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.92), in: Capsule())
                    .padding(GeoSpacing.md)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "\(L(label(type))): \(D(value(type)))"))
        }
    }

    // MARK: Fotoğrafsız (eski düzen)

    private var classicLayout: some View {
        VStack(spacing: GeoSpacing.lg) {
            Text(GeoFlagAnswerOption.flagEmoji(for: info.code))
                .font(.system(size: 64))
                .frame(width: 96, height: 64)

            Text(info.name)
                .font(.custom(GeoFontName.balooExtraBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.md) {
                ForEach(Self.types, id: \.self) { type in
                    chip(type: type, value: value(type), label: label(type), isSelected: false)
                }
            }
            // Kullanıcı kararı: üç kutu da aynı yükseklikte olsun — en uzun kutuya eşitlenir.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    /// Yemek/Tatlı/İçecek kutuları: her ülkede aynı sabit ikon (çatal-bıçak / pasta / fincan).
    @ViewBuilder
    private func chip(type: FoodType, value: String, label: String, isSelected: Bool) -> some View {
        VStack(spacing: GeoSpacing.xs) {
            GeoGlyphCircle(symbol: type.fixedIcon, background: type.iconBackground, size: 30)
            Text(D(value))
                .font(.custom(GeoFontName.balooExtraBold, size: 14))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(LocalizedStringKey(label))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, GeoSpacing.md)
        .background(isSelected ? type.iconBackground.opacity(0.18) : GeoColor.bgCanvas, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: GeoRadius.lg)
                .strokeBorder(isSelected ? type.strongTint : .clear, lineWidth: 2.5)
        }
    }
}

private struct FoodSheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

/// Alt sayfa içeriği: yüksekliği içeriğe göre ölçülür — üstte/altta boş alan kalmaz.
private struct FoodInfoSheetContent: View {
    let info: FoodCardInfo
    @State private var height: CGFloat = 0

    var body: some View {
        GeoFoodInfoCard(info: info)
            .padding(.bottom, GeoSpacing.sm)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: FoodSheetHeightKey.self, value: proxy.size.height)
                }
            }
            .onPreferenceChange(FoodSheetHeightKey.self) { if $0 > 0 { height = $0 } }
            .frame(maxHeight: .infinity, alignment: .top)
            .presentationDetents([.height(height > 0 ? height : (GeoFoodInfoCard.hasPhotos(info.code) ? 470 : 320))])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.white)
    }
}

extension View {
    func foodInfoSheet(selected: Binding<FoodCardInfo?>) -> some View {
        sheet(item: selected) { info in
            FoodInfoSheetContent(info: info)
        }
    }
}

#Preview {
    GeoFoodInfoCard(info: FoodCardInfo(code: "IT", name: "İtalya", dish: "Pizza", dessert: "Tiramisu", drink: "Espresso"))
        .background(Color.white)
}
