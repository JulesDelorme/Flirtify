import Combine
import Foundation

struct MatchListItem: Identifiable {
    let match: Match
    let otherUser: UserProfile
    let lastMessage: Message?

    var id: UUID {
        match.id
    }
}

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published private(set) var items: [MatchListItem] = []

    private let currentUserID: UUID
    private let userRepository: UserRepository
    private let matchRepository: MatchRepository
    private let messageRepository: MessageRepository

    init(
        currentUserID: UUID,
        userRepository: UserRepository,
        matchRepository: MatchRepository,
        messageRepository: MessageRepository
    ) {
        self.currentUserID = currentUserID
        self.userRepository = userRepository
        self.matchRepository = matchRepository
        self.messageRepository = messageRepository
        loadMatches()
    }

    func loadMatches() {
        items = matchRepository.matches(for: currentUserID).compactMap { match in
            guard
                let otherUserID = match.otherUserID(for: currentUserID),
                let otherUser = userRepository.profile(with: otherUserID)
            else {
                return nil
            }

            return MatchListItem(
                match: match,
                otherUser: otherUser,
                lastMessage: messageRepository.lastMessage(for: match.id)
            )
        }
    }
}
