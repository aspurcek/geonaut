#if DEBUG
import SwiftUI

/// TikTok/Reels/Shorts için yüzsüz karuseller (pazarlama planı v2, 19 Kasım 2026).
/// Her kare 360×640 çizilir, 3× ölçekle 1080×1920 PNG olarak Documents/carousels/<set>/ altına yazılır.
/// Görsel dil: GeoColor paleti, Baloo yazı, uygulamanın kendi bileşenleri (emoji yalnızca bayraklarda,
/// uygulamada olduğu gibi). Yemek fotoğrafları CC BY: her karede atıf satırı var.
enum PromoCarousels {
    struct FlagQ { let code: String; let options: [String]; let answer: String }
    struct CapitalQ { let code: String; let country: String; let wrong: String; let right: String }
    struct FoodQ { let image: String; let dish: String; let options: [String]; let answer: String; let credit: String }

    static let flags: [FlagQ] = [
        .init(code: "BT", options: ["Nepal", "Butan", "Tibet", "Laos"], answer: "Butan"),
        .init(code: "KG", options: ["Kazakistan", "Özbekistan", "Kırgızistan", "Tacikistan"], answer: "Kırgızistan"),
        .init(code: "LK", options: ["Sri Lanka", "Bangladeş", "Maldivler", "Myanmar"], answer: "Sri Lanka"),
        .init(code: "MN", options: ["Kazakistan", "Moğolistan", "Buryatya", "Türkmenistan"], answer: "Moğolistan"),
        .init(code: "NP", options: ["Butan", "Hindistan", "Nepal", "Pakistan"], answer: "Nepal"),
    ]
    static let capitals: [CapitalQ] = [
        .init(code: "AU", country: "Avustralya", wrong: "Sidney", right: "Canberra"),
        .init(code: "CA", country: "Kanada", wrong: "Toronto", right: "Ottawa"),
        .init(code: "BR", country: "Brezilya", wrong: "Rio de Janeiro", right: "Brasília"),
        .init(code: "CH", country: "İsviçre", wrong: "Zürih", right: "Bern"),
        .init(code: "NZ", country: "Yeni Zelanda", wrong: "Auckland", right: "Wellington"),
    ]
    static let foods: [FoodQ] = [
        .init(image: "Food-CA", dish: "Poutine", options: ["Fransa", "Kanada", "Belçika", "ABD"], answer: "Kanada", credit: "Fotoğraf: jencu · CC BY 2.0"),
        .init(image: "Food-BR", dish: "Feijoada", options: ["Portekiz", "Meksika", "Brezilya", "Küba"], answer: "Brezilya", credit: "Fotoğraf: snowpea&bokchoi · CC BY 2.0"),
        .init(image: "Food-GR", dish: "Musakka", options: ["Yunanistan", "İtalya", "Bulgaristan", "Lübnan"], answer: "Yunanistan", credit: "Fotoğraf: Kullez · CC BY 2.0"),
        .init(image: "Food-MX", dish: "Taco", options: ["İspanya", "Kolombiya", "Arjantin", "Meksika"], answer: "Meksika", credit: "Fotoğraf: ray_explores · CC BY 2.0"),
        .init(image: "Food-IN", dish: "Köri", options: ["Tayland", "Hindistan", "Pakistan", "Endonezya"], answer: "Hindistan", credit: "Fotoğraf: rovingI · CC BY 2.0"),
    ]

