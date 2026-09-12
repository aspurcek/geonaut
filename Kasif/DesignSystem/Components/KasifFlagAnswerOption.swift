import SwiftUI

/// Figma Design System / Bileşenler / Flag Answer Option (node 298:8893). State=Default/Correct/Wrong.
///
/// TASARIM NOTU: Figma'da her bayrak Design System'e elle eklenmiş bir vektör asset.
/// 254 bayrağın tamamını Figma'dan tek tek export etmek yerine, iOS'un yerleşik bayrak
/// emojisini (ISO 3166-1 alpha-2 kodundan üretilen) kullanıyorum — lisans/asset yönetimi
/// gerektirmez, hep günceldir, tüm ülkeler için hazır bulunur. Görsel olarak Figma'daki
/// düz vektör bayraklardan farklı (emoji stili), ama işlevsel olarak birebir aynı. Bunu
/// bir tasarım kararı olarak işaretliyorum — istenirse ileride gerçek SVG bayraklarla
/// (bkz. Design System > Kaynak Varlıklar / flag) değiştirilebilir.
struct KasifFlagAnswerOption: View {
    enum State { case normal, correct, wrong }

    /// ISO 3166-1 alpha-2 ülke kodu, örn. "DE" (Almanya), "TR" (Türkiye).
    let countryCode: String
    var state: State = .normal
    var action: (() -> Void)? = nil

    private var borderColor: Color {
        switch state {
        case .normal: KasifColor.borderSubtle
        case .correct: KasifColor.accentSuccessStrong
        case .wrong: KasifColor.accentDanger
        }
    }

    private var borderWidth: CGFloat { state == .wrong ? 3 : 2 }
    private var background: Color { state == .correct ? KasifColor.accentSuccess : .white }

    var body: some View {
        Button {
            action?()
        } label: {
            // Figma'daki gerçek bayrak vektörü 72x48'i uçtan uca dolduruyor. Bayrak
            // emojisi kendi iç boşluğuyla geliyor (dalgalı/3D stil, kutuyu doldurmaz);
            // aynı dolu görünümü almak için emoji kutudan büyük render edilip kırpılıyor.
            Text(Self.flagEmoji(for: countryCode))
                .font(.system(size: 76))
                .frame(width: 72, height: 48)
                .clipped()
                .frame(width: 169, height: 88)
                .background(background, in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }

    static func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var scalarView = String.UnicodeScalarView()
        for scalar in countryCode.uppercased().unicodeScalars {
            if let flagScalar = Unicode.Scalar(base + scalar.value) {
                scalarView.append(flagScalar)
            }
        }
        return String(scalarView)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.md) {
        KasifFlagAnswerOption(countryCode: "DE", state: .normal) {}
        KasifFlagAnswerOption(countryCode: "DE", state: .correct) {}
        KasifFlagAnswerOption(countryCode: "DE", state: .wrong) {}
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
