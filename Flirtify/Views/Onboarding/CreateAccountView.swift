import PhotosUI
import SwiftUI
import UIKit

struct CreateAccountPayload {
    let firstName: String
    let ageText: String
    let city: String
    let bio: String
    let interests: [String]
    let photoData: Data?
    let photoGalleryData: [Data]
}

struct CreateAccountView: View {
    let initialProfile: UserProfile?
    let onCreateAccount: (CreateAccountPayload) -> Void

    @State private var firstName: String
    @State private var ageText: String
    @State private var city: String
    @State private var bio: String
    @State private var selectedInterests: Set<String>
    @State private var photoGalleryData: [Data]
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    init(initialProfile: UserProfile?, onCreateAccount: @escaping (CreateAccountPayload) -> Void) {
        self.initialProfile = initialProfile
        self.onCreateAccount = onCreateAccount
        _firstName = State(initialValue: initialProfile?.firstName ?? "")
        _ageText = State(initialValue: initialProfile.map { String($0.age) } ?? "")
        _city = State(initialValue: initialProfile?.city ?? "")
        _bio = State(initialValue: initialProfile?.bio ?? "")
        _selectedInterests = State(initialValue: Set(initialProfile?.interests ?? []))
        _photoGalleryData = State(initialValue: Self.initialProfilePhotoGalleryData(initialProfile))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.45),
                    Color.pink.opacity(0.32),
                    Color.blue.opacity(0.4),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    titleBlock
                    photoSection
                    infoSection
                    interestsSection

                    PrimaryButton(title: "Creer mon compte", systemImage: "heart.fill") {
                        onCreateAccount(
                            CreateAccountPayload(
                                firstName: firstName,
                                ageText: ageText,
                                city: city,
                                bio: bio,
                                interests: InterestCatalog.orderedSelection(from: selectedInterests),
                                photoData: primaryPhotoData,
                                photoGalleryData: photoGalleryData
                            )
                        )
                    }
                    .disabled(!canCreate)
                    .opacity(canCreate ? 1 : 0.55)
                }
                .padding(20)
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task {
                await loadSelectedPhotos(from: newItems)
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flirtify")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Cree ton profil et commence a matcher.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photos de profil")
                .font(.headline)

            HStack(spacing: 14) {
                ProfilePhotoView(
                    photoData: primaryPhotoData,
                    fallbackSymbol: initialProfile?.photoSymbol ?? "person.crop.square.fill",
                    size: 90,
                    backgroundColor: Color.white.opacity(0.24),
                    symbolColor: .white,
                    strokeColor: Color.white.opacity(0.7)
                )

                VStack(alignment: .leading, spacing: 8) {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: Self.maxProfilePhotos,
                        matching: .images
                    ) {
                        Label("Ajouter des photos", systemImage: "photo.on.rectangle")
                            .font(.subheadline.weight(.semibold))
                    }

                    Text("\(photoGalleryData.count)/\(Self.maxProfilePhotos) photos")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !photoGalleryData.isEmpty {
                        Button("Retirer toutes les photos") {
                            photoGalleryData = []
                            selectedPhotoItems = []
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                    }
                }

                Spacer(minLength: 0)
            }

            if !photoGalleryData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(photoGalleryData.enumerated()), id: \.offset) { index, photoData in
                            ZStack(alignment: .topTrailing) {
                                thumbnailView(photoData, size: 76)
                                Button {
                                    removePhoto(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                }
                                .offset(x: 6, y: -6)
                            }
                            .padding(.top, 6)
                            .padding(.trailing, 2)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations")
                .font(.headline)

            Group {
                textField("Prenom", text: $firstName)
                textField("Age", text: $ageText, numeric: true)
                textField("Ville", text: $city)
                textField("Bio", text: $bio, axis: .vertical)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Centres d'interet")
                    .font(.headline)
                Spacer(minLength: 0)
                Text("\(selectedInterests.count) selectionnes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            InterestChipsPicker(
                allInterests: InterestCatalog.all,
                selectedInterests: $selectedInterests
            )
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func textField(
        _ title: String,
        text: Binding<String>,
        numeric: Bool = false,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField(title, text: text, axis: axis)
                .textFieldStyle(.roundedBorder)
                .keyboardType(numeric ? .numberPad : .default)
                .lineLimit(axis == .vertical ? 2 ... 4 : 1 ... 1)
        }
    }

    private var canCreate: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !ageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !selectedInterests.isEmpty
    }

    private var primaryPhotoData: Data? {
        photoGalleryData.first
    }

    private func removePhoto(at index: Int) {
        guard photoGalleryData.indices.contains(index) else {
            return
        }
        photoGalleryData.remove(at: index)
    }

    private func thumbnailView(_ photoData: Data, size: CGFloat) -> some View {
        Group {
            if let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white.opacity(0.2)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.white.opacity(0.7))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }

    @MainActor
    private func loadSelectedPhotos(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else {
            return
        }

        var newPhotos: [Data] = []
        for item in items {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                UIImage(data: data) != nil
            else {
                continue
            }
            newPhotos.append(data)
        }

        for photo in newPhotos where !photoGalleryData.contains(photo) {
            photoGalleryData.append(photo)
        }

        if photoGalleryData.count > Self.maxProfilePhotos {
            photoGalleryData = Array(photoGalleryData.prefix(Self.maxProfilePhotos))
        }

        selectedPhotoItems = []
    }

    private static let maxProfilePhotos = 6

    private static func initialProfilePhotoGalleryData(_ profile: UserProfile?) -> [Data] {
        guard let profile else {
            return []
        }

        if !profile.photoGalleryData.isEmpty {
            return Array(profile.photoGalleryData.prefix(maxProfilePhotos))
        }

        if let photoData = profile.photoData {
            return [photoData]
        }

        return []
    }
}
