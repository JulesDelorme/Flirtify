import Foundation

enum InterestCatalog {
    struct Category: Identifiable, Hashable {
        let title: String
        let interests: [String]

        var id: String {
            title
        }
    }

    static let maxSelectable = 5

    static let categories: [Category] = [
        Category(
            title: "Signe astro",
            interests: [
                "Astrologie",
                "Belier",
                "Taureau",
                "Gemeaux",
                "Cancer",
                "Lion",
                "Vierge",
                "Balance",
                "Scorpion",
                "Sagittaire",
                "Capricorne",
                "Verseau",
                "Poissons",
            ]
        ),
        Category(
            title: "Voyages",
            interests: [
                "Voyages",
                "Road trip",
                "Backpacking",
                "Week-end city break",
                "Plage",
                "Montagne",
            ]
        ),
        Category(
            title: "Nourriture",
            interests: [
                "Cuisine",
                "Brunch",
                "Cafe",
                "Street food",
                "Patisserie",
                "Sushi",
                "Vegan",
            ]
        ),
        Category(
            title: "Culture",
            interests: [
                "Musique",
                "Concerts",
                "Cinema",
                "Lecture",
                "Art",
                "Musees",
                "Theatre",
                "Photographie",
            ]
        ),
        Category(
            title: "Sport",
            interests: [
                "Sport",
                "Running",
                "Yoga",
                "Randonnee",
                "Velo",
                "Natation",
                "Escalade",
            ]
        ),
        Category(
            title: "Lifestyle",
            interests: [
                "Animaux",
                "Danse",
                "Mode",
                "Meditation",
                "Series",
                "Jeux video",
            ]
        ),
        Category(
            title: "Tech",
            interests: [
                "Tech",
                "Podcasts",
                "IA",
                "Startups",
                "Gaming",
            ]
        ),
    ]

    static let all: [String] = categories.flatMap(\.interests)

    static func orderedSelection(from selectedInterests: Set<String>) -> [String] {
        let commonInterests = all.filter { selectedInterests.contains($0) }
        let customInterests = selectedInterests
            .subtracting(Set(all))
            .sorted(by: <)
        return commonInterests + customInterests
    }
}
