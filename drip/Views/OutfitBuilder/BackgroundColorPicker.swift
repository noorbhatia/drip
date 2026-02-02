//
//  BackgroundColorPicker.swift
//  drip
//

import SwiftUI

struct BackgroundColorPicker: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 60, maximum: 80))]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedColor)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal)

                // Color grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(Constants.Canvas.backgroundColors.enumerated()), id: \.offset) { _, color in
                        colorSwatch(color)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Background")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func colorSwatch(_ color: Color) -> some View {
        Button {
            withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                selectedColor = color
            }
        } label: {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(
                            colorsMatch(selectedColor, color) ? Color.accentColor : Color(.separator),
                            lineWidth: colorsMatch(selectedColor, color) ? 3 : 1
                        )
                )
                .overlay {
                    if colorsMatch(selectedColor, color) {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(color.adaptedTextColor())
                    }
                }
        }
        .sensoryFeedback(.selection, trigger: selectedColor)
    }

    private func colorsMatch(_ color1: Color, _ color2: Color) -> Bool {
        // Compare colors by converting to UIColor and checking RGB values
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let tolerance: CGFloat = 0.01
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
}

#Preview {
    BackgroundColorPicker(selectedColor: .constant(.white))
}
