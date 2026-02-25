import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    @Published private(set) var hasCreatedAccount: Bool

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
        interestsText: String,
        photoSymbol: String
    ) {
        let cleanedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPhotoSymbol = photoSymbol.trimmingCharacters(in: .whitespacesAndNewlines)

        let parsedAge = Int(ageText) ?? 18
        let clampedAge = min(max(parsedAge, 18), 99)

        let interests = interestsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        userRepository.updateCurrentUser(
            firstName: cleanedFirstName.isEmpty ? "You" : cleanedFirstName,
            age: clampedAge,
            city: cleanedCity.isEmpty ? "Unknown city" : cleanedCity,
            bio: cleanedBio.isEmpty ? "No bio yet." : cleanedBio,
            interests: interests.isEmpty ? ["Coffee"] : interests,
            photoSymbol: cleanedPhotoSymbol.isEmpty ? "person.crop.square.fill" : cleanedPhotoSymbol
        )

        UserDefaults.standard.set(true, forKey: Self.accountCreatedFlagKey)
        hasCreatedAccount = true
    }

    private static let accountCreatedFlagKey = "IOS.Flirtify.accountCreated"
}
