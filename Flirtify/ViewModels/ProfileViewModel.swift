import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var profile: UserProfile?

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        loadProfile()
    }

    func loadProfile() {
        profile = userRepository.currentUser()
    }

    var preferenceCategories: [String] {
        let allKnownKeys = Set(InterestCatalog.all.map(categoryKey))
        let allCategories = userRepository.profiles
            .flatMap(\.interests)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var discoveredKeys: Set<String> = []
        var customCategories: [String] = []

        for category in allCategories {
            let key = categoryKey(category)
            guard discoveredKeys.insert(key).inserted else {
                continue
            }
            if !allKnownKeys.contains(key) {
                customCategories.append(category)
            }
        }

        let orderedKnown = InterestCatalog.all.filter { discoveredKeys.contains(categoryKey($0)) }
        let orderedCustom = customCategories.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        return orderedKnown + orderedCustom
    }

    func profiles(forPreferenceCategory category: String) -> [UserProfile] {
        guard let currentUser = userRepository.currentUser() else {
            return []
        }

        let expectedCategoryKey = categoryKey(category)

        return userRepository.profiles
            .filter { profile in
                profile.id != currentUser.id &&
                    currentUser.canMutuallyMatch(with: profile) &&
                    profile.interests.contains(where: { categoryKey($0) == expectedCategoryKey })
            }
            .sorted { lhs, rhs in
                if lhs.firstName != rhs.firstName {
                    return lhs.firstName < rhs.firstName
                }
                return lhs.age < rhs.age
            }
    }

    func saveProfile(
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
        loadProfile()
    }

    private func categoryKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
