import SwiftUI

private let matchesRelativeTimeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter
}()

struct MatchesView<Destination: View>: View {
    @ObservedObject var viewModel: MatchesViewModel
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

                        if viewModel.items.isEmpty {
                            EmptyStateView(
                                title: "Aucun match pour l'instant",
                                subtitle: "Glisse a droite sur les profils qui t'ont deja aime.",
                                symbol: "bubble.left.and.bubble.right"
                            )
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
                Text("\(viewModel.items.count) match actif\(viewModel.items.count > 1 ? "s" : "")")
                    .font(.title3.weight(.bold))
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
