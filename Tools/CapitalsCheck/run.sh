#!/bin/zsh
# Başkentler soru üretimi tutarlılık testi — Xcode'suz çalışır.  Kullanım: zsh Tools/CapitalsCheck/run.sh
cd "$(dirname "$0")"
S=../../Geonaut
# LanguageQuestion yapısı Languages.swift'ten (başka bağımlılıkları yüzünden tüm dosya derlenmez) çıkarılır.
sed -n '/^struct LanguageQuestion {/,/^}/p' $S/Game/Languages.swift > /tmp/kasif_lq.swift
swiftc -o /tmp/kasif_capcheck stubs.swift /tmp/kasif_lq.swift main.swift \
  "$S/Game/Capitals.swift" "$S/Game/Countries.swift" "$S/Game/CountryCoordinates.swift" "$S/Game/Tour.swift" "$S/Game/GameRules.swift" \
  "$S/Game/ContinentPath.swift" "$S/Game/GameProgress.swift" "$S/Game/Streak.swift" "$S/Game/AvatarOptions.swift" "$S/Persistence/PlayerProfile.swift" "$S/DesignSystem/Tokens/GeoColor.swift" \
  && /tmp/kasif_capcheck
