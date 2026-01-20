//
//  FloatingActionButton.swift
//  drip
//

import SwiftUI

struct FloatingActionButton: View {
    @Binding var isMenuExpanded: Bool
    var onAddClothes: () -> Void
    var onBuildOutfit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if isMenuExpanded {
                VStack(spacing: 8) {
                    menuButton(
                        title: Constants.Strings.addClothes,
                        icon: "plus.circle",
                        action: {
                            withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                                isMenuExpanded = false
                            }
                            onAddClothes()
                        }
                    )

                    menuButton(
                        title: Constants.Strings.buildOutfit,
                        icon: "rectangle.stack.badge.plus",
                        action: {
                            withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                                isMenuExpanded = false
                            }
                            onBuildOutfit()
                        }
                    )
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }

            fabButton
        }
    }

    private var fabButton: some View {
        Button {
            withAnimation(.spring(response: Constants.Animation.springResponse, dampingFraction: Constants.Animation.springDamping)) {
                isMenuExpanded.toggle()
            }
        } label: {
            Image(systemName: isMenuExpanded ? "xmark" : "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: Constants.Layout.fabSize, height: Constants.Layout.fabSize)
                .background(.accent)
                .clipShape(Circle())
                .rotationEffect(.degrees(isMenuExpanded ? 45 : 0))
        }
        .glassEffect(.regular.tint(.accentColor).interactive(), in: .circle)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isMenuExpanded)
    }

    private func menuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .sensoryFeedback(.selection, trigger: title)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        VStack {
            Spacer()
            FloatingActionButton(
                isMenuExpanded: .constant(true),
                onAddClothes: {},
                onBuildOutfit: {}
            )
            .padding(.bottom, 40)
        }
    }
}
