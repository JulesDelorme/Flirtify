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
                    Text("Reinitialisation a \(Self.hourFormatter.string(from: context.state.resetAt))")
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
                Text("\(state.remainingLikes)/\(state.dailyLimit) aujourd'hui")
                    .font(.headline.weight(.bold))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.timeStyle = .short
        return formatter
    }()
}
