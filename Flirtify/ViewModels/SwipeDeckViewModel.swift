import Foundation
import Observation

@MainActor
@Observable
final class SwipeDeckViewModel {
    private static let dailyLikeLimit = 6
    private static let likesDayKeyStorage = "IOS.Flirtify.likes.dayKey"
    private static let likesUsedCountStorage = "IOS.Flirtify.likes.usedCount"
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private(set) var deck: [UserProfile] = []
    var latestMatchUser: UserProfile?
    private(set) var likesRemainingToday = SwipeDeckViewModel.dailyLikeLimit
    private(set) var likeLimitReachedEventCount = 0
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

    private let currentUserID: UUID
    private let userRepository: UserRepository
    private let swipeRepository: SwipeRepository
    private let matchRepository: MatchRepository
    private let messageRepository: MessageRepository
    private let likesActivityManager: LikesActivityManager
    private let userDefaults: UserDefaults
    private var allProfiles: [UserProfile] = []

    init(
        currentUserID: UUID,
        userRepository: UserRepository,
        swipeRepository: SwipeRepository,
        matchRepository: MatchRepository,
        messageRepository: MessageRepository,
        likesActivityManager: LikesActivityManager? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.currentUserID = currentUserID
        self.userRepository = userRepository
        self.swipeRepository = swipeRepository
        self.matchRepository = matchRepository
        self.messageRepository = messageRepository
        self.likesActivityManager = likesActivityManager ?? .shared
        self.userDefaults = userDefaults
        refreshDailyLikesQuota()
        loadDeck()
    }

    var topProfile: UserProfile? {
        deck.first
    }

    var hasActiveFilters: Bool {
        sexFilter != .all || orientationFilter != .all || sharedInterestsOnly || myPreferencesOnly
    }

    var hasAnyProfiles: Bool {
        !allProfiles.isEmpty
    }

    var dailyLikesLimit: Int {
        Self.dailyLikeLimit
    }

    var hasLikesRemaining: Bool {
        likesRemainingToday > 0
    }

    func loadDeck() {
        refreshDailyLikesQuota()
        let swipedIDs = swipeRepository.swipedProfileIDs(for: currentUserID)
        let matchedIDs = matchRepository.matchedUserIDs(for: currentUserID)
        allProfiles = userRepository.candidateProfiles(
            excluding: swipedIDs,
            matchedUserIDs: matchedIDs
        )
        applyFilters()
    }

    func resetFilters() {
        sexFilter = .all
        orientationFilter = .all
        sharedInterestsOnly = false
        myPreferencesOnly = false
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

        if direction == .right, !consumeLikeIfAvailable() {
            notifyLikeLimitReached()
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

    func notifyLikeLimitReached() {
        likeLimitReachedEventCount += 1
    }

    private func applyFilters() {
        let currentUser = userRepository.currentUser()

        deck = allProfiles.filter { profile in
            if let expectedSex = sexFilter.mappedSex, profile.sex != expectedSex {
                return false
            }

            if let expectedOrientation = orientationFilter.mappedOrientation, profile.orientation != expectedOrientation {
                return false
            }

            if sharedInterestsOnly, let currentUser {
                let currentInterests = Set(currentUser.interests)
                let profileInterests = Set(profile.interests)
                if currentInterests.intersection(profileInterests).isEmpty {
                    return false
                }
            }

            if myPreferencesOnly, let currentUser, !currentUser.isInterested(in: profile) {
                return false
            }

            return true
        }
    }

    private func consumeLikeIfAvailable() -> Bool {
        refreshDailyLikesQuota()
        guard likesRemainingToday > 0 else {
            return false
        }

        let usedCount = userDefaults.integer(forKey: Self.likesUsedCountStorage) + 1
        userDefaults.set(usedCount, forKey: Self.likesUsedCountStorage)
        likesRemainingToday = max(0, Self.dailyLikeLimit - usedCount)
        updateLikesActivity()
        return true
    }

    private func refreshDailyLikesQuota() {
        let now = Date()
        let todayKey = Self.dayFormatter.string(from: now)
        let storedDayKey = userDefaults.string(forKey: Self.likesDayKeyStorage)

        if storedDayKey != todayKey {
            userDefaults.set(todayKey, forKey: Self.likesDayKeyStorage)
            userDefaults.set(0, forKey: Self.likesUsedCountStorage)
        }

        let usedCount = userDefaults.integer(forKey: Self.likesUsedCountStorage)
        likesRemainingToday = max(0, Self.dailyLikeLimit - usedCount)
        updateLikesActivity()
    }

    private func updateLikesActivity() {
        let resetAt = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Date().addingTimeInterval(24 * 60 * 60)

        likesActivityManager.startOrUpdate(
            remainingLikes: likesRemainingToday,
            dailyLimit: Self.dailyLikeLimit,
            resetAt: resetAt
        )
    }
}
