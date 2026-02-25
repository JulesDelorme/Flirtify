import Foundation

struct UserProfile: Identifiable, Equatable, Hashable {
    let id: UUID
    var firstName: String
    var age: Int
    var city: String
    var bio: String
    var interests: [String]
    var photoSymbol: String
    var likedUserIDs: Set<UUID>

    var headline: String {
        "\(firstName), \(age)"
    }
}
