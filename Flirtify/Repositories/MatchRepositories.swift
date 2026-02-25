import Combine
import Foundation

@MainActor
final class MatchRepository: ObservableObject {
    @Published private(set) var matches: [Match]

    init(matches: [Match] = []) {
        self.matches = matches
    }

    func matches(for userID: UUID) -> [Match] {
        matches
            .filter({ $0.includes(userID) })
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    func matchedUserIDs(for userID: UUID) -> Set<UUID> {
        Set(matches(for: userID).compactMap({ $0.otherUserID(for: userID) }))
    }

    func findMatch(between userAID: UUID, and userBID: UUID) -> Match? {
        let pair = [userAID, userBID].sorted(by: { $0.uuidString < $1.uuidString })
        return matches.first(where: { $0.userIDs == pair })
    }

    @discardableResult
    func createMatch(between userAID: UUID, and userBID: UUID) -> Match {
        if let existingMatch = findMatch(between: userAID, and: userBID) {
            return existingMatch
        }

        let match = Match(userIDs: [userAID, userBID])
        matches.append(match)
        return match
    }
}