    /// Tüm setlerin kareleri: (klasör, dosya adı, görünüm).
    @MainActor static var slides: [(String, String, AnyView)] {
        var out: [(String, String, AnyView)] = []
        // 1) Bayraklar
        out.append(("1-bayraklar", "01", AnyView(HookSlide(kicker: "BAYRAK TESTİ", title: "Bu 5 bayrağı\nbilebilir misin?", subtitle: "Cevaplar son karede. Kaçını bildin, yorumlara yaz!", flags: flags.map(\.code)))))
        for (i, q) in flags.enumerated() {
            out.append(("1-bayraklar", String(format: "%02d", i + 2), AnyView(FlagQuestionSlide(index: i + 1, total: flags.count, q: q))))
        }
        out.append(("1-bayraklar", "07", AnyView(AnswersSlide(title: "Cevaplar", lines: flags.enumerated().map { ($0.offset + 1, flag($0.element.code), $0.element.answer) }, cta: "248 ülkenin bayrağı Geonaut'ta"))))
        // 2) Başkentler
        out.append(("2-baskentler", "01", AnyView(HookSlide(kicker: "BAŞKENT TUZAĞI", title: "Başkenti,\nsandığın şehir değil", subtitle: "Çoğumuz bunlarda yanılıyoruz. Sen kaçını biliyordun?", flags: capitals.map(\.code)))))
        for (i, q) in capitals.enumerated() {
            out.append(("2-baskentler", String(format: "%02d", i + 2), AnyView(CapitalSlide(index: i + 1, total: capitals.count, q: q))))
        }
        out.append(("2-baskentler", "07", AnyView(CTASlide(title: "180 başkenti\nharitada öğren", subtitle: "Bayrak, harita, başkent, dil ve yemek; arkadaşınla düello."))))
        // 3) Yemekler
        out.append(("3-yemekler", "01", AnyView(HookSlide(kicker: "DÜNYA MUTFAĞI", title: "Bu yemekler\nhangi ülkenin?", subtitle: "Cevaplar son karede. Acıktıysan bizi suçlama.", flags: ["CA", "BR", "GR", "MX", "IN"]))))
        for (i, q) in foods.enumerated() {
            out.append(("3-yemekler", String(format: "%02d", i + 2), AnyView(FoodSlide(index: i + 1, total: foods.count, q: q))))
        }
        out.append(("3-yemekler", "07", AnyView(AnswersSlide(title: "Cevaplar", lines: foods.enumerated().map { ($0.offset + 1, flag(code(for: $0.element.answer)), "\($0.element.dish) · \($0.element.answer)") }, cta: "Ülkelerin yemeklerini Geonaut'ta keşfet"))))
        return out
    }

    static func flag(_ code: String) -> String { GeoFlagAnswerOption.flagEmoji(for: code) }
    static func code(for country: String) -> String {
        ["Kanada": "CA", "Brezilya": "BR", "Yunanistan": "GR", "Meksika": "MX", "Hindistan": "IN"][country] ?? "UN"
    }

    /// PNG'leri yazar; yazılan klasörü döner.
    @MainActor static func export() throws -> URL {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("carousels")
        try? FileManager.default.removeItem(at: root)
        for (folder, name, view) in slides {
            let dir = root.appendingPathComponent(folder)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let renderer = ImageRenderer(content: SlideFrame { view }.environment(\.locale, Locale(identifier: "tr_TR")))
            renderer.scale = 3
            if let image = renderer.uiImage, let data = image.pngData() {
                try data.write(to: dir.appendingPathComponent("\(name).png"))
            }
        }
        return root
    }
}

// MARK: - Ortak çerçeve

private struct SlideFrame<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            GeoColor.bgCanvas
            Circle().fill(GeoColor.accentTertiary.opacity(0.55)).frame(width: 360).blur(radius: 70).offset(x: -150, y: 120)
            Circle().fill(GeoColor.accentPrimarySoft.opacity(0.35)).frame(width: 300).blur(radius: 70).offset(x: 160, y: -170)
            Circle().fill(GeoColor.accentHighlight.opacity(0.35)).frame(width: 260).blur(radius: 60).offset(x: 120, y: 300)
            ForEach(0..<6, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat([14, 10, 18, 12, 9, 15][i])))
                    .foregroundStyle(GeoColor.accentHighlight)
                    .position(x: CGFloat([30, 330, 320, 40, 180, 300][i]), y: CGFloat([110, 70, 470, 560, 600, 250][i]))
            }
            content
                .frame(width: 360, height: 640, alignment: .top)
                .clipped()
            // Marka şeridi
            HStack(spacing: 6) {
                Image("MascotBody").resizable().scaledToFit().frame(width: 22, height: 22)
                Text(verbatim: "Geonaut").font(.custom(GeoFontName.balooExtraBold, size: 15)).foregroundStyle(GeoColor.textPrimary)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(GeoColor.bgSurface.opacity(0.9), in: Capsule())
            .position(x: 180, y: 34)
        }
        .frame(width: 360, height: 640)
        .clipped()
    }
}

