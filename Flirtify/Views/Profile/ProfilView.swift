import SwiftUI

struct ProfilView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            if let profile = viewModel.profile {
                VStack(spacing: 16) {
                    Image(systemName: profile.photoSymbol)
                        .font(.system(size: 72))
                        .foregroundStyle(.blue)
                        .frame(width: 120, height: 120)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())

                    VStack(spacing: 4) {
                        Text(profile.headline)
                            .font(.title2.bold())
                        Text(profile.city)
                            .foregroundStyle(.secondary)
                    }

                    Text(profile.bio)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Interests")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], alignment: .leading, spacing: 8) {
                            ForEach(profile.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.14))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            } else {
                EmptyStateView(
                    title: "Profile unavailable",
                    subtitle: "Try again in a moment.",
                    symbol: "person.crop.circle.badge.exclamationmark"
                )
            }
        }
        .navigationTitle("My profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
                .disabled(viewModel.profile == nil)
            }
        }
        .sheet(isPresented: $isEditing) {
            if let profile = viewModel.profile {
                EditProfileView(profile: profile) { payload in
                    viewModel.saveProfile(
                        firstName: payload.firstName,
                        ageText: payload.ageText,
                        city: payload.city,
                        bio: payload.bio,
                        interestsText: payload.interestsText,
                        photoSymbol: payload.photoSymbol
                    )
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}
