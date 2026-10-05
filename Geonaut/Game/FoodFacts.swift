import Foundation

/// Dünya Yemekleri kategorisinin veri kaynağı — CountryFacts (kıta/dil) gibi tüm 249
/// ülkeyi kapsamıyor; yalnızca gerçek, doğrulanabilir bir "meşhur yemek/tatlı/içecek"
/// bilgisiyle eşleşen ülkeler burada (bkz. WorldFoods.learnableCountries). Kültürel
/// doğruluğu korumak için içecekler kasıtlı olarak alkolsüz seçildi (uygulama çocuklara
/// yönelik) — çoğu ülkenin gerçek "milli içkisi" alkollü olsa da burada çay/kahve/meyve
/// suyu gibi alkolsüz bir alternatif kullanılıyor.
struct FoodFacts {
    let dish: String
    let dessert: String
    let drink: String
    /// Yalnızca kullanıcının Figma'da elle seçip Assets.xcassets'e ekleyeceği 30 ülke
    /// için dolu (bkz. WorldFoods.imageCoveredCodes) — emoji, elle çizilmiş SVG ve stok
    /// fotoğraf aramalarının hepsi sırasıyla "yetersiz"/"benzemiyor"/"yanlış" bulundu.
    /// Diğer 36 ülke Öğren listesinde metin olarak kalıyor, SORULARDA kullanılmıyor
    /// (bkz. WorldFoods.makeQuestions — yalnızca bu 30'dan soru üretiliyor).
    var dishImage: String? = nil
    var dessertImage: String? = nil
    var drinkImage: String? = nil

    func item(for type: FoodType) -> String {
        switch type {
        case .yemek: dish
        case .tatli: dessert
        case .icecek: drink
        }
    }

    func image(for type: FoodType) -> String? {
        switch type {
        case .yemek: dishImage
        case .tatli: dessertImage
        case .icecek: drinkImage
        }
    }
}

/// Bir soruda hangi tür isteneceği — bkz. WorldFoodStructure.style(forStage:).
enum FoodType: CaseIterable {
    case yemek, tatli, icecek

    /// .countryToFood stili için (ülke/bayrak/harita verilir, yemek/tatlı/içecek sorulur).
    var questionPrompt: (flag: String, map: String) {
        switch self {
        case .yemek: ("Bu ülkenin meşhur yemeği hangisi?", "Haritadaki ülkenin meşhur yemeği hangisi?")
        case .tatli: ("Bu ülkenin meşhur tatlısı hangisi?", "Haritadaki ülkenin meşhur tatlısı hangisi?")
        case .icecek: ("Bu ülkenin meşhur içeceği hangisi?", "Haritadaki ülkenin meşhur içeceği hangisi?")
        }
    }

}

