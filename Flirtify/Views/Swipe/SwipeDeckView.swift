import SwiftUI

struct SwipeDeckView: View {
    let viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero
    @State private var isMatchIslandVisible = false
    @State private var matchIslandDismissTask: Task<Void, Never>?
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
        .safeAreaInset(edge: .top, spacing: 6) {
            matchIslandOverlay
        }
        .onAppear {
            viewModel.loadDeck()
        }
        .onDisappear {
            matchIslandDismissTask?.cancel()
        }
        .onChange(of: viewModel.latestMatchUser?.id) { _, newValue in
            guard newValue != nil else {
                withAnimation(.easeOut(duration: 0.2)) {
                    isMatchIslandVisible = false
                }
                return
            }
            presentMatchIsland()
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
    private var matchIslandOverlay: some View {
        if let latestMatchUser = viewModel.latestMatchUser, isMatchIslandVisible {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.22))
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.pink)
                        .symbolEffect(.bounce, value: latestMatchUser.id)
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Nouveau match")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.72))
                    Text("Toi + \(latestMatchUser.firstName)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }

                Spacer(minLength: 0)

                Button {
                    dismissMatchIsland()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .frame(width: 22, height: 22)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.84))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.32), Color.pink.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.34), radius: 12, x: 0, y: 8)
            .padding(.horizontal, 30)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .top)
                        .combined(with: .scale(scale: 0.9, anchor: .top))
                        .combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                )
            )
        }
    }

    private func presentMatchIsland() {
        matchIslandDismissTask?.cancel()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            isMatchIslandVisible = true
        }

        matchIslandDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else {
                return
            }
            dismissMatchIsland()
        }
    }

    private func dismissMatchIsland() {
        matchIslandDismissTask?.cancel()
        let currentMatchID = viewModel.latestMatchUser?.id

        withAnimation(.easeInOut(duration: 0.24)) {
            isMatchIslandVisible = false
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
