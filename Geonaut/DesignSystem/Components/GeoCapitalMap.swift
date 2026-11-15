import SwiftUI
import MapKit

/// Başkentler alt sayfasındaki harita (kullanıcı: "başkentler nasıl" — Lezzetler'deki fotoğrafın
/// karşılığı): ülke ortası ile açılır, başkent adresi Apple Haritalar'da bulununca o şehre kayar ve
/// altın renkli bir başkent iğnesi gösterir. İnternet yoksa/bulunamazsa ülke haritası kalır (iğnesiz).
/// Yalnızca şehir + ülke adı sorgulanır; kullanıcıya ait hiçbir veri gönderilmez.
struct GeoCapitalMap: View {
    let countryCode: String
    let countryName: String
    let capital: String

    @State private var position: MapCameraPosition
    @State private var pin: CLLocationCoordinate2D?

    init(countryCode: String, countryName: String, capital: String) {
        self.countryCode = countryCode
        self.countryName = countryName
        self.capital = capital
        if let c = CountryCoordinates.coordinate(for: countryCode) {
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: c.lat, longitude: c.lon),
                span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12)
            )))
        } else {
            _position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        Map(position: $position, interactionModes: []) {
            if let pin {
                Annotation(D(capital), coordinate: pin, anchor: .bottom) {
                    VStack(spacing: -2) {
                        GeoGlyphCircle(symbol: "building.columns.fill", background: GeoColor.accentHighlight, size: 32)
                            .overlay { Circle().strokeBorder(.white, lineWidth: 2.5) }
                            .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                    }
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControlVisibility(.hidden)
        .allowsHitTesting(false)
        .task(id: countryCode) { await locateCapital() }
    }

    private func locateCapital() async {
        let center = CountryCoordinates.coordinate(for: countryCode)
        let geocoder = CLGeocoder()
        let query = "\(capital), \(countryName)"
        guard let placemarks = try? await geocoder.geocodeAddressString(query, in: nil, preferredLocale: Locale(identifier: "tr_TR")),
              let location = placemarks.first?.location else { return }
        // Yanlış eşleşmeye karşı: ülke ortasından çok uzaktaysa (ör. aynı adlı başka şehir) iğne koyma.
        if let center {
            let distance = location.distance(from: CLLocation(latitude: center.lat, longitude: center.lon))
            guard distance < 2_500_000 else { return }
        }
        withAnimation(.easeInOut(duration: 0.8)) {
            pin = location.coordinate
            position = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9)
            ))
        }
    }
}
