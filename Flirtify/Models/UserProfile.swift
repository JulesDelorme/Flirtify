import Foundation

enum UserSex: String, CaseIterable, Identifiable {
    case male
    case female

    var id: String { rawValue }

    var label: String {
        switch self {
        case .male:
            return "Homme"
        case .female:
            return "Femme"
        }
    }
}

enum UserOrientation: String, CaseIterable, Identifiable {
    case hetero
    case bi
    case homo

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hetero:
            return "Hetero"
        case .bi:
            return "Bi"
        case .homo:
            return "Homo"
        }
    }
}

struct UserProfile: Identifiable, Equatable, Hashable {
    let id: UUID
    var firstName: String
    var age: Int
    var city: String
    var bio: String
    var sex: UserSex
    var orientation: UserOrientation
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

    func isInterested(in other: UserProfile) -> Bool {
        switch orientation {
        case .bi:
            return other.id != id
        case .hetero:
            return sex != other.sex
        case .homo:
            return sex == other.sex
        }
    }

    func canMutuallyMatch(with other: UserProfile) -> Bool {
        isInterested(in: other) && other.isInterested(in: self)
    }
}
