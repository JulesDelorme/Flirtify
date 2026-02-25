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
        loadProfile()
    }
}
