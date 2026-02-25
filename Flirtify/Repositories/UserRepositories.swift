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
        photoData: Data?,
        photoGalleryData: [Data] = [],
        photoSymbol: String? = nil
    ) {
        guard var currentUser = currentUser() else {
            return
        }

        currentUser.firstName = firstName
        currentUser.age = age
        currentUser.city = city
        currentUser.bio = bio
        currentUser.interests = interests
        let cleanedPhotoGalleryData = normalizedPhotoGallery(photoGalleryData, fallback: photoData)
        currentUser.photoGalleryData = cleanedPhotoGalleryData
        currentUser.photoData = cleanedPhotoGalleryData.first
        if let photoSymbol {
            currentUser.photoSymbol = photoSymbol
        }

        guard let currentUserIndex = profiles.firstIndex(where: { $0.id == currentUser.id }) else {
            return
        }

        profiles[currentUserIndex] = currentUser
    }

    private func normalizedPhotoGallery(_ photoGalleryData: [Data], fallback: Data?) -> [Data] {
        var uniquePhotos: [Data] = []
        for photo in photoGalleryData {
            if !uniquePhotos.contains(photo) {
                uniquePhotos.append(photo)
            }
        }

        if uniquePhotos.isEmpty, let fallback {
            uniquePhotos = [fallback]
        }

        return Array(uniquePhotos.prefix(Self.maxProfilePhotos))
    }

    private static let maxProfilePhotos = 6
}
