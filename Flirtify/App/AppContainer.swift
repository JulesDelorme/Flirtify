import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    private(set) var hasCreatedAccount: Bool

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
        hasCreatedAccount = UserDefaults.standard.bool(forKey: Self.accountCreatedFlagKey)
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

    func currentUserProfile() -> UserProfile? {
        userRepository.currentUser()
    }

    func createAccount(
        firstName: String,
        ageText: String,
        city: String,
        bio: String,
        sex: UserSex,
        orientation: UserOrientation,
        interests: [String],
        photoData: Data?,
        photoGalleryData: [Data]
    ) {
        let cleanedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedInterests = interests
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cappedInterests = Array(cleanedInterests.prefix(InterestCatalog.maxSelectable))

        let parsedAge = Int(ageText) ?? 18
        let clampedAge = min(max(parsedAge, 18), 99)

        userRepository.updateCurrentUser(
            firstName: cleanedFirstName.isEmpty ? "Toi" : cleanedFirstName,
            age: clampedAge,
            city: cleanedCity.isEmpty ? "Ville inconnue" : cleanedCity,
            bio: cleanedBio.isEmpty ? "Pas encore de bio." : cleanedBio,
            sex: sex,
            orientation: orientation,
            interests: cappedInterests.isEmpty ? ["Cafe"] : cappedInterests,
            photoData: photoData,
            photoGalleryData: photoGalleryData
        )

        UserDefaults.standard.set(true, forKey: Self.accountCreatedFlagKey)
        hasCreatedAccount = true
    }

    private static let accountCreatedFlagKey = "IOS.Flirtify.accountCreated"
}
