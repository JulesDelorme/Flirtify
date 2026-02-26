import Foundation

enum SeedData {
    static let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let leaID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
    static let camilleID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
    static let chloeID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
    static let inesID = UUID(uuidString: "00000000-0000-0000-0000-000000000013")!
    static let sarahID = UUID(uuidString: "00000000-0000-0000-0000-000000000014")!
    static let manonID = UUID(uuidString: "00000000-0000-0000-0000-000000000015")!
    static let noraID = UUID(uuidString: "00000000-0000-0000-0000-000000000016")!
    static let emmaID = UUID(uuidString: "00000000-0000-0000-0000-000000000017")!
    static let salomeID = UUID(uuidString: "00000000-0000-0000-0000-000000000018")!
    static let aminaID = UUID(uuidString: "00000000-0000-0000-0000-000000000019")!
    static let julieID = UUID(uuidString: "00000000-0000-0000-0000-00000000001A")!
    static let zoeID = UUID(uuidString: "00000000-0000-0000-0000-00000000001B")!
    static let claraID = UUID(uuidString: "00000000-0000-0000-0000-00000000001C")!
    static let lolaID = UUID(uuidString: "00000000-0000-0000-0000-00000000001D")!
    static let paulineID = UUID(uuidString: "00000000-0000-0000-0000-00000000001E")!
    static let hugoID = UUID(uuidString: "00000000-0000-0000-0000-00000000001F")!
    static let theoID = UUID(uuidString: "00000000-0000-0000-0000-000000000020")!
    static let karimID = UUID(uuidString: "00000000-0000-0000-0000-000000000021")!
    static let lucasID = UUID(uuidString: "00000000-0000-0000-0000-000000000022")!
    static let eventAfterworkBdxID = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let eventExpoParisID = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    static let eventRunBdxID = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
    static let eventFoodLyonID = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
    static let eventMusicNantesID = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!
    static let eventAfterworkToulouseID = UUID(uuidString: "10000000-0000-0000-0000-000000000006")!

