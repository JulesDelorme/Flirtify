import SwiftUI

struct EditProfilePayload {
    let firstName: String
    let ageText: String
    let city: String
    let bio: String
    let interestsText: String
    let photoSymbol: String
}

struct EditProfileView: View {
    let profile: UserProfile
    let onSave: (EditProfilePayload) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var ageText: String
    @State private var city: String
    @State private var bio: String
    @State private var interestsText: String
    @State private var photoSymbol: String

    init(profile: UserProfile, onSave: @escaping (EditProfilePayload) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _firstName = State(initialValue: profile.firstName)
        _ageText = State(initialValue: String(profile.age))
        _city = State(initialValue: profile.city)
        _bio = State(initialValue: profile.bio)
        _interestsText = State(initialValue: profile.interests.joined(separator: ", "))
        _photoSymbol = State(initialValue: profile.photoSymbol)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("First name", text: $firstName)
                    TextField("Age", text: $ageText)
                        .keyboardType(.numberPad)
                    TextField("City", text: $city)
                }

                Section("Description") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3 ... 5)
                    TextField("Interests (comma separated)", text: $interestsText, axis: .vertical)
                        .lineLimit(2 ... 4)
                }

                Section("Avatar symbol") {
                    TextField("SF Symbol", text: $photoSymbol)
                    HStack {
                        Text("Preview")
                        Spacer()
                        Image(systemName: photoSymbol.isEmpty ? "person.crop.square.fill" : photoSymbol)
                            .font(.title2)
                    }
                }
            }
            .navigationTitle("Edit profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            EditProfilePayload(
                                firstName: firstName,
                                ageText: ageText,
                                city: city,
                                bio: bio,
                                interestsText: interestsText,
                                photoSymbol: photoSymbol
                            )
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
