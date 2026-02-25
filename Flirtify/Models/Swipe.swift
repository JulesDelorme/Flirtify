import Foundation

enum SwipeDirection: String {
    case left
    case right
}

struct Swipe: Identifiable, Equatable {
    let id: UUID
    let fromUserID: UUID
    let toUserID: UUID
    let direction: SwipeDirection
    let createdAt: Date

    init(
        id: UUID = UUID(),
        fromUserID: UUID,
        toUserID: UUID,
        direction: SwipeDirection,
        createdAt: Date = .now
    ) {
        self.id = id
        self.fromUserID = fromUserID
        self.toUserID = toUserID
        self.direction = direction
        self.createdAt = createdAt
    }
}
