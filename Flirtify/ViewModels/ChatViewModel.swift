import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var draftMessage: String = ""

    let match: Match
    let otherUser: UserProfile
    private let currentUserID: UUID
    private let messageRepository: MessageRepository

    init(
        match: Match,
        otherUser: UserProfile,
        currentUserID: UUID,
        messageRepository: MessageRepository
    ) {
        self.match = match
        self.otherUser = otherUser
        self.currentUserID = currentUserID
        self.messageRepository = messageRepository
        loadMessages()
    }

    var canSendDraft: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadMessages() {
        messages = messageRepository.messages(for: match.id)
    }

    func sendDraftMessage() {
        guard canSendDraft else {
            return
        }

        _ = messageRepository.sendMessage(
            matchID: match.id,
            senderID: currentUserID,
            text: draftMessage
        )
        draftMessage = ""
        loadMessages()
    }

    func isFromCurrentUser(_ message: Message) -> Bool {
        message.senderID == currentUserID
    }
}
