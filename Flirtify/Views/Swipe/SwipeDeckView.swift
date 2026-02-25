import SwiftUI

struct SwipeDeckView: View {
    @ObservedObject var viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 18) {
            if let latestMatchUser = viewModel.latestMatchUser {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.pink)
                    Text("C'est un match avec \(latestMatchUser.firstName).")
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 0)
                    Button("Fermer") {
                        viewModel.dismissMatchBanner()
                    }
                    .font(.caption.weight(.semibold))
                }
                .padding(12)
                .background(Color.pink.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            ZStack {
                if viewModel.deck.dropFirst(2).first != nil {
                    DeckBackgroundCardView()
                        .scaleEffect(0.89)
                        .offset(y: 34)
                        .opacity(0.24)
                        .allowsHitTesting(false)
                }

                if viewModel.deck.dropFirst().first != nil {
                    DeckBackgroundCardView()
                        .scaleEffect(0.93 + dragRevealProgress * 0.03)
                        .offset(y: 20 - dragRevealProgress * 10)
                        .opacity(0.5 + dragRevealProgress * 0.22)
                        .allowsHitTesting(false)
                }

                if let profile = viewModel.topProfile {
                    ProfileCardView(profile: profile)
                        .offset(x: dragOffset.width, y: dragOffset.height * 0.3)
                        .rotationEffect(.degrees(Double(dragOffset.width / 18)))
                        .overlay(alignment: .topLeading) {
                            decisionBadge(
                                title: "NON",
                                color: .red,
                                isVisible: dragOffset.width < -60
                            )
                        }
                        .overlay(alignment: .topTrailing) {
                            decisionBadge(
                                title: "J'AIME",
                                color: .green,
                                isVisible: dragOffset.width > 60
                            )
                        }
                        .gesture(cardDragGesture)
                } else {
                    EmptyStateView(
                        title: "Plus de profils",
                        subtitle: "Tu as parcouru tous les profils disponibles.",
                        symbol: "checkmark.seal"
                    )
                    .frame(height: 460)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }

            HStack(spacing: 22) {
                swipeActionButton(icon: "xmark", tint: .red) {
                    animateAndSwipe(.left)
                }
                swipeActionButton(icon: "heart.fill", tint: .green) {
                    animateAndSwipe(.right)
                }
            }
        }
        .padding()
        .navigationTitle("Decouvrir")
        .onAppear {
            viewModel.loadDeck()
        }
    }

    private var dragRevealProgress: CGFloat {
        min(abs(dragOffset.width) / 170, 1)
    }

    private var cardDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 120
                if value.translation.width > threshold {
                    animateAndSwipe(.right)
                } else if value.translation.width < -threshold {
                    animateAndSwipe(.left)
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func animateAndSwipe(_ direction: SwipeDirection) {
        guard viewModel.topProfile != nil else {
            return
        }

        let targetX: CGFloat = direction == .right ? 620 : -620
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(width: targetX, height: 30)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            viewModel.swipeCurrentProfile(direction)
            dragOffset = .zero
        }
    }

    @ViewBuilder
    private func decisionBadge(title: String, color: Color, isVisible: Bool) -> some View {
        if isVisible {
            Text(title)
                .font(.title3.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(color, lineWidth: 2)
                )
                .padding(16)
                .transition(.opacity)
        }
    }

    private func swipeActionButton(icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 64, height: 64)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

private struct DeckBackgroundCardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.17, green: 0.26, blue: 0.44),
                        Color(red: 0.52, green: 0.22, blue: 0.42),
                        Color(red: 0.66, green: 0.38, blue: 0.21),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 6)
            .frame(height: 460)
    }
}
