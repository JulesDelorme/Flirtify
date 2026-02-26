import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class EventsViewModel {
    private static let nearbyRadiusKilometers = 120.0

    private(set) var allEvents: [LocalEvent] = []
    private(set) var events: [LocalEvent] = []
    var selectedCategory: LocalEventCategory? {
        didSet { applyFilters() }
    }
    var nearMeOnly = true {
        didSet { applyFilters() }
    }

    private let currentUserID: UUID
    private let userRepository: UserRepository
    private let swipeRepository: SwipeRepository
    private let matchRepository: MatchRepository
    private let eventRepository: EventRepository
    private let locationService: LocationService

    init(
        currentUserID: UUID,
        userRepository: UserRepository,
        swipeRepository: SwipeRepository,
        matchRepository: MatchRepository,
        eventRepository: EventRepository,
        locationService: LocationService
    ) {
        self.currentUserID = currentUserID
        self.userRepository = userRepository
        self.swipeRepository = swipeRepository
        self.matchRepository = matchRepository
        self.eventRepository = eventRepository
        self.locationService = locationService
        self.locationService.onLocationChange = { [weak self] in
            self?.loadEvents()
        }
        loadEvents()
    }

    var totalEventsCount: Int {
        allEvents.count
    }

    var currentUserCity: String {
        userRepository.currentUser()?.city ?? "Ta ville"
    }

    var isLocationAuthorized: Bool {
        locationService.isAuthorized
    }

    var canRequestLocationAuthorization: Bool {
        locationService.canRequestAuthorization
    }

    var nearbyRadiusKilometers: Int {
        Int(Self.nearbyRadiusKilometers)
    }

    var locationStatusText: String {
        if isLocationAuthorized, let location = locationService.currentLocation {
            return "Position activee (\(Int(location.horizontalAccuracy))m)"
        }

        if canRequestLocationAuthorization {
            return "Active la geolocalisation pour des events proches."
        }

        return "Geolocalisation indisponible, tri par ville."
    }

    func loadEvents() {
        if isLocationAuthorized, locationService.currentLocation == nil {
            locationService.requestLocation()
        }

        allEvents = eventRepository.upcomingEvents()
        applyFilters()
    }

    func requestLocationAccess() {
        locationService.requestAuthorizationIfNeeded()
    }

    func event(with id: UUID) -> LocalEvent? {
        eventRepository.event(with: id)
    }

    func toggleParticipation(for eventID: UUID) {
        eventRepository.toggleParticipation(userID: currentUserID, in: eventID)
        loadEvents()
    }

    func isParticipating(in event: LocalEvent) -> Bool {
        event.attendeeUserIDs.contains(currentUserID)
    }

    func matchCandidates(for event: LocalEvent) -> [UserProfile] {
        guard let currentUser = userRepository.currentUser() else {
            return []
        }

        let attendeeIDs = Set(event.attendeeUserIDs)
        let swipedIDs = swipeRepository.swipedProfileIDs(for: currentUserID)
        let matchedIDs = matchRepository.matchedUserIDs(for: currentUserID)

        return userRepository.profiles
            .filter { profile in
                attendeeIDs.contains(profile.id) &&
                    profile.id != currentUserID &&
                    !swipedIDs.contains(profile.id) &&
                    !matchedIDs.contains(profile.id) &&
                    currentUser.canMutuallyMatch(with: profile)
            }
            .sorted(by: { $0.firstName < $1.firstName })
    }

    func sharedInterests(with profile: UserProfile) -> [String] {
        guard let currentUser = userRepository.currentUser() else {
            return []
        }
        let currentInterests = Set(currentUser.interests)
        return profile.interests.filter { currentInterests.contains($0) }
    }

    func distanceFromCurrentUser(to event: LocalEvent) -> CLLocationDistance? {
        guard let currentLocation = locationService.currentLocation else {
            return nil
        }

        let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
        return currentLocation.distance(from: eventLocation)
    }

    func distanceLabel(for event: LocalEvent) -> String? {
        guard let distance = distanceFromCurrentUser(to: event) else {
            return nil
        }

        let kilometers = distance / 1_000
        if kilometers < 10 {
            return String(format: "%.1f km", kilometers)
        }
        return "\(Int(kilometers.rounded())) km"
    }

    private func applyFilters() {
        let city = userRepository.currentUser()?.city
        var filteredEvents = allEvents.filter { event in
            if let selectedCategory, event.category != selectedCategory {
                return false
            }

            if nearMeOnly {
                if let distance = distanceFromCurrentUser(to: event) {
                    if distance > Self.nearbyRadiusKilometers * 1_000 {
                        return false
                    }
                } else if let city, event.city != city {
                    return false
                }
            }

            return true
        }

        if isLocationAuthorized, locationService.currentLocation != nil {
            filteredEvents.sort { lhs, rhs in
                let lhsDistance = distanceFromCurrentUser(to: lhs) ?? .greatestFiniteMagnitude
                let rhsDistance = distanceFromCurrentUser(to: rhs) ?? .greatestFiniteMagnitude
                if lhsDistance == rhsDistance {
                    return lhs.startsAt < rhs.startsAt
                }
                return lhsDistance < rhsDistance
            }
        }

        events = filteredEvents
    }
}
