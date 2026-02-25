import Combine
import Foundation

@MainActor
final class MessageRepository: ObservableObject {
    @Published private(set) var messages: [Message]

    init(messages: [Message] = []) {
        self.messages = messages
    }

    func messages(for matchID: UUID) -> [Message] {
        messages
            .filter({ $0.matchID == matchID })
            .sorted(by: { $0.sentAt < $1.sentAt })
    }

    func lastMessage(for matchID: UUID) -> Message? {
        messages(for: matchID).last
    }

    @discardableResult
    func sendMessage(matchID: UUID, senderID: UUID, text: String) -> Message? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return nil
        }

        let message = Message(
            matchID: matchID,
            senderID: senderID,
            text: trimmedText
        )
        messages.append(message)
        return message
    }
}