enum FoodData {
    static let facts: [String: FoodFacts] = [
        // MARK: Avrupa — görseli olan 6 ülke: TR, IT, FR, DE, ES, GR
        "TR": FoodFacts(dish: "Kebap", dessert: "Baklava", drink: "Ayran", dishImage: "Food-TR", dessertImage: "Dessert-TR", drinkImage: "Drink-TR"),
        "IT": FoodFacts(dish: "Pizza", dessert: "Tiramisu", drink: "Espresso", dishImage: "Food-IT", dessertImage: "Dessert-IT", drinkImage: "Drink-IT"),
        "FR": FoodFacts(dish: "Krep", dessert: "Makaron", drink: "Sıcak Çikolata", dishImage: "Food-FR", dessertImage: "Dessert-FR", drinkImage: "Drink-FR"),
        "DE": FoodFacts(dish: "Bratwurst", dessert: "Streuselkuchen", drink: "Elma Suyu", dishImage: "Food-DE", dessertImage: "Dessert-DE", drinkImage: "Drink-DE"),
        "ES": FoodFacts(dish: "Paella", dessert: "Churros", drink: "Portakal Suyu", dishImage: "Food-ES", dessertImage: "Dessert-ES", drinkImage: "Drink-ES"),
        "GR": FoodFacts(dish: "Musakka", dessert: "Loukoumades", drink: "Frappe", dishImage: "Food-GR", dessertImage: "Dessert-GR", drinkImage: "Drink-GR"),
        "GB": FoodFacts(dish: "Fish and Chips", dessert: "Trifle", drink: "Çay"),
        "PT": FoodFacts(dish: "Bacalhau", dessert: "Pastel de Nata", drink: "Limonata"),
        "RU": FoodFacts(dish: "Borç", dessert: "Blini", drink: "Semaver Çayı"),
        "PL": FoodFacts(dish: "Pierogi", dessert: "Sernik", drink: "Kompot"),
        "CH": FoodFacts(dish: "Fondü", dessert: "Çikolata", drink: "Kahve"),
        "BE": FoodFacts(dish: "Midye-Patates Kızartması", dessert: "Waffle", drink: "Elma Suyu"),

        // MARK: Asya — görseli olan 6 ülke: JP, CN, IN, TH, KR, VN
        "JP": FoodFacts(dish: "Sushi", dessert: "Mochi", drink: "Matcha Çayı", dishImage: "Food-JP", dessertImage: "Dessert-JP", drinkImage: "Drink-JP"),
        "CN": FoodFacts(dish: "Pekin Ördeği", dessert: "Ay Keki", drink: "Çin Çayı", dishImage: "Food-CN", dessertImage: "Dessert-CN", drinkImage: "Drink-CN"),
        "IN": FoodFacts(dish: "Köri", dessert: "Gulab Jamun", drink: "Masala Chai", dishImage: "Food-IN", dessertImage: "Dessert-IN", drinkImage: "Drink-IN"),
        "TH": FoodFacts(dish: "Pad Thai", dessert: "Mangolu Yapışkan Pirinç", drink: "Tayland Çayı", dishImage: "Food-TH", dessertImage: "Dessert-TH", drinkImage: "Drink-TH"),
        "KR": FoodFacts(dish: "Bibimbap", dessert: "Bingsu", drink: "Yeşil Çay", dishImage: "Food-KR", dessertImage: "Dessert-KR", drinkImage: "Drink-KR"),
        "VN": FoodFacts(dish: "Pho", dessert: "Muzlu Kızartma", drink: "Vietnam Kahvesi", dishImage: "Food-VN", dessertImage: "Dessert-VN", drinkImage: "Drink-VN"),
        "ID": FoodFacts(dish: "Nasi Goreng", dessert: "Klepon", drink: "Buzlu Çay"),
        "LB": FoodFacts(dish: "Humus", dessert: "Künefe", drink: "Arap Kahvesi"),
        "SA": FoodFacts(dish: "Kabsa", dessert: "Hurma Tatlısı", drink: "Kahve (Kahwa)"),
        "IL": FoodFacts(dish: "Falafel", dessert: "Halva", drink: "Limonana"),

        // MARK: Afrika — görseli olan 5 ülke: EG, MA, ET, NG, ZA
        "EG": FoodFacts(dish: "Ful Medames", dessert: "Basbousa", drink: "Karkade", dishImage: "Food-EG", dessertImage: "Dessert-EG", drinkImage: "Drink-EG"),
        "MA": FoodFacts(dish: "Kuskus", dessert: "Şebbekiye", drink: "Nane Çayı", dishImage: "Food-MA", dessertImage: "Dessert-MA", drinkImage: "Drink-MA"),
        "ET": FoodFacts(dish: "Injera", dessert: "Himbasha", drink: "Etiyopya Kahvesi", dishImage: "Food-ET", dessertImage: "Dessert-ET", drinkImage: "Drink-ET"),
        "NG": FoodFacts(dish: "Jollof Pilavı", dessert: "Puf Puf", drink: "Zobo", dishImage: "Food-NG", dessertImage: "Dessert-NG", drinkImage: "Drink-NG"),
        "ZA": FoodFacts(dish: "Braai", dessert: "Melktert", drink: "Rooibos Çayı", dishImage: "Food-ZA", dessertImage: "Dessert-ZA", drinkImage: "Drink-ZA"),
        "KE": FoodFacts(dish: "Ugali", dessert: "Mandazi", drink: "Chai"),
        "TN": FoodFacts(dish: "Brik", dessert: "Makroudh", drink: "Nane Çayı"),
        "GH": FoodFacts(dish: "Waakye", dessert: "Kelewele", drink: "Sobolo"),
        "SN": FoodFacts(dish: "Thieboudienne", dessert: "Thiakry", drink: "Bissap"),
        "DZ": FoodFacts(dish: "Kuskus", dessert: "Baklava", drink: "Nane Çayı"),

        // MARK: Kuzey Amerika — görseli olan 5 ülke: US, MX, CA, CU, JM
        "US": FoodFacts(dish: "Hamburger", dessert: "Cheesecake", drink: "Kola", dishImage: "Food-US", dessertImage: "Dessert-US", drinkImage: "Drink-US"),
        "MX": FoodFacts(dish: "Taco", dessert: "Tres Leches Kek", drink: "Horchata", dishImage: "Food-MX", dessertImage: "Dessert-MX", drinkImage: "Drink-MX"),
        "CA": FoodFacts(dish: "Poutine", dessert: "Buttertart", drink: "Kahve", dishImage: "Food-CA", dessertImage: "Dessert-CA", drinkImage: "Drink-CA"),
        "CU": FoodFacts(dish: "Ropa Vieja", dessert: "Flan", drink: "Guarapo", dishImage: "Food-CU", dessertImage: "Dessert-CU", drinkImage: "Drink-CU"),
        "JM": FoodFacts(dish: "Jerk Tavuk", dessert: "Muzlu Tatlı", drink: "Sorrel İçeceği", dishImage: "Food-JM", dessertImage: "Dessert-JM", drinkImage: "Drink-JM"),
        "GT": FoodFacts(dish: "Pepian", dessert: "Rellenitos", drink: "Kahve"),
        "CR": FoodFacts(dish: "Gallo Pinto", dessert: "Churros", drink: "Kahve"),
        "PA": FoodFacts(dish: "Sancocho", dessert: "Raspao", drink: "Chicha"),
        "HT": FoodFacts(dish: "Griot", dessert: "Pain Patate", drink: "Haiti Kahvesi"),

        // MARK: Güney Amerika — görseli olan 5 ülke: BR, AR, PE, CL, CO
        "BR": FoodFacts(dish: "Feijoada", dessert: "Brigadeiro", drink: "Kahve", dishImage: "Food-BR", dessertImage: "Dessert-BR", drinkImage: "Drink-BR"),
        "AR": FoodFacts(dish: "Asado", dessert: "Alfajores", drink: "Mate Çayı", dishImage: "Food-AR", dessertImage: "Dessert-AR", drinkImage: "Drink-AR"),
        "PE": FoodFacts(dish: "Ceviche", dessert: "Suspiro a la Limeña", drink: "Chicha Morada", dishImage: "Food-PE", dessertImage: "Dessert-PE", drinkImage: "Drink-PE"),
        "CL": FoodFacts(dish: "Empanada", dessert: "Kuchen", drink: "Mote con Huesillo", dishImage: "Food-CL", dessertImage: "Dessert-CL", drinkImage: "Drink-CL"),
        "CO": FoodFacts(dish: "Bandeja Paisa", dessert: "Arequipe", drink: "Kolombiya Kahvesi", dishImage: "Food-CO", dessertImage: "Dessert-CO", drinkImage: "Drink-CO"),
        "VE": FoodFacts(dish: "Arepa", dessert: "Quesillo", drink: "Papelón con Limón"),
        "EC": FoodFacts(dish: "Locro de Papa", dessert: "Higos con Queso", drink: "Kahve"),
        "BO": FoodFacts(dish: "Salteña", dessert: "Helado de Canela", drink: "Api Morado"),
        "UY": FoodFacts(dish: "Chivito", dessert: "Postre Chajá", drink: "Mate Çayı"),
        "PY": FoodFacts(dish: "Sopa Paraguaya", dessert: "Dulce de Leche", drink: "Tereré"),

        // MARK: Okyanusya — görseli olan 3 ülke: AU, NZ, FJ
        "AU": FoodFacts(dish: "Meat Pie", dessert: "Lamington", drink: "Kahve", dishImage: "Food-AU", dessertImage: "Dessert-AU", drinkImage: "Drink-AU"),
        "NZ": FoodFacts(dish: "Hangi", dessert: "Pavlova", drink: "Çay", dishImage: "Food-NZ", dessertImage: "Dessert-NZ", drinkImage: "Drink-NZ"),
        "FJ": FoodFacts(dish: "Kokoda", dessert: "Vakalolo", drink: "Hindistan Cevizi Suyu", dishImage: "Food-FJ", dessertImage: "Dessert-FJ", drinkImage: "Drink-FJ"),
        "PG": FoodFacts(dish: "Mumu", dessert: "Muzlu Tatlı", drink: "Kava"),
        "WS": FoodFacts(dish: "Palusami", dessert: "Panipopo", drink: "Kava"),
        "TO": FoodFacts(dish: "Lu Pulu", dessert: "Faikakai", drink: "Otai"),
        "VU": FoodFacts(dish: "Laplap", dessert: "Muzlu Tatlı", drink: "Kava"),

        // MARK: Antarktika / kutup bölgeleri — bkz. CountryFacts'teki aynı not: kalıcı
        // nüfus yok, burada idari bağlantıya göre şakacı bir eşleştirme yapıldı. 30'luk
        // görsel kümesinde yok (bkz. WorldFoods.pool'daki "boşsa 30'a düş" kuralı).
        "AQ": FoodFacts(dish: "Balık Çorbası", dessert: "Sıcak Çikolatalı Kek", drink: "Sıcak Çikolata"),
        "BV": FoodFacts(dish: "Somon", dessert: "Krumkake", drink: "Kakao"),
        "HM": FoodFacts(dish: "Meat Pie", dessert: "Lamington", drink: "Kakao"),
        "TF": FoodFacts(dish: "Krep", dessert: "Makaron", drink: "Sıcak Çikolata")
    ]
}
