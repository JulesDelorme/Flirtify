import PhotosUI
import SwiftUI
import UIKit

struct EditProfilePayload {
    let firstName: String
    let ageText: String
    let city: String
    let bio: String
    let sex: UserSex
    let orientation: UserOrientation
    let interests: [String]
    let photoData: Data?
    let photoGalleryData: [Data]
}

struct EditProfileView: View {
    let profile: UserProfile
    let onSave: (EditProfilePayload) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var ageText: String
    @State private var city: String
    @State private var bio: String
    @State private var selectedSex: UserSex
    @State private var selectedOrientation: UserOrientation
    @State private var selectedInterests: Set<String>
    @State private var photoGalleryData: [Data]
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    init(profile: UserProfile, onSave: @escaping (EditProfilePayload) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _firstName = State(initialValue: profile.firstName)
        _ageText = State(initialValue: String(profile.age))
        _city = State(initialValue: profile.city)
        _bio = State(initialValue: profile.bio)
        _selectedSex = State(initialValue: profile.sex)
        _selectedOrientation = State(initialValue: profile.orientation)
        _selectedInterests = State(initialValue: Set(profile.interests))
        _photoGalleryData = State(initialValue: Self.initialProfilePhotoGalleryData(profile))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        Spacer(minLength: 0)
                        ProfilePhotoView(
                            photoData: primaryPhotoData,
                            fallbackSymbol: profile.photoSymbol,
                            size: 94,
                            backgroundColor: Color.blue.opacity(0.14),
                            symbolColor: .blue,
                            strokeColor: Color.blue.opacity(0.25)
                        )
                        Spacer(minLength: 0)
                    }

                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: Self.maxProfilePhotos,
                        matching: .images
                    ) {
                        Label("Ajouter des photos", systemImage: "photo.on.rectangle")
                    }

                    Text("\(photoGalleryData.count)/\(Self.maxProfilePhotos) photos")
                        .font(.caption)
                        .foregroundStyle(.secondary)

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
                                                .foregroundStyle(.white, .black.opacity(0.65))
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                    .padding(.top, 6)
                                    .padding(.trailing, 2)
                                }
                            }
                        }

                        Button("Retirer toutes les photos") {
                            photoGalleryData = []
                            selectedPhotoItems = []
                        }
                        .foregroundStyle(.red)
                    }
                }

                Section("Informations") {
                    TextField("Prenom", text: $firstName)
                    TextField("Age", text: $ageText)
                        .keyboardType(.numberPad)
                    TextField("Ville", text: $city)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3 ... 5)
                }

                Section("Preferences") {
                    Picker("Sexe", selection: $selectedSex) {
                        ForEach(UserSex.allCases) { sex in
                            Text(sex.label).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Orientation", selection: $selectedOrientation) {
                        ForEach(UserOrientation.allCases) { orientation in
                            Text(orientation.label).tag(orientation)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Centres d'interet") {
                    Text("\(selectedInterests.count) selectionnes")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    InterestChipsPicker(
                        allInterests: InterestCatalog.all,
                        selectedInterests: $selectedInterests
                    )
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Modifier le profil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        onSave(
                            EditProfilePayload(
                                firstName: firstName,
                                ageText: ageText,
                                city: city,
                                bio: bio,
                                sex: selectedSex,
                                orientation: selectedOrientation,
                                interests: InterestCatalog.orderedSelection(from: selectedInterests),
                                photoData: primaryPhotoData,
                                photoGalleryData: photoGalleryData
                            )
                        )
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task {
                await loadSelectedPhotos(from: newItems)
            }
        }
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
                Color.blue.opacity(0.15)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.blue.opacity(0.75))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
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

    private static func initialProfilePhotoGalleryData(_ profile: UserProfile) -> [Data] {
        if !profile.photoGalleryData.isEmpty {
            return Array(profile.photoGalleryData.prefix(maxProfilePhotos))
        }

        if let photoData = profile.photoData {
            return [photoData]
        }

        return []
    }
}
