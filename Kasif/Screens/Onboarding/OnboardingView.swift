import SwiftUI
import AuthenticationServices

/// Figma "Onboarding-Kimlik Doğrulama" / Onboarding (node 51:2) — karşılama ekranı.
/// Sadece Apple ile Devam Et var (ürün kararı: e-posta/Google yok, bkz. proje notları).
///
/// Not — Responsive: Figma 390×844 sabit bir kanvas kullanıyor; buradaki dekoratif
/// gökyüzü dalgası/yıldızlar orantılı (GeometryReader ile yüzde bazlı) yerleştirildi
/// ki farklı iPhone ekran boyutlarında da doğru görünsün. Dekoratif şekiller (dalga,
/// yıldız, noktalı çember) Figma'daki SVG'lerin birebir kopyası yerine native SwiftUI
/// çizimiyle üretildi — küçük dekoratif öğeler için daha sağlam ve her boyutta pürüzsüz
/// ölçekleniyor; maskot gibi karmaşık illüstrasyonlar gerçek asset olarak kaldı.
struct OnboardingView: View {
    var onContinueWithApple: () -> Void
    /// Ürün kararı: giriş yapmadan önce Bayrak Tahmin › Avrupa › Etap 1'i deneyebilme
    /// imkânı — Figma'da bu bağlantı yok, hesap oluşturmadan önceki sürtünmeyi
    /// azaltmak için sonradan eklendi.
    var onTryAsGuest: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                KasifColor.bgCanvas.ignoresSafeArea()

                OnboardingWaveShape()
                    .fill(KasifColor.accentInfo.opacity(0.55))
                    .frame(width: geo.size.width, height: geo.size.height * 0.142)
                    .ignoresSafeArea(edges: .top)

                Image(systemName: "star.fill")
                    .foregroundStyle(KasifColor.accentPrimarySoft)
                    .font(.system(size: 22))
                    .kasifFloat(dx: 5, dy: 9, duration: 4.2)
                    .position(x: geo.size.width * 0.092, y: geo.size.height * 0.076)
                Image(systemName: "star.fill")
                    .foregroundStyle(KasifColor.accentHighlight)
                    .font(.system(size: 16))
                    .kasifFloat(dx: -6, dy: 7, duration: 3.6, delay: 0.6)
                    .position(x: geo.size.width * 0.718, y: geo.size.height * 0.130)
                Circle()
                    .strokeBorder(KasifColor.accentInfoStrong.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                    .frame(width: 20, height: 20)
                    .kasifFloat(dx: 4, dy: -8, duration: 5, delay: 1.1)
                    .position(x: geo.size.width * 0.836, y: geo.size.height * 0.178)

                VStack(spacing: KasifSpacing.xxxxl) {
                    Spacer()

                    // Kullanıcı kararı: giriş ekranında maskot zıplasın (bkz. KasifBouncingMascot).
                    KasifBouncingMascot(size: 176)

                    VStack(spacing: KasifSpacing.xs) {
                        Text(verbatim: AppBrand.name)
                            .font(KasifTypography.display)
                            .foregroundStyle(KasifColor.textPrimary)
                        Text("Oyna, öğren, dünyayı keşfet!")
                            .font(KasifTypography.bodyBoldL)
                            .foregroundStyle(KasifColor.textSecondary)
                    }
                    .multilineTextAlignment(.center)

                    VStack(spacing: KasifSpacing.md) {
                        KasifSocialButton(provider: .apple, action: onContinueWithApple)
                        Button("Şimdi değil, önce deneyeyim", action: onTryAsGuest)
                            .font(KasifTypography.bodySemibold)
                            .foregroundStyle(KasifColor.textSecondary)
                        if let privacyURL = LegalLinks.privacyPolicy {
                            Link("Gizlilik Politikası", destination: privacyURL)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(KasifColor.textMuted)
                        }
                    }
                    .padding(.horizontal, KasifSpacing.xl)

                    Spacer()
                    Spacer()
                }
            }
        }
    }
}

/// Figma'daki gökyüzü şeridinin dalga konturu (bkz. node 51:20), orana göre ölçeklenir.
private struct OnboardingWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x / 390 * w, y: y / 120 * h) }

        var path = Path()
        path.move(to: pt(0, 0))
        path.addLine(to: pt(390, 0))
        path.addLine(to: pt(390, 70))
        path.addCurve(to: pt(195, 60), control1: pt(320, 100), control2: pt(260, 40))
        path.addCurve(to: pt(0, 55), control1: pt(130, 80), control2: pt(70, 30))
        path.addLine(to: pt(0, 0))
        path.closeSubpath()
        return path
    }
}

#Preview {
    OnboardingView(onContinueWithApple: {})
}
