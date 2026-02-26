import SwiftUI

struct PreferenceCategoriesView: View {
    let viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            if viewModel.preferenceCategories.isEmpty {
                EmptyStateView(
                    title: "Aucune categorie disponible",
                    subtitle: "Ajoute des centres d'interet pour voir des profils associes.",
                    symbol: "line.3.horizontal.decrease.circle"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.preferenceCategories, id: \.self) { category in
                        NavigationLink {
                            PreferenceCategoryProfilesView(
                                viewModel: viewModel,
                                category: category
                            )
                        } label: {
                            categoryRow(category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryRow(_ category: String) -> some View {
        let associatedCount = viewModel.profiles(forPreferenceCategory: category).count

        return HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.8))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(associatedCount) profil\(associatedCount > 1 ? "s" : "") associe\(associatedCount > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct PreferenceCategoryProfilesView: View {
    let viewModel: ProfileViewModel
    let category: String

    var body: some View {
        ScrollView {
            if profiles.isEmpty {
                EmptyStateView(
                    title: "Aucun profil pour \(category)",
                    subtitle: "Essaie une autre categorie pour trouver plus de personnes.",
                    symbol: "person.crop.circle.badge.questionmark"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(profiles) { profile in
                        associatedProfileCard(profile)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profiles: [UserProfile] {
        viewModel.profiles(forPreferenceCategory: category)
    }

    private func associatedProfileCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ProfilePhotoView(
                    photoData: profile.primaryPhotoData,
                    fallbackSymbol: profile.photoSymbol,
                    size: 54,
                    backgroundColor: Color.blue.opacity(0.13),
                    symbolColor: .blue,
                    strokeColor: Color.blue.opacity(0.28)
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.headline)
                        .font(.headline.weight(.semibold))
                    Text(profile.city)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Text(profile.bio)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(profile.interests, id: \.self) { interest in
                        Text(interest)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(interest == category ? Color.blue.opacity(0.22) : Color.white.opacity(0.12))
                            )
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
