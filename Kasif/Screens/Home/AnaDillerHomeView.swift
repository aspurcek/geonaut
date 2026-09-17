import SwiftUI

/// Ana Diller'in giriş ekranı — HomeView'in Bayrak Tahmin için yaptığı işi görür
/// (başlık + Öğren kısayolu + kıta yolu), ama HomeView zaten Bayrak Tahmin'in kendi
/// ekranı olduğu için (bkz. o dosyadaki mimari not) Ana Diller kendi push edilen
/// ekranına ihtiyaç duyuyor — Harita Bilmece'nin MapPuzzleEntryView'ı gibi.
struct AnaDillerHomeView: View {
    var progress: GameProgress
    var onBack: () -> Void
    var onSelectContinent: (String) -> Void
    var onSelectLearn: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.xxxxl) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(KasifColor.textPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, KasifSpacing.xl)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ana Diller")
                        .font(KasifTypography.headingL)
                        .foregroundStyle(KasifColor.textPrimary)
                    Text("Kıtaları keşfet, ana dilleri öğren!")
                        .font(KasifTypography.bodyBold)
                        .foregroundStyle(KasifColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, KasifSpacing.xl)

                // Bayrak Tahmin'deki mor "Öğren" durağıyla aynı görsel dil (bkz.
                // HomeView.swift) — yalnızca ikon, Ana Diller'in kategori kartıyla
                // aynı "character.book.closed.fill" simgesine çevrildi.
                GeometryReader { geo in
                    Button(action: onSelectLearn) {
                        VStack(spacing: KasifSpacing.sm) {
                            Circle()
                                .fill(Color(hex: 0x9966E6))
                                .frame(width: 56, height: 56)
                                .overlay {
                                    Image(systemName: "character.book.closed.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.white)
                                }
                            Text("Öğren")
                                .font(.custom(KasifFontName.balooBold, size: 14))
                                .foregroundStyle(Color(hex: 0x9966E6))
                        }
                    }
                    .buttonStyle(.plain)
                    .position(x: geo.size.width * 0.62, y: geo.size.height / 2)
                }
                .frame(height: 84)
                .padding(.horizontal, KasifSpacing.xxxxl)

                ContinentPathView(nodes: ContinentPathNode.mainLanguagePath(progress: progress)) { node in
                    guard node.state != .locked else { return }
                    onSelectContinent(node.name)
                }
                .padding(.horizontal, KasifSpacing.xxxxl)
            }
            .padding(.top, KasifSpacing.md)
            .padding(.bottom, KasifSpacing.xxxl)
        }
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    AnaDillerHomeView(progress: GameProgress(), onBack: {}, onSelectContinent: { _ in }, onSelectLearn: {})
}
