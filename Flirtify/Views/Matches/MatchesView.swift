import SwiftUI

struct MatchesView<Destination: View>: View {
    @ObservedObject var viewModel: MatchesViewModel
    let destinationBuilder: (Match, UserProfile) -> Destination

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    EmptyStateView(
                        title: "No matches yet",
                        subtitle: "Swipe right on people that already liked you.",
                        symbol: "bubble.left.and.bubble.right"
                    )
                } else {
                    List(viewModel.items) { item in
                        NavigationLink(destination: destinationBuilder(item.match, item.otherUser)) {
                            HStack(spacing: 12) {
                                Image(systemName: item.otherUser.photoSymbol)
                                    .font(.system(size: 26))
                                    .foregroundStyle(.blue)
                                    .frame(width: 42, height: 42)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.otherUser.headline)
                                        .font(.headline)
                                    if let lastMessage = item.lastMessage {
                                        Text(lastMessage.text)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    } else {
                                        Text("Say hi to start chatting.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Matches")
        }
        .onAppear {
            viewModel.loadMatches()
        }
    }
}
