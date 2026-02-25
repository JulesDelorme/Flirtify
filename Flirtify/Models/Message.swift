import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let matchID: UUID
    let senderID: UUID
    let text: String
    let sentAt: Date

    init(
        id: UUID = UUID(),
        matchID: UUID,
        senderID: UUID,
        text: String,
        sentAt: Date = .now
    ) {
        self.id = id
        self.matchID = matchID
        self.senderID = senderID
        self.text = text
        self.sentAt = sentAt
    }
}
