import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile?

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        loadProfile()
    }

    func loadProfile() {
        profile = userRepository.currentUser()
    }

    func saveProfile(
        firstName: String,
        ageText: String,
        city: String,
        bio: String,
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

        let parsedAge = Int(ageText) ?? 18
        let clampedAge = min(max(parsedAge, 18), 99)

        userRepository.updateCurrentUser(
            firstName: cleanedFirstName.isEmpty ? "Toi" : cleanedFirstName,
            age: clampedAge,
            city: cleanedCity.isEmpty ? "Ville inconnue" : cleanedCity,
            bio: cleanedBio.isEmpty ? "Pas encore de bio." : cleanedBio,
            interests: cleanedInterests.isEmpty ? ["Cafe"] : cleanedInterests,
            photoData: photoData,
            photoGalleryData: photoGalleryData
        )
        loadProfile()
    }
}
