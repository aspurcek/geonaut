import SwiftUI

/// "Bayrakları/Ana Dilleri Öğren" satırlarına dokununca çıkan bilgi kartı — Figma
/// "Ülke Bilgi Kartı" (Ana Diller FLOW5 bölümü). Kullanıcı kararı: satırlar
/// dokunulabilir, kart ülke adı + bayrağı + dili + kıtasını gösterir.
struct CountryCardInfo: Identifiable, Equatable {
    let code: String
    let name: String
    let language: String
    let continent: String
    var id: String { code }
}

struct KasifCountryInfoCard: View {
    let info: CountryCardInfo
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(KasifColor.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(KasifColor.bgCanvas, in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text(KasifFlagAnswerOption.flagEmoji(for: info.code))
                .font(.system(size: 64))
                .frame(width: 96, height: 64)

            Text(info.name)
                .font(.custom(KasifFontName.balooExtraBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: KasifSpacing.md) {
                chip(icon: "🗣️", value: info.language, label: "Dili")
                chip(icon: "🌍", value: info.continent, label: "Kıtası")
            }
        }
        .padding(KasifSpacing.xl)
        .frame(width: 350)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
    }

    private func chip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: KasifSpacing.xs) {
            Text(icon).font(.system(size: 22))
            Text(value)
                .font(.custom(KasifFontName.balooExtraBold, size: 16))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KasifSpacing.md)
        .background(KasifColor.bgCanvas, in: RoundedRectangle(cornerRadius: KasifRadius.lg))
    }
}

/// Her iki "Öğren" ekranının da paylaştığı, satıra dokununca kartı scrim üstünde
/// ortalayan overlay — bkz. LearnFlagsView/LearnLanguagesView.
struct CountryInfoOverlay: ViewModifier {
    @Binding var selected: CountryCardInfo?

    func body(content: Content) -> some View {
        content.overlay {
            if let selected {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .onTapGesture { self.selected = nil }
                    KasifCountryInfoCard(info: selected, onClose: { self.selected = nil })
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: selected)
    }
}

extension View {
    func countryInfoOverlay(selected: Binding<CountryCardInfo?>) -> some View {
        modifier(CountryInfoOverlay(selected: selected))
    }
}

#Preview {
    KasifCountryInfoCard(info: CountryCardInfo(code: "DE", name: "Almanya", language: "Almanca", continent: "Avrupa"), onClose: {})
        .padding(KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
}
