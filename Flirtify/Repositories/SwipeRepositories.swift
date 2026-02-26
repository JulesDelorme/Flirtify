import Foundation
import Observation

@MainActor
@Observable
final class SwipeRepository {
    private(set) var swipes: [Swipe]

    init(swipes: [Swipe] = []) {
        self.swipes = swipes
    }

    func swipedProfileIDs(for userID: UUID) -> Set<UUID> {
        Set(swipes.filter({ $0.fromUserID == userID }).map(\.toUserID))
    }

    func hasSwipe(from userID: UUID, to profileID: UUID) -> Bool {
        swipes.contains(where: { $0.fromUserID == userID && $0.toUserID == profileID })
    }

    @discardableResult
    func recordSwipe(from userID: UUID, to profileID: UUID, direction: SwipeDirection) -> Swipe? {
        guard !hasSwipe(from: userID, to: profileID) else {
            return nil
        }

        let swipe = Swipe(
            fromUserID: userID,
            toUserID: profileID,
            direction: direction
        )
        swipes.append(swipe)
        return swipe
    }
}
