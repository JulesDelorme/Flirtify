import Combine
import Foundation

@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var deck: [UserProfile] = []
    @Published var latestMatchUser: UserProfile?

    private let currentUserID: UUID
    private let userRepository: UserRepository
    private let swipeRepository: SwipeRepository
    private let matchRepository: MatchRepository
    private let messageRepository: MessageRepository

    init(
        currentUserID: UUID,
        userRepository: UserRepository,
        swipeRepository: SwipeRepository,
        matchRepository: MatchRepository,
        messageRepository: MessageRepository
    ) {
        self.currentUserID = currentUserID
        self.userRepository = userRepository
        self.swipeRepository = swipeRepository
        self.matchRepository = matchRepository
        self.messageRepository = messageRepository
        loadDeck()
    }

    var topProfile: UserProfile? {
        deck.first
    }

    func loadDeck() {
        let swipedIDs = swipeRepository.swipedProfileIDs(for: currentUserID)
        let matchedIDs = matchRepository.matchedUserIDs(for: currentUserID)
        deck = userRepository.candidateProfiles(
            excluding: swipedIDs,
            matchedUserIDs: matchedIDs
        )
    }

    func swipeLeft() {
        swipeCurrentProfile(.left)
    }

    func swipeRight() {
        swipeCurrentProfile(.right)
    }

    func swipeCurrentProfile(_ direction: SwipeDirection) {
        guard let profile = topProfile else {
            return
        }

        _ = swipeRepository.recordSwipe(
            from: currentUserID,
            to: profile.id,
            direction: direction
        )

        if direction == .right, profile.likedUserIDs.contains(currentUserID) {
            let existingMatch = matchRepository.findMatch(
                between: currentUserID,
                and: profile.id
            )
            let match = matchRepository.createMatch(
                between: currentUserID,
                and: profile.id
            )

            if existingMatch == nil {
                latestMatchUser = profile
                _ = messageRepository.sendMessage(
                    matchID: match.id,
                    senderID: profile.id,
                    text: "Salut \(userRepository.currentUser()?.firstName ?? "toi"), contente qu'on ait matché."
                )
            }
        }

        loadDeck()
    }

    func dismissMatchBanner() {
        latestMatchUser = nil
    }
}
