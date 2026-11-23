#!/bin/zsh
# Aynı testte soru tekrarı kontrolü: tüm kategori/tur/seviyeler için ~21.000 test üretip
# aynı ülkenin iki kez sorulup sorulmadığını ve her testte 10 soru çıktığını sayar.
# Kullanım:  zsh Tools/QuestionDuplicateTest/run.sh
cd "$(dirname "$0")"
S=../../Geonaut
sed 's/^import UIKit/import Foundation/' $S/Game/WorldFoods.swift > /tmp/kasif_WorldFoods.swift
swiftc -o /tmp/kasif_duptest stubs.swift main.swift /tmp/kasif_WorldFoods.swift \
  $S/Game/Countries.swift $S/Game/TypedAnswer.swift $S/Game/Capitals.swift $S/Game/CapitalQuestion.swift $S/Game/Languages.swift $S/Game/GameRules.swift $S/Game/ContinentPath.swift \
  $S/Game/Tour.swift $S/Game/FoodFacts.swift $S/Game/CountryFacts.swift $S/Game/CountryCoordinates.swift \
  $S/Game/MapCountries.swift $S/Game/MapQuizQuestion.swift $S/Game/CountryQuizQuestion.swift $S/Game/GameProgress.swift \
  && /tmp/kasif_duptest
