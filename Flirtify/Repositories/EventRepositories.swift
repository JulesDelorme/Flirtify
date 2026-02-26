import Foundation
import Observation

@MainActor
@Observable
final class EventRepository {
    private(set) var events: [LocalEvent]

    init(events: [LocalEvent] = []) {
        self.events = events
    }

    func upcomingEvents() -> [LocalEvent] {
        events
            .filter { $0.startsAt >= Date().addingTimeInterval(-2 * 60 * 60) }
            .sorted(by: { $0.startsAt < $1.startsAt })
    }

    func event(with id: UUID) -> LocalEvent? {
        events.first(where: { $0.id == id })
    }

    func isUserParticipating(userID: UUID, in eventID: UUID) -> Bool {
        guard let event = event(with: eventID) else {
            return false
        }
        return event.attendeeUserIDs.contains(userID)
    }

    func toggleParticipation(userID: UUID, in eventID: UUID) {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }) else {
            return
        }

        if events[eventIndex].attendeeUserIDs.contains(userID) {
            events[eventIndex].attendeeUserIDs.removeAll(where: { $0 == userID })
        } else {
            events[eventIndex].attendeeUserIDs.append(userID)
            events[eventIndex].attendeeUserIDs = Array(Set(events[eventIndex].attendeeUserIDs))
        }
    }
}
