import Foundation

#if canImport(ActivityKit)
import ActivityKit

struct LikesQuotaActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingLikes: Int
        var dailyLimit: Int
        var resetAt: Date
    }

    var activityName: String = "likes-quota"
}
#endif
