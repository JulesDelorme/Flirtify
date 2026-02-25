import Combine
import Foundation

@MainActor
final class UserRepository: ObservableObject {
    @Published private(set) var profiles: [UserProfile]
    let currentUserID: UUID

    init(profiles: [UserProfile], currentUserID: UUID) {
        self.profiles = profiles
        self.currentUserID = currentUserID
    }

    func currentUser() -> UserProfile? {
        profile(with: currentUserID)
    }

    func profile(with id: UUID) -> UserProfile? {
        profiles.first(where: { $0.id == id })
    }

    func candidateProfiles(excluding excludedIDs: Set<UUID>, matchedUserIDs: Set<UUID>) -> [UserProfile] {
        profiles
            .filter { profile in
                profile.id != currentUserID &&
                    !excludedIDs.contains(profile.id) &&
                    !matchedUserIDs.contains(profile.id)
            }
            .sorted(by: { $0.firstName < $1.firstName })
    }

    func updateCurrentUser(
        firstName: String,
        age: Int,
        city: String,
        bio: String,
        interests: [String],
        photoSymbol: String
    ) {
        guard var currentUser = currentUser() else {
            return
        }

        currentUser.firstName = firstName
        currentUser.age = age
        currentUser.city = city
        currentUser.bio = bio
        currentUser.interests = interests
        currentUser.photoSymbol = photoSymbol

        guard let currentUserIndex = profiles.firstIndex(where: { $0.id == currentUser.id }) else {
            return
        }

        profiles[currentUserIndex] = currentUser
    }
}