private struct Kicker: View {
    let text: String
    var color: Color = GeoColor.accentPrimary
    var body: some View {
        Text(text)
            .font(.custom(GeoFontName.balooExtraBold, size: 13))
            .tracking(1.2)
            .foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(color, in: Capsule())
    }
}

private struct Counter: View {
    let index: Int, total: Int
    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...total, id: \.self) { i in
                Capsule().fill(i <= index ? GeoColor.accentPrimary : GeoColor.borderSubtle).frame(width: i == index ? 22 : 10, height: 6)
            }
        }
    }
}

/// Statik cevap şıkkı (Button, görüntüye dönüştürülürken soluk çiziliyordu).
private struct OptionRow: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom(GeoFontName.balooBold, size: 16))
            .foregroundStyle(GeoColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
            .overlay { RoundedRectangle(cornerRadius: GeoRadius.lg).strokeBorder(GeoColor.borderSubtle, lineWidth: 2) }
            .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
    }
}

// MARK: - Kareler

private struct HookSlide: View {
    let kicker: String, title: String, subtitle: String, flags: [String]
    var body: some View {
        VStack(spacing: 18) {
            Spacer().frame(height: 70)
            Kicker(text: kicker)
            Text(title)
                .font(.custom(GeoFontName.balooExtraBold, size: 34))
                .lineSpacing(-8)
                .multilineTextAlignment(.center)
                .foregroundStyle(GeoColor.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            Text(subtitle)
                .font(.custom(GeoFontName.balooBold, size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(GeoColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 30)
            ZStack {
                ForEach(Array(flags.enumerated()), id: \.offset) { i, code in
                    Text(PromoCarousels.flag(code))
                        .font(.system(size: 66))
                        .padding(10)
                        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: 22))
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 6)
                        .rotationEffect(.degrees([-12, 8, -4, 12, -8][i % 5]))
                        .offset(x: CGFloat([-100, 0, 100, -52, 52][i % 5]), y: CGFloat([-40, -64, -40, 52, 52][i % 5]))
                }
            }
            .frame(height: 210)
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                Text("Kaydır").font(.custom(GeoFontName.balooBold, size: 15))
                Image(systemName: "arrow.right").font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(GeoColor.textMuted)
            .padding(.bottom, 40)
        }
    }
}

private struct FlagQuestionSlide: View {
    let index: Int, total: Int, q: PromoCarousels.FlagQ
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 66)
            Counter(index: index, total: total)
            Text("Bu hangi ülkenin bayrağı?")
                .font(.custom(GeoFontName.balooExtraBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
            Text(PromoCarousels.flag(q.code))
                .font(.system(size: 112))
                .frame(height: 140)
                .shadow(color: .black.opacity(0.12), radius: 12, y: 8)
            VStack(spacing: 10) {
                ForEach(q.options, id: \.self) { OptionRow(text: $0) }
            }
            .padding(.horizontal, 28)
            Spacer(minLength: 0)
            Text("Cevabını yorumlara yaz")
                .font(.custom(GeoFontName.balooBold, size: 13))
                .foregroundStyle(GeoColor.textMuted)
                .padding(.bottom, 36)
        }
    }
}

