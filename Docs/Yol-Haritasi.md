# Geonaut yol haritası (10 Kasım 2026 →)

Durum: 1.0.1 yayında (4 Kasım'daki 1.0'ın güncellemesi). AB (27 ülke) DSA onayı bekliyor, 148 ülkede satışta. Kod GitHub'da (private), karar günlüğü Notion'da. Aşağıdaki tarihler hedef, kesin söz değil; her pazartesi ölçümle güncellenir.

## Ana hedef (ilk 90 gün)
1. **Kalıcı oyuncu kazanmak:** 1.000 toplam indirme, 1. gün geri dönüş %30+, 7. gün %10+, puan 4,5+ (en az 25 puan).
2. **Bulunabilirlik:** mağaza aramalarında ve Google'da çıkmak (ASO + tanıtım sitesi).
3. **Para:** eşikler sağlanınca reklam (ilk biçim: can yenileme için ödüllü reklam).

## Faz 0 — Bu hafta (10–16 Kasım): yayın sonrası + 1.0.2
| İş | Kim | Not |
|---|---|---|
| 1.0.1'i ilk 3 gün izle: çökme, yorum, App Store Connect → Analytics | Sen (ben okumana yardım) | Çökme %1 altı olmalı |
| **1.0.2**: etap başı bilgi kartları (4 kategori), Puan/Seri/Öğrenilen Ülke bilgi sayfaları, kilitli alan sayfaları | Ben yazdım (feature/info-cards dalı), **sen simülatörde test et** | Test bitince build 10, incelemeye sen gönder |
| TikTok hesabını aç + ilk 5 video | Sen hesap, ben metin/fikir (Docs/ASO-ve-TikTok-Plani.md) | 3-5 video/hafta |
| Alan adı al (örn. geonaut.app) | Sen | Siteyi ben hazırlarım |
| DSA durumunu kontrol et (Business → Compliance) | Sen | Onaylanınca AB'de otomatik açılır |
| Figma: Ayarlar/Öğren/Rozetler çerçevelerini güncelle, bilgi kartı/bilgi sayfası tasarımlarını ekle | Ben | |

## Faz 1 — 17 Kasım–14 Aralık: bulunabilirlik + geri dönüş
| İş | Kim |
|---|---|
| 1.0.2 yayında → ilk hafta ölçüm (bilgi kartları geri dönüşü artırdı mı?) | İkimiz |
| **ASO yenilemesi** (ad/alt başlık/anahtar kelime EN+TR, ES eklenir; DE AB açılınca) | Ben hazırlar, yeni sürümle girilir |
| **Tanıtım sitesi** (tek sayfa, App Store butonu, gizlilik bağlantısı) + `app-ads.txt` yeri | Ben |
| **Günlük Soru** (her gün tek kısa soru, seriyi besler) | Ben (tasarım → onay → kod) |
| Yorum isteme (ilk seviyeden sonra uygun an, Apple'ın kendi penceresi) | Ben |
| TikTok/Reels/Shorts: haftada 3-5 video; hangileri indirme getiriyor ölç (kampanya bağlantısı) | Sen (çekim), ben fikir |
| Haftalık ölçüm tablosu (Notion) | Ben kurarım, sen pazartesi rakamları söylersin |

**Faz 1 çıkış ölçütü:** 500+ toplam indirme, puan 4,3+ (en az 10 puan), 7. gün geri dönüş verisi görünür.

## Faz 2 — 15 Aralık–Ocak: reklama hazırlık ve ilk reklam
Reklam yalnızca **hepsi** sağlanınca açılır:
- AB'de DSA onaylı (reklam onay penceresi şart),
- 1.000+ toplam indirme ve haftalık 150+ indirme 4 hafta üst üste,
- puan 4,5+ (25+ puan), 7. gün geri dönüş %10+,
- AdMob hesabı, alan adı ve `app-ads.txt` hazır.

Hazırlık (reklam açılmadan yapılır): AdMob hesabı + ödeme profili (sen), reklam ekranı tasarımı (can bitince "reklam izle"), AB onay mesajı (AdMob), App Privacy güncelleme taslağı. Bkz. Docs/Reklam-Hazirlik.md.
İlk biçim: **ödüllü reklam** (can yenileme). Banner yok, tam ekran reklam ya hiç ya da çok seyrek. Soru ortasında reklam yok.
Reklam sonrası koruma: 2 hafta içinde geri dönüş %10'dan fazla düşerse ya da puan 4,3'ün altına inerse reklam azaltılır.

## Faz 3 — Şubat ve sonrası: büyüme
- Yeni içerik: **Ünlü Yapılar**, **Para Birimleri** (kategori zinciri uzar), yeni rozetler.
- **Ana ekran widget'ı** (günlük seri).
- Apple Search Ads küçük bütçeyle deneme (ASO verisi oturunca).
- Yerelleştirilmiş videolar (ES, AB açılınca DE) ve mağaza dilleri.
- Arkadaşla yarış / paylaşım (yalnızca gizlilik taahhüdümüze uyuyorsa; sunucu gerektiriyor mu önce değerlendir).

## Ölçüm ve alışkanlıklar
- **Her pazartesi 5 dk:** App Store Connect → Analytics: indirme, sayfa görüntüleme, dönüşüm, geri dönüş, çökme, puan. Notion'a tek satır.
- **Her sürüm:** önce Figma, sonra kod, simülatörde test, Release derlemesi + testler, sonra yükleme.
- **Her büyük karar:** Notion karar günlüğüne ve hafızaya yazılır.
- **Yedek:** her sürüm sonrası `git bundle` + GitHub push (yeni token ile; token'ı yalnızca terminalde gir).

## Riskler
| Risk | Önlem |
|---|---|
| AB onayı gecikir | AB dışı pazarlara odaklan; Apple'a durum sor |
| İndirme düşük kalır | ASO + içerik üretimi, TikTok denemeleri; reklamı erkene çekme |
| Reklam geri dönüşü bozar | Yalnızca ödüllü, ölçümle sınırla |
| Çökme/hata | TestFlight, Release testleri, ilk günlerde izleme |
| Gizlilik sapması | Yeni SDK eklemeden önce politika + App Privacy güncellemesi |

## Hemen şimdi
1. 1.0.2'yi simülatörde dene (kart akışı, kilit ve bilgi sayfaları) → "onay" ya da değişiklik.
2. TikTok hesabı + alan adı.
3. DSA durumunu kontrol et.
