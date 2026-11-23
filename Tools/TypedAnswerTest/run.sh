#!/bin/zsh
# Yazılı cevap kontrolü testi ("Karışık" bölümleri: bayrak, başkent, dil, lezzet) — Xcode'suz çalışır.
# Kullanım: zsh Tools/TypedAnswerTest/run.sh
cd "$(dirname "$0")"
S=../../Geonaut
sed 's/^import UIKit/import Foundation/' $S/Game/WorldFoods.swift > /tmp/kasif_typed_WorldFoods.swift
swiftc -o /tmp/kasif_typedtest stubs.swift main.swift /tmp/kasif_typed_WorldFoods.swift \
  $S/Game/TypedAnswer.swift $S/Game/Capitals.swift $S/Game/CapitalQuestion.swift $S/Game/CountryFacts.swift \
  $S/Game/CountryCoordinates.swift $S/Game/Countries.swift $S/Game/Tour.swift $S/Game/GameRules.swift \
  $S/Game/Languages.swift $S/Game/FoodFacts.swift $S/Game/MapCountries.swift $S/Localization.swift \
  && /tmp/kasif_typedtest
