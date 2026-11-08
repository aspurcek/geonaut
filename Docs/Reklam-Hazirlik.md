# Reklam hazırlığı (reklamlar sonraki sürümde kodlanacak)

Durum (9 Kasım 2026): Gizlilik politikası "Geonaut'ta reklam gösterilebilir" diyecek şekilde güncellendi (TR/EN/DE/ES, "Reklamlar" bölümü). Uygulamada henüz reklam kodu YOK; build 8 reklamsız.

## 1) App Store Connect → App Privacy
- **1.0.1 (reklamsız build) için cevaplar değişmez:** "Veri toplanmıyor". Reklamsız build'de veri toplama beyan etmek yanlış olur ve mağazada gereksiz "sizi izleyen veriler" etiketi çıkarır.
- **Reklamlı sürümü göndermeden önce** (build yüklenmeden, App Privacy sayfası inceleme gerektirmeden güncellenir) şunları ekle. Hepsi "Third-Party Advertising" amacıyla, kullanıcıya bağlı DEĞİL:
  - Identifiers → **Device ID** (reklam kimliği IDFA) — izleme için kullanılıyor: **Evet** (kişiselleştirilmiş reklam varsa)
  - Usage Data → **Advertising Data** ve **Product Interaction**
  - Location → **Coarse Location** (IP'den)
  - Diagnostics → **Performance Data / Crash Data** (AdMob SDK'sı toplar)
- "Tracking" evet olduğu için uygulamada **ATT izin penceresi** şart (aşağıda).

## 2) Reklamlı sürümde kodda yapılacaklar
1. Swift Package: `GoogleMobileAds` (içinde UMP: User Messaging Platform da var).
2. Info.plist: `GADApplicationIdentifier` (AdMob uygulama kimliği), `NSUserTrackingUsageDescription` (TR/EN/DE/ES), `SKAdNetworkItems` (Google'ın güncel listesi).
3. Açılışta sırayla: **UMP onay formu (AEA/UK/TR)** → ATT penceresi → `MobileAds.start()`.
4. Çocuk ayarları: `tagForChildDirectedTreatment = false`, `maxAdContentRating = "PG"` (AdMob panelinden de "G/PG" sınırla). Uygulama çocuklara yönelik DEĞİL (bkz. standing karar).
5. Yerleşim kararı bekliyor (öneri: ödüllü reklamla can yenileme + seviye sonunda sınırlı geçiş reklamı; soru sırasında asla). Yeni UI → önce Figma, sonra kod.
6. PrivacyInfo.xcprivacy: Tracking = true, tracking domain'leri, toplanan veri tipleri (Device ID, Advertising Data, Coarse Location, Product Interaction).
7. Reklam gösterilmeyecek durumlar: misafir/demo modu (App Review demo hesabı) dahil mi hariç mi — karar ver; App Review'da test reklamı görünmesi sorun değil.

## 3) Senin yapacakların (ben hesap açamam)
1. **AdMob hesabı:** admob.google.com → Apple Kimliği değil Google hesabıyla giriş; ödeme profili + vergi bilgileri (ödeme alabilmek için).
2. AdMob'da **iOS uygulaması ekle** (Geonaut, App Store ID 6819617535), **reklam birimleri** oluştur (Rewarded, Interstitial) ve bana **Uygulama kimliği + birim kimliklerini** ver.
3. AdMob → Gizlilik ve mesajlaşma: **GDPR mesajı** oluştur ve yayınla (UMP formu buradan gelir).
4. **app-ads.txt:** App Store'daki "Geliştirici web sitesi" alan adının kökünde `app-ads.txt` yayınlanmalı (AdMob satırını panel verir). Web sitesi yoksa gerekirse basit bir sayfa açarız.
5. App Store Connect → **Business → Agreements:** Ücretsiz uygulama + AdMob reklamı için Paid Apps Agreement gerekmez (uygulama içi satın alma yok). Ayrıca DSA satıcı beyanı AB için zaten gerekli.

## 4) Yaş derecelendirmesi
Reklamlı sürümde App Store Connect yaş derecelendirme anketini yeniden doldur; AdMob içerik filtresi "G/PG" olduğu için derecelendirme değişmemeli (hâlâ 4+ ya da mevcut).
