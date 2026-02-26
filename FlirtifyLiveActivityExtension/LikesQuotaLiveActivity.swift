import ActivityKit
import SwiftUI
import WidgetKit

struct LikesQuotaLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LikesQuotaActivityAttributes.self) { context in
            lockScreenView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("Likes")
                    } icon: {
                        Image(systemName: "heart.fill")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.pink)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingLikes)/\(context.state.dailyLimit)")
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 4) {
                        Text("Reset dans")
                        Text(context.state.resetAt, style: .timer)
                            .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            } compactTrailing: {
                Text("\(context.state.remainingLikes)")
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            } minimal: {
                Text("\(context.state.remainingLikes)")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
        }
    }

    private func lockScreenView(state: LikesQuotaActivityAttributes.ContentState) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(.pink)
                .frame(width: 34, height: 34)
                .background(Color.pink.opacity(0.16))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Likes restants")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(state.remainingLikes)/\(state.dailyLimit) sur \(Self.windowMinutes) min")
                    .font(.headline.weight(.bold))

                HStack(spacing: 4) {
                    Text("Reset dans")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(state.resetAt, style: .timer)
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private static let windowMinutes = 10
}
