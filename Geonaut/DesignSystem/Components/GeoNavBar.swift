import SwiftUI

/// Figma Design System / Bileşenler / NavBar (node 355:14668). 3 sekme: Ana Sayfa,
/// Kupalar, Profil — aktif sekme accentPrimary, diğerleri iconInactive renginde.
enum GeoTab: CaseIterable {
    case home, cups, profile

    var title: String {
        switch self {
        case .home: "Ana Sayfa"
        case .cups: "Kupalar"
        case .profile: "Profil"
        }
    }

    func systemImage(isActive: Bool) -> String {
        switch self {
        case .home: isActive ? "house.fill" : "house"
        case .cups: isActive ? "trophy.fill" : "trophy"
        case .profile: isActive ? "person.fill" : "person"
        }
    }
}

struct GeoNavBar: View {
    @Binding var selection: GeoTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GeoTab.allCases, id: \.self) { tab in
                let isActive = tab == selection
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: GeoSpacing.xs) {
                        Image(systemName: tab.systemImage(isActive: isActive))
                            .font(.system(size: 22))
                        Text(LocalizedStringKey(tab.title))
                            .font(GeoTypography.captionSmall)
                    }
                    .foregroundStyle(isActive ? GeoColor.accentPrimary : GeoColor.iconInactive)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
        .padding(.horizontal, GeoSpacing.md)
        .padding(.top, 14)
        .padding(.bottom, GeoSpacing.xxl)
        .background(GeoColor.bgSurface)
        .clipShape(.rect(topLeadingRadius: GeoRadius.xl, topTrailingRadius: GeoRadius.xl))
        .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: -4)
    }
}

#Preview {
    @Previewable @State var selection: GeoTab = .home
    VStack {
        Spacer()
        GeoNavBar(selection: $selection)
    }
    .ignoresSafeArea(edges: .bottom)
    .background(GeoColor.bgCanvas)
}