private struct CapitalSlide: View {
    let index: Int, total: Int, q: PromoCarousels.CapitalQ
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 66)
            Counter(index: index, total: total)
            Text(PromoCarousels.flag(q.code)).font(.system(size: 96)).shadow(color: .black.opacity(0.12), radius: 10, y: 6)
            Text(q.country)
                .font(.custom(GeoFontName.balooExtraBold, size: 34))
                .foregroundStyle(GeoColor.textPrimary)
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundStyle(GeoColor.accentDanger)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Çoğu kişinin cevabı").font(.custom(GeoFontName.balooBold, size: 13)).foregroundStyle(GeoColor.textMuted)
                        Text(q.wrong).font(.custom(GeoFontName.balooExtraBold, size: 24)).foregroundStyle(GeoColor.textSecondary).strikethrough(true, color: GeoColor.accentDanger)
                    }
                    Spacer()
                }
                .padding(16)
                .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: 20))
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 22)).foregroundStyle(GeoColor.accentSuccessStrong)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Başkenti").font(.custom(GeoFontName.balooBold, size: 13)).foregroundStyle(GeoColor.accentSuccessText)
                        Text(q.right).font(.custom(GeoFontName.balooExtraBold, size: 30)).foregroundStyle(GeoColor.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "building.columns.fill").font(.system(size: 26)).foregroundStyle(GeoColor.accentHighlightStrong)
                }
                .padding(16)
                .background(GeoColor.accentSuccess.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
                .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(GeoColor.accentSuccessStrong, lineWidth: 2) }
            }
            .padding(.horizontal, 28)
            Spacer()
        }
    }
}

private struct FoodSlide: View {
    let index: Int, total: Int, q: PromoCarousels.FoodQ
    var body: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 66)
            Counter(index: index, total: total)
            Text("\(q.dish) hangi ülkenin?")
                .font(.custom(GeoFontName.balooExtraBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
            Image(q.image)
                .resizable().scaledToFill()
                .frame(width: 304, height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(alignment: .bottomLeading) {
                    Text(q.credit)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(8)
                }
                .shadow(color: .black.opacity(0.15), radius: 12, y: 8)
            VStack(spacing: 9) {
                ForEach(q.options, id: \.self) { OptionRow(text: $0) }
            }
            .padding(.horizontal, 28)
            Spacer()
        }
    }
}

private struct AnswersSlide: View {
    let title: String
    let lines: [(Int, String, String)]
    let cta: String
    var body: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 70)
            Kicker(text: "CEVAPLAR", color: GeoColor.accentSuccessStrong)
            VStack(spacing: 8) {
                ForEach(lines, id: \.0) { n, flag, text in
                    HStack(spacing: 12) {
                        Text(verbatim: "\(n)").font(.custom(GeoFontName.balooExtraBold, size: 18)).foregroundStyle(GeoColor.textMuted).frame(width: 18)
                        Text(flag).font(.system(size: 30))
                        Text(text).font(.custom(GeoFontName.balooExtraBold, size: 18)).foregroundStyle(GeoColor.textPrimary).lineLimit(1).minimumScaleFactor(0.7)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 28)
            Spacer()
            CTABlock(title: cta)
                .padding(.bottom, 40)
        }
    }
}

private struct CTASlide: View {
    let title: String, subtitle: String
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("MascotBody").resizable().scaledToFit().frame(width: 150, height: 150)
            Text(title)
                .font(.custom(GeoFontName.balooExtraBold, size: 36))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .foregroundStyle(GeoColor.textPrimary)
            Text(subtitle)
                .font(.custom(GeoFontName.balooBold, size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(GeoColor.textSecondary)
                .padding(.horizontal, 30)
            StoreBadge().padding(.top, 8)
            Spacer()
        }
    }
}

private struct CTABlock: View {
    let title: String
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image("MascotBody").resizable().scaledToFit().frame(width: 44, height: 44)
                Text(title)
                    .font(.custom(GeoFontName.balooExtraBold, size: 17))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            StoreBadge()
        }
    }
}

private struct StoreBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "apple.logo").font(.system(size: 16, weight: .bold))
            Text("App Store'da · Ücretsiz").font(.custom(GeoFontName.balooExtraBold, size: 16))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20).padding(.vertical, 11)
        .background(GeoColor.textPrimary, in: Capsule())
    }
}

/// `-debugScreen carousels`: tüm karuselleri PNG olarak yazar.
struct CarouselsDebugScreen: View {
    @State private var status = "Yazılıyor…"
    var body: some View {
        Text(status).padding()
            .task {
                do {
                    let url = try PromoCarousels.export()
                    status = "Bitti: \(url.path)"
                    print("CAROUSELS_DONE \(url.path)")
                } catch { status = "Hata: \(error.localizedDescription)" }
            }
    }
}
#endif
