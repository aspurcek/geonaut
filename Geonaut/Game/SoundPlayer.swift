import AVFoundation

/// Uygulamadaki tek ses katmanı: yalnızca doğru cevap, yanlış cevap ve başarı (ünvan/rozet/kupa
/// tebrik ekranı) için kısa efektler. Sesler bu projeye özel sentezlenmiş özgün dosyalardır
/// (Sounds/), telif sorunu yoktur. Ayarlar > "Ses efektleri" kapalıysa hiçbir ses çalmaz.
enum SoundEffect: String, CaseIterable {
    case correct, wrong, success
}

enum SoundPlayer {
    static let enabledDefaultsKey = "soundEffectsEnabled"

    /// Varsayılan AÇIK: anahtar hiç yazılmadıysa ses çalar.
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: enabledDefaultsKey) as? Bool ?? true
    }

    private static var players: [SoundEffect: AVAudioPlayer] = [:]
    private static var sessionConfigured = false

    static func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        configureSessionIfNeeded()
        guard let player = player(for: effect) else { return }
        player.currentTime = 0
        player.play()
    }

    /// `.ambient`: telefon sessizdeyken çalmaz, kullanıcının müziğini/podcast'ini bölmez.
    private static func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private static func player(for effect: SoundEffect) -> AVAudioPlayer? {
        if let cached = players[effect] { return cached }
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        players[effect] = player
        return player
    }
}
