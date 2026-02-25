import SwiftUI

struct ProfileCardView: View {
    let profile: UserProfile

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.25),
                            Color.pink.opacity(0.45),
                            Color.orange.opacity(0.35),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 10) {
                ProfilePhotoView(
                    photoData: profile.primaryPhotoData,
                    fallbackSymbol: profile.photoSymbol,
                    size: 86,
                    backgroundColor: Color.white.opacity(0.2),
                    symbolColor: .white,
                    strokeColor: Color.white.opacity(0.5)
                )
                .padding(.bottom, 6)

                Text(profile.headline)
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text(profile.city)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("\(profile.sex.label) · \(profile.orientation.label)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))

                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(profile.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 460)
    }
}
