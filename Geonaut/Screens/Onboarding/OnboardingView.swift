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
    /// Demo girişi (kullanıcı adı + şifre) doğrulanınca çağrılır — bkz. DemoAccess.
    var onDemoLogin: () -> Void = {}

    @State private var showingDemoLogin = false
    @State private var demoUsername = ""
    @State private var demoPassword = ""
    @State private var demoError = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                GeoColor.bgCanvas.ignoresSafeArea()

                OnboardingWaveShape()
                    .fill(GeoColor.accentInfo.opacity(0.55))
                    .frame(width: geo.size.width, height: geo.size.height * 0.142)
                    .ignoresSafeArea(edges: .top)

                Image(systemName: "star.fill")
                    .foregroundStyle(GeoColor.accentPrimarySoft)
                    .font(.system(size: 22))
                    .kasifFloat(dx: 5, dy: 9, duration: 4.2)
                    .position(x: geo.size.width * 0.092, y: geo.size.height * 0.076)
                Image(systemName: "star.fill")
                    .foregroundStyle(GeoColor.accentHighlight)
                    .font(.system(size: 16))
                    .kasifFloat(dx: -6, dy: 7, duration: 3.6, delay: 0.6)
                    .position(x: geo.size.width * 0.718, y: geo.size.height * 0.130)
                Circle()
                    .strokeBorder(GeoColor.accentInfoStrong.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                    .frame(width: 20, height: 20)
                    .kasifFloat(dx: 4, dy: -8, duration: 5, delay: 1.1)
                    .position(x: geo.size.width * 0.836, y: geo.size.height * 0.178)

                VStack(spacing: GeoSpacing.xxxxl) {
                    Spacer()

                    // Kullanıcı kararı: giriş ekranında maskot zıplasın (bkz. GeoBouncingMascot).
                    GeoBouncingMascot(size: 176)

                    VStack(spacing: GeoSpacing.xs) {
                        Text(verbatim: AppBrand.name)
                            .font(GeoTypography.display)
                            .foregroundStyle(GeoColor.textPrimary)
                        Text("Oyna, öğren, dünyayı keşfet!")
                            .font(GeoTypography.bodyBoldL)
                            .foregroundStyle(GeoColor.textSecondary)
                    }
                    .multilineTextAlignment(.center)

                    VStack(spacing: GeoSpacing.md) {
                        GeoSocialButton(provider: .apple, action: onContinueWithApple)
                        Button("Şimdi değil, önce deneyeyim", action: onTryAsGuest)
                            .font(GeoTypography.bodySemibold)
                            .foregroundStyle(GeoColor.textSecondary)
                    }
                    .padding(.horizontal, GeoSpacing.xl)
                    .frame(maxWidth: 520) // iPad'de düğmeler ekran boyunca uzamasın

                    Spacer()
                    Spacer()
                }

                // Kullanıcı kararı: Gizlilik Politikası bağlantısı ekranın EN ALTINDA, diğer
                // düğmelerden ayrı, sakin bir dipnot olarak durur. Yanında App Review/tanıtım için
                // "Demo girişi" (kullanıcı adı + şifre) bağlantısı.
                VStack {
                    Spacer()
                    HStack(spacing: GeoSpacing.xl) {
                        if let privacyURL = LegalLinks.privacyPolicy {
                            Link("Gizlilik Politikası", destination: privacyURL)
                        }
                        Button("Demo girişi") { showingDemoLogin = true }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
                    .padding(.bottom, GeoSpacing.lg)
                }
            }
        }
        .sheet(isPresented: $showingDemoLogin) { demoLoginSheet }
    }

    private var demoLoginSheet: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.lg) {
            Text("Demo girişi")
                .font(GeoTypography.title)
                .foregroundStyle(GeoColor.textPrimary)
            Text("İnceleme ve tanıtım için demo hesabı. Giriş yapınca tüm özellikler açılır.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
            TextField("Kullanıcı adı", text: $demoUsername)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            SecureField("Şifre", text: $demoPassword)
                .textFieldStyle(.roundedBorder)
            if demoError {
                Text("Kullanıcı adı ya da şifre hatalı.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(GeoColor.accentPrimary)
            }
            Button {
                if DemoAccess.isValid(username: demoUsername, password: demoPassword) {
                    demoError = false
                    showingDemoLogin = false
                    onDemoLogin()
                } else {
                    demoError = true
                }
            } label: {
                Text("Giriş yap")
                    .font(.custom(GeoFontName.balooBold, size: 14))
                    .foregroundStyle(.white)
                    .padding(.vertical, GeoSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(GeoColor.accentPrimary, in: Capsule())
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(GeoSpacing.xl)
        .presentationDetents([.medium])
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
