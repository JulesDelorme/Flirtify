import Foundation

enum SeedData {
    static let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let leaID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
    static let camilleID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
    static let chloeID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
    static let inesID = UUID(uuidString: "00000000-0000-0000-0000-000000000013")!
    static let sarahID = UUID(uuidString: "00000000-0000-0000-0000-000000000014")!

    static let initialProfiles: [UserProfile] = [
        UserProfile(
            id: currentUserID,
            firstName: "Jules",
            age: 26,
            city: "Bordeaux",
            bio: "Je construis des produits et je cherche les meilleurs spots ramen.",
            interests: ["Cafe", "Musique", "Voyages"],
            photoSymbol: "person.crop.square.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: leaID,
            firstName: "Lea",
            age: 24,
            city: "Bordeaux",
            bio: "Running, musees et espresso a toute heure.",
            interests: ["Running", "Art", "Cafe"],
            photoSymbol: "figure.run",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: camilleID,
            firstName: "Camille",
            age: 27,
            city: "Toulouse",
            bio: "Cuisine du week-end et photos au coucher du soleil.",
            interests: ["Cuisine", "Photographie", "Sport"],
            photoSymbol: "camera.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: chloeID,
            firstName: "Chloe",
            age: 25,
            city: "Lille",
            bio: "Librairies, concerts et voyages improvises.",
            interests: ["Lecture", "Concerts", "Voyages"],
            photoSymbol: "book.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: inesID,
            firstName: "Ines",
            age: 23,
            city: "Nantes",
            bio: "Team chiens, startups et brunch du dimanche.",
            interests: ["Animaux", "Tech", "Brunch"],
            photoSymbol: "dog.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: sarahID,
            firstName: "Sarah",
            age: 28,
            city: "Paris",
            bio: "Passionnee de langues et collectionneuse de vinyles.",
            interests: ["Musique", "Randonnee", "Voyages"],
            photoSymbol: "music.note",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
    ]

    static let initialSwipes: [Swipe] = []
    static let initialMatches: [Match] = []
    static let initialMessages: [Message] = []
}
