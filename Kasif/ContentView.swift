//
//  ContentView.swift
//  Kasif
//
//  Created by Aspurçe on 10.09.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Text("Kaşif")
                .font(KasifTypography.display)
                .foregroundStyle(KasifColor.textPrimary)
            Button("Başlayalım") {}.buttonStyle(.kasifPrimary)
            Button("Başlayalım") {}.buttonStyle(.kasifPrimary).disabled(true)
            Button("Başlayalım") {}.buttonStyle(.kasifSecondary)
            Button("Başlayalım") {}.buttonStyle(.kasifSecondary).disabled(true)
        }
        .padding(KasifSpacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    ContentView()
}
