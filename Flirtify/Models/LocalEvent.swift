import Foundation

enum LocalEventCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case afterwork
    case expo
    case sport
    case food
    case musique

    var id: String { rawValue }

    var label: String {
        switch self {
        case .afterwork:
            return "Afterwork"
        case .expo:
            return "Expo"
        case .sport:
            return "Sport"
        case .food:
            return "Food"
        case .musique:
            return "Musique"
        }
    }

    var systemImage: String {
        switch self {
        case .afterwork:
            return "wineglass.fill"
        case .expo:
            return "photo.artframe"
        case .sport:
            return "figure.run"
        case .food:
            return "fork.knife"
        case .musique:
            return "music.note"
        }
    }
}

struct LocalEvent: Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: LocalEventCategory
    var city: String
    var venue: String
    var latitude: Double
    var longitude: Double
    var startsAt: Date
    var summary: String
    var attendeeUserIDs: [UUID]

    init(
        id: UUID = UUID(),
        title: String,
        category: LocalEventCategory,
        city: String,
        venue: String,
        latitude: Double,
        longitude: Double,
        startsAt: Date,
        summary: String,
        attendeeUserIDs: [UUID]
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.city = city
        self.venue = venue
        self.latitude = latitude
        self.longitude = longitude
        self.startsAt = startsAt
        self.summary = summary
        self.attendeeUserIDs = attendeeUserIDs
    }
}
