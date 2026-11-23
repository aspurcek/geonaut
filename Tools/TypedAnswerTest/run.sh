#!/bin/zsh
# Yazılı cevap kontrolü testi (Bayrak "Karışık") — Xcode'suz çalışır.  Kullanım: zsh Tools/TypedAnswerTest/run.sh
cd "$(dirname "$0")"
S=../../Geonaut
swiftc -o /tmp/kasif_typedtest stubs.swift main.swift \
  $S/Game/TypedAnswer.swift $S/Game/Countries.swift $S/Game/Tour.swift $S/Game/GameRules.swift \
  && /tmp/kasif_typedtest
