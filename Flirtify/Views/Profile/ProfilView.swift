import SwiftUI
import UIKit

struct ProfilView: View {
    let viewModel: ProfileViewModel
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            if let profile = viewModel.profile {
                VStack(spacing: 16) {
                    ProfilePhotoView(
                        photoData: profile.primaryPhotoData,
                        fallbackSymbol: profile.photoSymbol,
                        size: 124,
                        backgroundColor: Color.blue.opacity(0.12),
                        symbolColor: .blue,
                        strokeColor: Color.blue.opacity(0.25)
                    )

                    if !profile.photoGalleryData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(profile.photoGalleryData.enumerated()), id: \.offset) { _, photoData in
                                    profileThumbnail(photoData)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: 4) {
                        Text(profile.headline)
                            .font(.title2.bold())
                        Text(profile.city)
                            .foregroundStyle(.secondary)
                        Text("\(profile.sex.label) · \(profile.orientation.label)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Text(profile.bio)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Centres d'interet")
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
                    title: "Profil indisponible",
                    subtitle: "Reessaie dans un instant.",
                    symbol: "person.crop.circle.badge.exclamationmark"
                )
            }
        }
        .navigationTitle("Mon profil")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifier") {
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
                        sex: payload.sex,
                        orientation: payload.orientation,
                        interests: payload.interests,
                        photoData: payload.photoData,
                        photoGalleryData: payload.photoGalleryData
                    )
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }

    private func profileThumbnail(_ photoData: Data) -> some View {
        Group {
            if let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.blue.opacity(0.14)
                    .overlay(Image(systemName: "photo"))
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.blue.opacity(0.24), lineWidth: 1)
        )
    }
}
