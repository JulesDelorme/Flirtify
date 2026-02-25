import Foundation

struct UserProfile: Identifiable, Equatable, Hashable {
    let id: UUID
    var firstName: String
    var age: Int
    var city: String
    var bio: String
    var interests: [String]
    var photoSymbol: String
    var photoData: Data?
    var photoGalleryData: [Data]
    var likedUserIDs: Set<UUID>

    var headline: String {
        "\(firstName), \(age)"
    }

    var primaryPhotoData: Data? {
        photoGalleryData.first ?? photoData
    }
}
