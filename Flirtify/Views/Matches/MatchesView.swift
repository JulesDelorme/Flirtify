import SwiftUI

private let matchesRelativeTimeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
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
                                title: "No matches yet",
                                subtitle: "Swipe right on people that already liked you.",
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
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadMatches()
        }
    }

    private var topSummaryCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your inbox")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.items.count) active match\(viewModel.items.count > 1 ? "es" : "")")
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
            Text("New matches")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.items.prefix(10))) { item in
                        NavigationLink(destination: destinationBuilder(item.match, item.otherUser)) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.pink.opacity(0.4), Color.blue.opacity(0.45)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 64, height: 64)

                                    Image(systemName: item.otherUser.photoSymbol)
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(.white)
                                }

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
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.blue.opacity(0.14))
                                    .frame(width: 56, height: 56)

                                Image(systemName: item.otherUser.photoSymbol)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(.blue)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.otherUser.headline)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.primary)

                                    Spacer(minLength: 0)

                                    if let lastMessage = item.lastMessage {
                                        Text(matchesRelativeTimeFormatter.localizedString(for: lastMessage.sentAt, relativeTo: .now))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Text(previewText(for: item))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        return "Say hi to start chatting."
    }
}
