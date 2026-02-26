import Foundation
import Observation

struct MatchListItem: Identifiable {
    let match: Match
    let otherUser: UserProfile
    let lastMessage: Message?

    var id: UUID {
        match.id
    }
}

enum MatchSexFilter: String, CaseIterable, Identifiable {
    case all
    case male
    case female

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:
            return "Tous"
        case .male:
            return "Hommes"
        case .female:
            return "Femmes"
        }
    }

    var mappedSex: UserSex? {
        switch self {
        case .all:
            return nil
        case .male:
            return .male
        case .female:
            return .female
        }
    }
}

enum MatchOrientationFilter: String, CaseIterable, Identifiable {
    case all
    case hetero
    case bi
    case homo

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:
            return "Toutes"
        case .hetero:
            return "Hetero"
        case .bi:
            return "Bi"
        case .homo:
            return "Homo"
        }
    }

    var mappedOrientation: UserOrientation? {
        switch self {
        case .all:
            return nil
        case .hetero:
            return .hetero
        case .bi:
            return .bi
        case .homo:
            return .homo
        }
    }
}

@MainActor
@Observable
final class MatchesViewModel {
    private(set) var items: [MatchListItem] = []
    private(set) var incomingLikeProfiles: [UserProfile] = []
    var isPremiumLikesFeedEnabled = false
    var sexFilter: MatchSexFilter = .all {
        didSet { applyFilters() }
    }
    var orientationFilter: MatchOrientationFilter = .all {
        didSet { applyFilters() }
    }
    var sharedInterestsOnly = false {
        didSet { applyFilters() }
    }
    var myPreferencesOnly = false {
        didSet { applyFilters() }
    }

    private var allItems: [MatchListItem] = []

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
        loadMatches()
    }

    var totalMatchesCount: Int {
        allItems.count
    }

    var hasActiveFilters: Bool {
        sexFilter != .all || orientationFilter != .all || sharedInterestsOnly || myPreferencesOnly
    }

    var hasAnyMatches: Bool {
        !allItems.isEmpty
    }

    var hasIncomingLikes: Bool {
        !incomingLikeProfiles.isEmpty
    }

    var incomingLikesCount: Int {
        incomingLikeProfiles.count
    }

    func togglePremiumLikesFeed() {
        isPremiumLikesFeedEnabled.toggle()
    }

    func sharedInterestsCount(with profile: UserProfile) -> Int {
        guard let currentUser = userRepository.currentUser() else {
            return 0
        }
        return Set(currentUser.interests).intersection(Set(profile.interests)).count
    }

    func resetFilters() {
        sexFilter = .all
        orientationFilter = .all
        sharedInterestsOnly = false
        myPreferencesOnly = false
    }

    func loadMatches() {
        allItems = matchRepository.matches(for: currentUserID).compactMap { match in
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
        loadIncomingLikes()
        applyFilters()
    }

    private func loadIncomingLikes() {
        guard let currentUser = userRepository.currentUser() else {
            incomingLikeProfiles = []
            return
        }

        let swipedIDs = swipeRepository.swipedProfileIDs(for: currentUserID)
        let matchedIDs = matchRepository.matchedUserIDs(for: currentUserID)

        incomingLikeProfiles = userRepository.profiles
            .filter { profile in
                profile.id != currentUserID &&
                    profile.likedUserIDs.contains(currentUserID) &&
                    !swipedIDs.contains(profile.id) &&
                    !matchedIDs.contains(profile.id) &&
                    currentUser.canMutuallyMatch(with: profile)
            }
            .sorted(by: { $0.firstName < $1.firstName })
    }

    private func applyFilters() {
        let currentUser = userRepository.currentUser()

        items = allItems.filter { item in
            if let expectedSex = sexFilter.mappedSex, item.otherUser.sex != expectedSex {
                return false
            }

            if let expectedOrientation = orientationFilter.mappedOrientation, item.otherUser.orientation != expectedOrientation {
                return false
            }

            if sharedInterestsOnly, let currentUser {
                let currentInterests = Set(currentUser.interests)
                let otherInterests = Set(item.otherUser.interests)
                if currentInterests.intersection(otherInterests).isEmpty {
                    return false
                }
            }

            if myPreferencesOnly, let currentUser, !currentUser.isInterested(in: item.otherUser) {
                return false
            }

            return true
        }
    }
}
