import SwiftUI

struct CreateAccountPayload {
    let firstName: String
    let ageText: String
    let city: String
    let bio: String
    let interestsText: String
    let photoSymbol: String
}

struct CreateAccountView: View {
    let initialProfile: UserProfile?
    let onCreateAccount: (CreateAccountPayload) -> Void

    @State private var firstName: String
    @State private var ageText: String
    @State private var city: String
    @State private var bio: String
    @State private var interestsText: String
    @State private var photoSymbol: String

    init(initialProfile: UserProfile?, onCreateAccount: @escaping (CreateAccountPayload) -> Void) {
        self.initialProfile = initialProfile
        self.onCreateAccount = onCreateAccount
        _firstName = State(initialValue: initialProfile?.firstName ?? "")
        _ageText = State(initialValue: initialProfile.map { String($0.age) } ?? "")
        _city = State(initialValue: initialProfile?.city ?? "")
        _bio = State(initialValue: initialProfile?.bio ?? "")
        _interestsText = State(initialValue: initialProfile?.interests.joined(separator: ", ") ?? "")
        _photoSymbol = State(initialValue: initialProfile?.photoSymbol ?? "person.crop.square.fill")
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
                    formCard
                    PrimaryButton(title: "Create account", systemImage: "heart.fill") {
                        onCreateAccount(
                            CreateAccountPayload(
                                firstName: firstName,
                                ageText: ageText,
                                city: city,
                                bio: bio,
                                interestsText: interestsText,
                                photoSymbol: photoSymbol
                            )
                        )
                    }
                    .disabled(!canCreate)
                    .opacity(canCreate ? 1 : 0.55)
                }
                .padding(20)
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flirtify")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Create your profile and start matching.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: photoSymbol.isEmpty ? "person.crop.square.fill" : photoSymbol)
                    .font(.system(size: 30))
                    .frame(width: 56, height: 56)
                    .background(Color.blue.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(firstName.isEmpty ? "Your name" : firstName), \(ageText.isEmpty ? "?" : ageText)")
                        .font(.headline)
                    Text(city.isEmpty ? "Your city" : city)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Group {
                field("First name", text: $firstName)
                field("Age", text: $ageText, numeric: true)
                field("City", text: $city)
                field("Bio", text: $bio, axis: .vertical)
                field("Interests (comma separated)", text: $interestsText, axis: .vertical)
                field("SF Symbol (avatar)", text: $photoSymbol)
            }

            Text("Examples: `camera.fill`, `figure.run`, `book.fill`")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func field(
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
            !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
