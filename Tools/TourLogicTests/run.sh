#!/bin/zsh
# Tur sistemi (kilitler, kupa, anahtarlar, soru penceresi) mantık testi — Xcode'suz çalışır.
# Kullanım:  zsh Tools/TourLogicTests/run.sh
cd "$(dirname "$0")"
S=../../Geonaut
swiftc -o /tmp/kasif_tourtests stubs.swift main.swift \
  "$S/Game/GameProgress.swift" "$S/Game/Streak.swift" "$S/Game/Tour.swift" "$S/Game/GameRules.swift" \
  "$S/Game/ContinentPath.swift" "$S/Game/Countries.swift" "$S/Game/AvatarOptions.swift" "$S/Persistence/PlayerProfile.swift" "$S/DesignSystem/Tokens/GeoColor.swift" && /tmp/kasif_tourtests
