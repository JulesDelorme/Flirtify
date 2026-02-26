import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

@MainActor
final class LikesActivityManager {
    static let shared = LikesActivityManager()

    private init() {}

    func startOrUpdate(
        remainingLikes: Int,
        dailyLimit: Int,
        resetAt: Date
    ) {
        #if canImport(ActivityKit)
        guard #available(iOS 16.2, *) else {
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let state = LikesQuotaActivityAttributes.ContentState(
            remainingLikes: remainingLikes,
            dailyLimit: dailyLimit,
            resetAt: resetAt
        )
        let content = ActivityContent(state: state, staleDate: resetAt)

        if let existingActivity = Activity<LikesQuotaActivityAttributes>.activities.first {
            Task {
                await existingActivity.update(content)
            }
        } else {
            do {
                _ = try Activity.request(
                    attributes: LikesQuotaActivityAttributes(),
                    content: content,
                    pushType: nil
                )
            } catch {
                return
            }
        }
        #endif
    }
}
