# Geonaut — Apple izni iptal sunucusu (ücretsiz)

Hesap silinince Apple'a "bu uygulamanın Sign in with Apple iznini iptal et" demek için gerekli (App Store kuralı 5.1.1(v)).
Gizli anahtar uygulamaya konulamadığı için bu küçük işlev Netlify'da çalışır.

## Senin yapacakların (sırayla)

1. **Apple anahtarı oluştur** — developer.apple.com → Certificates, IDs & Profiles → **Keys** → `+`
   - Ad: `Geonaut SIWA`, **Sign in with Apple** kutusunu işaretle → Configure → Primary App ID: `com.aspurce.geonaut`.
   - Continue → Register → **Download** (`AuthKey_XXXXXXXXXX.p8`). Bu dosya BİR KEZ indirilir; kaybolursa yenisi gerekir.
   - Sayfadaki **Key ID**'yi (10 harf/rakam) not et.
   - `.p8` dosyasını kimseyle (benimle dahil) paylaşma, git'e koyma.
2. **Netlify'da yeni site** — app.netlify.com → Add new site → **Deploy manually** → bu `revoke-apple-token` klasörünü sürükle-bırak.
   - Site adını `geonaut-revoke` gibi bir şey yap (adres: `https://geonaut-revoke.netlify.app`).
3. **Ortam değişkenleri** — Site configuration → Environment variables → şunları ekle (hepsi "Secret" olarak):
   - `APPLE_TEAM_ID` = `PPAAHJK43N`
   - `APPLE_KEY_ID` = 1. adımdaki Key ID
   - `APPLE_CLIENT_ID` = `com.aspurce.geonaut`
   - `APPLE_PRIVATE_KEY` = `.p8` dosyasını bir metin düzenleyiciyle aç, **tüm içeriği** (`-----BEGIN PRIVATE KEY-----` … `-----END PRIVATE KEY-----`) yapıştır.
4. Değişkenleri ekledikten sonra siteyi **yeniden yayınla** (Deploys → Trigger deploy ya da klasörü tekrar sürükle).
5. Bana şunu yaz: **site adresi** (ör. `https://geonaut-revoke.netlify.app/revoke`). Ben uygulamadaki `AppleTokenRevocation.endpoint` alanına yazıp test ederim.

## Nasıl çalışıyor
Uygulama hesap silerken kullanıcıya Apple ile kısa bir onay gösterir → Apple'dan kısa ömürlü bir kod gelir → bu işleve gönderilir →
işlev kodu gizli anahtarla Apple'a karşılık imzalayıp bir token alır ve o token'ı iptal eder. Sunucu hiçbir kullanıcı verisi saklamaz.
