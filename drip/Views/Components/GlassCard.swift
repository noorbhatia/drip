//
//  GlassCard.swift
//  drip
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
            .glassEffect(.regular, in: .rect(cornerRadius: Constants.Layout.cardCornerRadius))
    }
}

#Preview {
    GlassCard {
        VStack {
            Text("Sample Card")
            Text("With some content")
        }
        .padding()
    }
    .padding()
}
