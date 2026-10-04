import SwiftUI

/// Figma Design System / Bileşenler / NavBar (node 355:14668). 3 sekme: Ana Sayfa,
/// Kupalar, Profil — aktif sekme accentPrimary, diğerleri iconInactive renginde.
enum KasifTab: CaseIterable {
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

struct KasifNavBar: View {
    @Binding var selection: KasifTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(KasifTab.allCases, id: \.self) { tab in
                let isActive = tab == selection
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: KasifSpacing.xs) {
                        Image(systemName: tab.systemImage(isActive: isActive))
                            .font(.system(size: 22))
                        Text(LocalizedStringKey(tab.title))
                            .font(KasifTypography.captionSmall)
                    }
                    .foregroundStyle(isActive ? KasifColor.accentPrimary : KasifColor.iconInactive)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
        .padding(.horizontal, KasifSpacing.md)
        .padding(.top, 14)
        .padding(.bottom, KasifSpacing.xxl)
        .background(KasifColor.bgSurface)
        .clipShape(.rect(topLeadingRadius: KasifRadius.xl, topTrailingRadius: KasifRadius.xl))
        .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: -4)
    }
}

#Preview {
    @Previewable @State var selection: KasifTab = .home
    VStack {
        Spacer()
        KasifNavBar(selection: $selection)
    }
    .ignoresSafeArea(edges: .bottom)
    .background(KasifColor.bgCanvas)
}