    static let initialProfiles: [UserProfile] = [
        UserProfile(
            id: currentUserID,
            firstName: "Jules",
            age: 26,
            city: "Bordeaux",
            bio: "Je construis des produits et je cherche les meilleurs spots ramen.",
            sex: .male,
            orientation: .hetero,
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
            sex: .female,
            orientation: .hetero,
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
            sex: .female,
            orientation: .bi,
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
            sex: .female,
            orientation: .hetero,
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
            sex: .female,
            orientation: .bi,
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
            sex: .female,
            orientation: .hetero,
            interests: ["Musique", "Randonnee", "Voyages"],
            photoSymbol: "music.note",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: manonID,
            firstName: "Manon",
            age: 26,
            city: "Lyon",
            bio: "Apero en terrasse, cine inde et weekends rando.",
            sex: .female,
            orientation: .hetero,
            interests: ["Cinema", "Randonnee", "Brunch"],
            photoSymbol: "wineglass.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: noraID,
            firstName: "Nora",
            age: 29,
            city: "Marseille",
            bio: "Plongee, street food et couchers de soleil.",
            sex: .female,
            orientation: .bi,
            interests: ["Voyages", "Cuisine", "Photographie"],
            photoSymbol: "sun.max.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: emmaID,
            firstName: "Emma",
            age: 25,
            city: "Rennes",
            bio: "Fan de concerts et de cafes qui ferment tard.",
            sex: .female,
            orientation: .hetero,
            interests: ["Concerts", "Cafe", "Musique"],
            photoSymbol: "music.mic",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: salomeID,
            firstName: "Salome",
            age: 27,
            city: "Montpellier",
            bio: "Yoga matinal et cuisine du marche.",
            sex: .female,
            orientation: .bi,
            interests: ["Yoga", "Cuisine", "Mode"],
            photoSymbol: "leaf.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: aminaID,
            firstName: "Amina",
            age: 24,
            city: "Nice",
            bio: "Escapades improvisees et grosses playlists.",
            sex: .female,
            orientation: .hetero,
            interests: ["Voyages", "Musique", "Running"],
            photoSymbol: "airplane.departure",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: julieID,
            firstName: "Julie",
            age: 30,
            city: "Strasbourg",
            bio: "Bouquins, musees et cinema du dimanche.",
            sex: .female,
            orientation: .hetero,
            interests: ["Lecture", "Art", "Cinema"],
            photoSymbol: "theatermasks.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: zoeID,
            firstName: "Zoe",
            age: 22,
            city: "Toulon",
            bio: "Jeux video, bubble tea et week-end plage.",
            sex: .female,
            orientation: .bi,
            interests: ["Jeux video", "Series", "Animaux"],
            photoSymbol: "gamecontroller.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: claraID,
            firstName: "Clara",
            age: 28,
            city: "Grenoble",
            bio: "Trail en montagne et cuisine maison.",
            sex: .female,
            orientation: .hetero,
            interests: ["Running", "Randonnee", "Cuisine"],
            photoSymbol: "mountain.2.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: lolaID,
            firstName: "Lola",
            age: 26,
            city: "Lyon",
            bio: "Photo de rue et brunch en bande.",
            sex: .female,
            orientation: .bi,
            interests: ["Photographie", "Brunch", "Art"],
            photoSymbol: "camera.aperture",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: paulineID,
            firstName: "Pauline",
            age: 27,
            city: "Bordeaux",
            bio: "Startup life, sport et cafes de quartier.",
            sex: .female,
            orientation: .hetero,
            interests: ["Tech", "Sport", "Cafe"],
            photoSymbol: "laptopcomputer",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: [currentUserID]
        ),
        UserProfile(
            id: hugoID,
            firstName: "Hugo",
            age: 28,
            city: "Lille",
            bio: "Cine de minuit et cooking challenges.",
            sex: .male,
            orientation: .hetero,
            interests: ["Cinema", "Cuisine", "Musique"],
            photoSymbol: "fork.knife",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: theoID,
            firstName: "Theo",
            age: 24,
            city: "Nantes",
            bio: "Guitare, footing et concerts live.",
            sex: .male,
            orientation: .hetero,
            interests: ["Musique", "Running", "Concerts"],
            photoSymbol: "guitars.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: karimID,
            firstName: "Karim",
            age: 31,
            city: "Paris",
            bio: "Voyages, photo argentique et expos.",
            sex: .male,
            orientation: .bi,
            interests: ["Voyages", "Photographie", "Art"],
            photoSymbol: "map.fill",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
        UserProfile(
            id: lucasID,
            firstName: "Lucas",
            age: 27,
            city: "Toulouse",
            bio: "Cuisine epicee, mode et longues balades.",
            sex: .male,
            orientation: .homo,
            interests: ["Cuisine", "Mode", "Randonnee"],
            photoSymbol: "figure.walk",
            photoData: nil,
            photoGalleryData: [],
            likedUserIDs: []
        ),
    ]

    static let initialSwipes: [Swipe] = []
    static let initialMatches: [Match] = []
    static let initialMessages: [Message] = []
    static let initialEvents: [LocalEvent] = [
        LocalEvent(
            id: eventAfterworkBdxID,
            title: "Afterwork quai des Chartrons",
            category: .afterwork,
            city: "Bordeaux",
            venue: "Le Local",
            latitude: 44.8533,
            longitude: -0.5722,
            startsAt: dateInFuture(hours: 6),
            summary: "Networking chill avec terrasse et DJ set leger.",
            attendeeUserIDs: [leaID, paulineID, manonID]
        ),
        LocalEvent(
            id: eventExpoParisID,
            title: "Expo photo urbaine",
            category: .expo,
            city: "Paris",
            venue: "Galerie 11",
            latitude: 48.8606,
            longitude: 2.3376,
            startsAt: dateInFuture(hours: 26),
            summary: "Vernissage + rencontre artistes autour d'un verre.",
            attendeeUserIDs: [sarahID, karimID, julieID]
        ),
        LocalEvent(
            id: eventRunBdxID,
            title: "Run club du dimanche",
            category: .sport,
            city: "Bordeaux",
            venue: "Miroir d'eau",
            latitude: 44.8413,
            longitude: -0.5683,
            startsAt: dateInFuture(hours: 44),
            summary: "8 km rythme cool puis cafe debrief en groupe.",
            attendeeUserIDs: [leaID, claraID, theoID, aminaID]
        ),
        LocalEvent(
            id: eventFoodLyonID,
            title: "Tour street-food",
            category: .food,
            city: "Lyon",
            venue: "Presqu'ile",
            latitude: 45.7597,
            longitude: 4.8320,
            startsAt: dateInFuture(hours: 30),
            summary: "3 adresses, bonne ambiance et degustation en petit groupe.",
            attendeeUserIDs: [lolaID, lucasID, camilleID]
        ),
        LocalEvent(
            id: eventMusicNantesID,
            title: "Open air electro",
            category: .musique,
            city: "Nantes",
            venue: "Parc des Chantiers",
            latitude: 47.2066,
            longitude: -1.5622,
            startsAt: dateInFuture(hours: 52),
            summary: "Set sunset puis dancefloor en plein air.",
            attendeeUserIDs: [chloeID, noraID, emmaID]
        ),
        LocalEvent(
            id: eventAfterworkToulouseID,
            title: "Afterwork jeux de societe",
            category: .afterwork,
            city: "Toulouse",
            venue: "Le Comptoir Ludique",
            latitude: 43.6045,
            longitude: 1.4442,
            startsAt: dateInFuture(hours: 18),
            summary: "Tables de jeux, equipes random et ambiance detendue.",
            attendeeUserIDs: [camilleID, hugoID, inesID]
        ),
    ]

    private static func dateInFuture(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: .now) ?? .now
    }
}
