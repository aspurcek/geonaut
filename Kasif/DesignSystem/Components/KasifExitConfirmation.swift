import SwiftUI

/// Seviye yarıdayken çıkış onayı — kullanıcı kararı: kullanıcı bir seviyeden çıkabilmeli.
/// Çıkış kuralları (bkz. Notion "Seviyeden çıkış kuralları"):
/// - Çıkış ücretsiz, mevcut puanlar ve seri korunur.
/// - O seviyede kazanılan puan ve ilerleme yalnızca seviye TAMAMLANINCA eklenir; yarıda çıkınca eklenmez.
/// - "Puanla Devam Et" ile harcanan puan iade edilmez.
/// - Canlar her seviye girişinde yeniden 5'tir; tekrar girince seviye baştan başlar.
/// - Hiç soru cevaplanmadıysa (ilk sorudaysa) onay sorulmadan çıkılır.
struct KasifExitConfirmation: ViewModifier {
    @Binding var isPresented: Bool
    var onExit: () -> Void

    func body(content: Content) -> some View {
        content.alert("Seviyeden çıkmak istiyor musun?", isPresented: $isPresented) {
            Button("Devam Et", role: .cancel) {}
            Button("Çık", role: .destructive, action: onExit)
        } message: {
            Text("Bu seviyede kazandığın puanlar ve ilerleme kaydedilmez. Mevcut puanların ve serin korunur.")
        }
    }
}

extension View {
    func exitConfirmation(isPresented: Binding<Bool>, onExit: @escaping () -> Void) -> some View {
        modifier(KasifExitConfirmation(isPresented: isPresented, onExit: onExit))
    }
}
