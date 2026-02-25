import Foundation

struct Match: Identifiable, Equatable {
    let id: UUID
    let userIDs: [UUID]
    let createdAt: Date

    init(id: UUID = UUID(), userIDs: [UUID], createdAt: Date = .now) {
        let normalizedUserIDs = Array(Set(userIDs)).sorted { $0.uuidString < $1.uuidString }
        precondition(normalizedUserIDs.count == 2, "A match must contain exactly two user IDs.")

        self.id = id
        self.userIDs = normalizedUserIDs
        self.createdAt = createdAt
    }

    func includes(_ userID: UUID) -> Bool {
        userIDs.contains(userID)
    }

    func otherUserID(for userID: UUID) -> UUID? {
        userIDs.first(where: { $0 != userID })
    }
}
