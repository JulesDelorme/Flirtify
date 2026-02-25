import SwiftUI

struct TabRootView: View {
    private enum Tab: Hashable {
        case swipe
        case matches
        case profile
    }

    let container: AppContainer

    @State private var selectedTab: Tab = .swipe
    @StateObject private var swipeViewModel: SwipeDeckViewModel
    @StateObject private var matchesViewModel: MatchesViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init(container: AppContainer) {
        self.container = container
        _swipeViewModel = StateObject(
            wrappedValue: SwipeDeckViewModel(
                currentUserID: container.currentUserID,
                userRepository: container.userRepository,
                swipeRepository: container.swipeRepository,
                matchRepository: container.matchRepository,
                messageRepository: container.messageRepository
            )
        )
        _matchesViewModel = StateObject(
            wrappedValue: MatchesViewModel(
                currentUserID: container.currentUserID,
                userRepository: container.userRepository,
                matchRepository: container.matchRepository,
                messageRepository: container.messageRepository
            )
        )
        _profileViewModel = StateObject(
            wrappedValue: ProfileViewModel(
                userRepository: container.userRepository
            )
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SwipeDeckView(viewModel: swipeViewModel)
            }
            .tabItem {
                Label("Swipe", systemImage: "flame.fill")
            }
            .tag(Tab.swipe)

            MatchesView(viewModel: matchesViewModel) { match, otherUser in
                ChatView(
                    viewModel: ChatViewModel(
                        match: match,
                        otherUser: otherUser,
                        currentUserID: container.currentUserID,
                        messageRepository: container.messageRepository
                    )
                )
            }
            .tabItem {
                Label("Matches", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(Tab.matches)

            NavigationStack {
                ProfilView(viewModel: profileViewModel)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(Tab.profile)
        }
        .onAppear {
            refreshTabContent(for: selectedTab)
        }
        .onChange(of: selectedTab) { _, newValue in
            refreshTabContent(for: newValue)
        }
    }

    private func refreshTabContent(for tab: Tab) {
        switch tab {
        case .swipe:
            swipeViewModel.loadDeck()
        case .matches:
            matchesViewModel.loadMatches()
        case .profile:
            profileViewModel.loadProfile()
        }
    }
}
