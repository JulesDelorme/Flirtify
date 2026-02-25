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
            bio: "Product builder by day, ramen hunter by night.",
            interests: ["Coffee", "Music", "Trips"],
            photoSymbol: "person.crop.square.fill",
            likedUserIDs: []
        ),
        UserProfile(
            id: leaID,
            firstName: "Lea",
            age: 24,
            city: "Bordeaux",
            bio: "Runner, museum lover, and always up for espresso.",
            interests: ["Running", "Museums", "Coffee"],
            photoSymbol: "figure.run",
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: camilleID,
            firstName: "Camille",
            age: 27,
            city: "Toulouse",
            bio: "Weekend cook and sunset photographer.",
            interests: ["Cooking", "Photos", "Cycling"],
            photoSymbol: "camera.fill",
            likedUserIDs: []
        ),
        UserProfile(
            id: chloeID,
            firstName: "Chloe",
            age: 25,
            city: "Lille",
            bio: "Bookstores, concerts, and random train trips.",
            interests: ["Books", "Concerts", "Travel"],
            photoSymbol: "book.fill",
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: inesID,
            firstName: "Ines",
            age: 23,
            city: "Nantes",
            bio: "Dog person, startup person, brunch person.",
            interests: ["Dogs", "Startups", "Brunch"],
            photoSymbol: "dog.fill",
            likedUserIDs: []
        ),
        UserProfile(
            id: sarahID,
            firstName: "Sarah",
            age: 28,
            city: "Paris",
            bio: "Language nerd with a weak spot for vinyl records.",
            interests: ["Languages", "Vinyl", "Hiking"],
            photoSymbol: "music.note",
            likedUserIDs: [currentUserID]
        ),
    ]

    static let initialSwipes: [Swipe] = []
    static let initialMatches: [Match] = []
    static let initialMessages: [Message] = []
}
