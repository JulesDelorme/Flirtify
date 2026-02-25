import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let currentUserID: UUID
    let userRepository: UserRepository
    let swipeRepository: SwipeRepository
    let matchRepository: MatchRepository
    let messageRepository: MessageRepository

    init(
        currentUserID: UUID,
        profiles: [UserProfile],
        swipes: [Swipe],
        matches: [Match],
        messages: [Message]
    ) {
        self.currentUserID = currentUserID
        userRepository = UserRepository(profiles: profiles, currentUserID: currentUserID)
        swipeRepository = SwipeRepository(swipes: swipes)
        matchRepository = MatchRepository(matches: matches)
        messageRepository = MessageRepository(messages: messages)
    }

    convenience init() {
        self.init(
            currentUserID: SeedData.currentUserID,
            profiles: SeedData.initialProfiles,
            swipes: SeedData.initialSwipes,
            matches: SeedData.initialMatches,
            messages: SeedData.initialMessages
        )
    }
}
