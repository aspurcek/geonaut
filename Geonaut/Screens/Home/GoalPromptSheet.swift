import SwiftUI

/// 1.0.4 (kullanıcı kararı 2026-11-16): ilk seviye bitip Ana Sayfa'ya dönülünce, yalnızca bir kez
/// "Günlük hedefini seç" diye sorulur. Hedef herkese aynı başlamasın, oyuncu kendi temposunu seçsin.
/// Sayfa kaydırılıp kapatılırsa seçili tempo (varsayılan Normal) kaydedilir; bir daha sorulmaz.
/// Hatırlatma izni sayfası (ReminderPromptSheet) bundan sonraki dönüşe kalır.
struct GoalPromptSheet: View {
    var daily = DailyEngagement.shared
    var onDone: () -> Void
    @State private var selection = DailyEngagement.shared.today().goal

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            GeoGlyphCircle(symbol: "target", background: GeoColor.accentTertiary, size: 76)
                .kasifWinGlow(color: GeoColor.accentHighlight, size: 150)
                .padding(.top, GeoSpacing.sm)

            VStack(spacing: GeoSpacing.sm) {
                Text("Günlük hedefini seç")
                    .font(.custom(GeoFontName.balooBold, size: 22))
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Her gün kaç doğru cevap hedefleyelim? İstediğin zaman Bugün sayfasından değiştirebilirsin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)

            DailyGoalPicker(selected: selection) { selection = $0 }

            Button {
                daily.setGoal(selection)
                onDone()
            } label: {
                Text("Başla").frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
            .padding(.top, GeoSpacing.sm)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xxl)
        .padding(.bottom, GeoSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.selection, trigger: selection)
        .onDisappear {
            // Kaydırılıp kapatıldıysa da seçili tempo kalır; soru bir daha gelmez.
            if daily.needsGoalChoice { daily.setGoal(selection) }
        }
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) { GoalPromptSheet(onDone: {}) }
}
