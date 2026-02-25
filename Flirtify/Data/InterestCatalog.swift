import Foundation

enum InterestCatalog {
    static let all: [String] = [
        "Musique",
        "Voyages",
        "Cuisine",
        "Cinema",
        "Sport",
        "Lecture",
        "Photographie",
        "Jeux video",
        "Animaux",
        "Randonnee",
        "Danse",
        "Art",
        "Cafe",
        "Series",
        "Tech",
        "Mode",
        "Brunch",
        "Yoga",
        "Running",
        "Concerts",
        
    ]

    static func orderedSelection(from selectedInterests: Set<String>) -> [String] {
        let commonInterests = all.filter { selectedInterests.contains($0) }
        let customInterests = selectedInterests
            .subtracting(Set(all))
            .sorted(by: <)
        return commonInterests + customInterests
    }
}
