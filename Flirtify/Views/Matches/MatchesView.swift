import SwiftUI

private let matchesRelativeTimeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter
}()

struct MatchesView<Destination: View>: View {
    let viewModel: MatchesViewModel
    let destinationBuilder: (Match, UserProfile) -> Destination

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.2),
                        Color.blue.opacity(0.12),
                        Color.orange.opacity(0.1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        topSummaryCard
                        if viewModel.hasIncomingLikes {
                            incomingLikesSection
                        }
                        if viewModel.hasAnyMatches {
                            filterSection
                        }

                        if viewModel.items.isEmpty {
                            Group {
                                if viewModel.hasAnyMatches {
                                    EmptyStateView(
                                        title: "Aucun resultat",
                                        subtitle: "Ajuste tes filtres pour voir plus de profils.",
                                        symbol: "line.3.horizontal.decrease.circle"
                                    )
                                } else {
                                    EmptyStateView(
                                        title: "Aucun match pour l'instant",
                                        subtitle: "Glisse a droite sur les profils qui t'ont deja aime.",
                                        symbol: "bubble.left.and.bubble.right"
                                    )
                                }
                            }
                            .padding(.top, 30)
                        } else {
                            newMatchesSection
                            conversationsSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Matchs")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadMatches()
        }
    }

    private var topSummaryCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ta messagerie")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.totalMatchesCount) match actif\(viewModel.totalMatchesCount > 1 ? "s" : "")")
                    .font(.title3.weight(.bold))
                if viewModel.hasIncomingLikes {
                    Text("\(viewModel.incomingLikesCount) like\(viewModel.incomingLikesCount > 1 ? "s" : "") en attente")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if viewModel.hasActiveFilters {
                    Text("\(viewModel.items.count) affiche\(viewModel.items.count > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "sparkles")
                .font(.title2.weight(.bold))
                .foregroundStyle(.pink)
                .frame(width: 44, height: 44)
                .background(Color.pink.opacity(0.15))
                .clipShape(Circle())
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var incomingLikesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Qui t'a like")
                    .font(.headline)

                Spacer(minLength: 0)

                Button {
                    viewModel.togglePremiumLikesFeed()
                } label: {
                    Text(viewModel.isPremiumLikesFeedEnabled ? "Premium ON" : "Activer Premium")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.pink.opacity(0.8))
                        )
                }
                .buttonStyle(.plain)
            }

            Text(viewModel.isPremiumLikesFeedEnabled ? "Apercu premium: infos partielles pour proteger la surprise." : "Version gratuite: profils masques. Active premium pour un apercu detaille.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.incomingLikeProfiles.prefix(12))) { profile in
                        incomingLikeCard(profile)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func incomingLikeCard(_ profile: UserProfile) -> some View {
        let premiumEnabled = viewModel.isPremiumLikesFeedEnabled

        return VStack(spacing: 8) {
            ZStack {
                ProfilePhotoView(
                    photoData: profile.primaryPhotoData,
                    fallbackSymbol: profile.photoSymbol,
                    size: 72,
                    backgroundColor: Color.pink.opacity(0.2),
                    symbolColor: .white,
                    strokeColor: Color.white.opacity(0.8)
                )
                .blur(radius: premiumEnabled ? 7 : 16)

                if premiumEnabled {
                    Text(String(profile.firstName.prefix(1)) + ".")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Circle())
                }
            }

            Text(premiumEnabled ? profile.city : "Profil mystere")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            if premiumEnabled {
                Text("\(viewModel.sharedInterestsCount(with: profile)) interets communs")
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.75))
            } else {
                Text("Apercu premium")
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.75))
            }
        }
        .frame(width: 112)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var filterSection: some View {
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

    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nouveaux matchs")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.items.prefix(10))) { item in
                        NavigationLink(destination: destinationBuilder(item.match, item.otherUser)) {
                            VStack(spacing: 8) {
                                ProfilePhotoView(
                                    photoData: item.otherUser.primaryPhotoData,
                                    fallbackSymbol: item.otherUser.photoSymbol,
                                    size: 64,
                                    backgroundColor: Color.pink.opacity(0.25),
                                    symbolColor: .white,
                                    strokeColor: Color.white.opacity(0.85)
                                )

                                Text(item.otherUser.firstName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                            }
                            .frame(width: 82)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conversations")
                .font(.headline)

            LazyVStack(spacing: 10) {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: destinationBuilder(item.match, item.otherUser)) {
                        HStack(spacing: 12) {
                            ProfilePhotoView(
                                photoData: item.otherUser.primaryPhotoData,
                                fallbackSymbol: item.otherUser.photoSymbol,
                                size: 56,
                                backgroundColor: Color.blue.opacity(0.14),
                                symbolColor: .blue,
                                strokeColor: Color.blue.opacity(0.3)
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.otherUser.headline)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.white)

                                    Spacer(minLength: 0)

                                    if let lastMessage = item.lastMessage {
                                        Text(matchesRelativeTimeFormatter.localizedString(for: lastMessage.sentAt, relativeTo: .now))
                                            .font(.caption)
                                            .foregroundStyle(Color.white.opacity(0.72))
                                    }
                                }

                                Text(previewText(for: item))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.88))
                                    .lineLimit(1)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func previewText(for item: MatchListItem) -> String {
        if let lastMessage = item.lastMessage {
            return lastMessage.text
        }
        return "Dis bonjour pour lancer la discussion."
    }
}
