import SwiftUI
import MapKit

/// Gerçek MapKit verisiyle HERHANGİ bir ülkenin konumunu gösterir (bkz.
/// CountryCoordinates.swift) — görsel asset üretimi gerektirmez, bu yüzden yalnızca
/// 17 ülkeyi kapsayan elle-hazırlanmış `CountryMap-<kod>` PNG'lerinin aksine tüm
/// ülkeler için çalışır (bkz. LanguageQuestionView.mapCard'daki öncelik sırası).
/// Statik/etkileşimsiz gösterim — bir quiz kartı içinde kaydırılabilir/yakınlaştırılabilir
/// bir harita olması kafa karıştırırdı, bu yüzden tüm jestler kapalı.
struct KasifLiveCountryMap: View {
    let latitude: Double
    let longitude: Double

    @State private var position: MapCameraPosition

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 14, longitudeDelta: 14)
        )
        _position = State(initialValue: .region(region))
    }

    var body: some View {
        Map(position: $position, interactionModes: []) {
            Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                .tint(KasifColor.accentDanger)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControlVisibility(.hidden)
        .allowsHitTesting(false)
    }
}

#Preview {
    KasifLiveCountryMap(latitude: 52.5200, longitude: 13.4050)
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))
        .padding(KasifSpacing.xxxl)
}
