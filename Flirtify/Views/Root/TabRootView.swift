import SwiftUI

struct TabRootView: View {
    private enum Tab: Hashable {
        case swipe
        case preferences
        case events
        case matches
        case profile
    }

    let container: AppContainer

    @State private var selectedTab: Tab = .swipe
    @State private var swipeViewModel: SwipeDeckViewModel
    @State private var eventsViewModel: EventsViewModel
    @State private var matchesViewModel: MatchesViewModel
    @State private var profileViewModel: ProfileViewModel

    init(container: AppContainer) {
        self.container = container
        _swipeViewModel = State(
            initialValue: SwipeDeckViewModel(
                currentUserID: container.currentUserID,
                userRepository: container.userRepository,
                swipeRepository: container.swipeRepository,
                matchRepository: container.matchRepository,
                messageRepository: container.messageRepository
            )
        )
        _matchesViewModel = State(
            initialValue: MatchesViewModel(
                currentUserID: container.currentUserID,
                userRepository: container.userRepository,
                swipeRepository: container.swipeRepository,
                matchRepository: container.matchRepository,
                messageRepository: container.messageRepository
            )
        )
        _eventsViewModel = State(
            initialValue: EventsViewModel(
                currentUserID: container.currentUserID,
                userRepository: container.userRepository,
                swipeRepository: container.swipeRepository,
                matchRepository: container.matchRepository,
                eventRepository: container.eventRepository,
                locationService: container.locationService
            )
        )
        _profileViewModel = State(
            initialValue: ProfileViewModel(
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
                Label("Decouvrir", systemImage: "flame.fill")
            }
            .tag(Tab.swipe)

            NavigationStack {
                PreferenceCategoriesView(viewModel: profileViewModel)
            }
            .tabItem {
                Label("Catégories", systemImage: "square.grid.2x2.fill")
            }
            .tag(Tab.preferences)

            NavigationStack {
                EventsView(viewModel: eventsViewModel)
            }
            .tabItem {
                VStack(spacing: 2) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "mappin.and.ellipse")
                        Image(systemName: "sparkles")
                            .font(.system(size: 8, weight: .bold))
                            .offset(x: 7, y: -5)
                    }
                    Text("Evenements")
                }
            }
            .tag(Tab.events)

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
                Label("Matchs", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(Tab.matches)

            NavigationStack {
                ProfilView(viewModel: profileViewModel)
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
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
        case .preferences:
            profileViewModel.loadProfile()
        case .events:
            eventsViewModel.loadEvents()
        case .matches:
            matchesViewModel.loadMatches()
        case .profile:
            profileViewModel.loadProfile()
        }
    }
}
