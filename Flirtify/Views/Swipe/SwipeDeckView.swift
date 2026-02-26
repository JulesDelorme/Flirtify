import SwiftUI

struct SwipeDeckView: View {
    let viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero
    @State private var isMatchCelebrationVisible = false
    @State private var matchCelebrationDismissTask: Task<Void, Never>?
    @State private var celebrationPulse = false
    @State private var celebrationSpin = false
    @State private var isLikeLimitAlertPresented = false

    var body: some View {
        VStack(spacing: 18) {
            filterSection

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
                    emptyStateCard
                }
            }

            HStack(spacing: 22) {
                swipeActionButton(icon: "xmark", tint: .red) {
                    animateAndSwipe(.left)
                }
                swipeActionButton(
                    icon: "heart.fill",
                    tint: .green,
                    isDisabled: !viewModel.hasLikesRemaining
                ) {
                    animateAndSwipe(.right)
                }
            }

            Text("Likes restants: \(viewModel.likesRemainingToday)/\(viewModel.dailyLikesLimit)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Decouvrir")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            matchCelebrationOverlay
        }
        .onAppear {
            viewModel.loadDeck()
        }
        .onDisappear {
            matchCelebrationDismissTask?.cancel()
        }
        .onChange(of: viewModel.latestMatchUser?.id) { _, newValue in
            guard newValue != nil else {
                withAnimation(.easeOut(duration: 0.2)) {
                    isMatchCelebrationVisible = false
                }
                return
            }
            presentMatchCelebration()
        }
        .onChange(of: viewModel.likeLimitReachedEventCount) { _, _ in
            isLikeLimitAlertPresented = true
        }
        .alert("Limite de likes atteinte", isPresented: $isLikeLimitAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tu as utilise tes 6 likes aujourd'hui. Reviens demain pour continuer.")
        }
    }

    @ViewBuilder
    private var matchCelebrationOverlay: some View {
        if let latestMatchUser = viewModel.latestMatchUser, isMatchCelebrationVisible {
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.64))
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.27, blue: 0.53),
                        Color(red: 0.59, green: 0.16, blue: 0.37),
                        Color(red: 0.72, green: 0.33, blue: 0.16),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.94)
                .ignoresSafeArea()

                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.24), lineWidth: 2)
                        .frame(
                            width: CGFloat(120 + (index * 56)),
                            height: CGFloat(120 + (index * 56))
                        )
                        .scaleEffect(celebrationPulse ? 1.08 : 0.56)
                        .opacity(celebrationPulse ? 0 : 0.44)
                        .animation(
                            .easeOut(duration: 1.45)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.12),
                            value: celebrationPulse
                        )
                }

                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.19))
                            .frame(width: 120, height: 120)

                        Image(systemName: "sparkles")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(celebrationSpin ? 14 : -14))
                            .animation(
                                .easeInOut(duration: 0.82)
                                    .repeatForever(autoreverses: true),
                                value: celebrationSpin
                            )
                    }

                    VStack(spacing: 10) {
                        Text("C'est un match !")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.68)

                        Text("Toi et \(latestMatchUser.firstName) vous vous etes likes.")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                    }

                    Button {
                        dismissMatchCelebration()
                    } label: {
                        Text("Continuer")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 26)
            }
            .zIndex(50)
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.94)),
                    removal: .opacity
                )
            )
            .onAppear {
                celebrationPulse = true
                celebrationSpin = true
            }
            .onDisappear {
                celebrationPulse = false
                celebrationSpin = false
            }
        }
    }

    private func presentMatchCelebration() {
        matchCelebrationDismissTask?.cancel()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            isMatchCelebrationVisible = true
        }

        matchCelebrationDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else {
                return
            }
            dismissMatchCelebration()
        }
    }

    private func dismissMatchCelebration() {
        matchCelebrationDismissTask?.cancel()
        let currentMatchID = viewModel.latestMatchUser?.id

        withAnimation(.easeInOut(duration: 0.24)) {
            isMatchCelebrationVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            if viewModel.latestMatchUser?.id == currentMatchID {
                viewModel.dismissMatchBanner()
            }
        }
    }

    @ViewBuilder
    private var filterSection: some View {
        if viewModel.hasAnyProfiles {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Filtres")
                        .font(.headline)

                    Spacer(minLength: 0)

                    if viewModel.hasActiveFilters {
                        Button("Reinitialiser") {
                            viewModel.resetFilters()
                        }
                        .font(.caption.weight(.semibold))
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Menu {
                            ForEach(MatchSexFilter.allCases) { filter in
                                Button {
                                    viewModel.sexFilter = filter
                                } label: {
                                    HStack {
                                        Text(filter.label)
                                        if viewModel.sexFilter == filter {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            filterChip(
                                title: "Sexe: \(viewModel.sexFilter.label)",
                                isActive: viewModel.sexFilter != .all
                            )
                        }

                        Menu {
                            ForEach(MatchOrientationFilter.allCases) { filter in
                                Button {
                                    viewModel.orientationFilter = filter
                                } label: {
                                    HStack {
                                        Text(filter.label)
                                        if viewModel.orientationFilter == filter {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            filterChip(
                                title: "Orientation: \(viewModel.orientationFilter.label)",
                                isActive: viewModel.orientationFilter != .all
                            )
                        }

                        Button {
                            viewModel.myPreferencesOnly.toggle()
                        } label: {
                            filterChip(
                                title: "Mes preferences",
                                isActive: viewModel.myPreferencesOnly
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.sharedInterestsOnly.toggle()
                        } label: {
                            filterChip(
                                title: "Interets en commun",
                                isActive: viewModel.sharedInterestsOnly
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 1)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 14) {
            if viewModel.hasAnyProfiles, viewModel.hasActiveFilters {
                EmptyStateView(
                    title: "Aucun profil avec ces filtres",
                    subtitle: "Ajuste tes preferences pour relancer le swipe.",
                    symbol: "line.3.horizontal.decrease.circle"
                )
                Button("Reinitialiser les filtres") {
                    viewModel.resetFilters()
                }
                .font(.subheadline.weight(.semibold))
            } else {
                EmptyStateView(
                    title: "Plus de profils",
                    subtitle: "Tu as parcouru tous les profils disponibles.",
                    symbol: "checkmark.seal"
                )
            }
        }
        .frame(height: 460)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func filterChip(title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isActive ? Color.white : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? Color.blue.opacity(0.72) : Color.white.opacity(0.24))
            )
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
                    if viewModel.hasLikesRemaining {
                        animateAndSwipe(.right)
                    } else {
                        viewModel.notifyLikeLimitReached()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            dragOffset = .zero
                        }
                    }
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

        if direction == .right, !viewModel.hasLikesRemaining {
            viewModel.notifyLikeLimitReached()
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

    private func swipeActionButton(
        icon: String,
        tint: Color,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 64, height: 64)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                .opacity(isDisabled ? 0.45 : 1)
        }
        .disabled(isDisabled)
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
