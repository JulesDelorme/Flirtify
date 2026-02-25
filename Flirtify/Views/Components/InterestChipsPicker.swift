import SwiftUI

struct InterestChipsPicker: View {
    let allInterests: [String]
    @Binding var selectedInterests: Set<String>

    private let columns = [GridItem(.adaptive(minimum: 98), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(allInterests, id: \.self) { interest in
                Button {
                    toggle(interest)
                } label: {
                    Text(interest)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isSelected(interest) ? Color.white : Color.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            isSelected(interest) ? Color.blue : Color(.secondarySystemBackground)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func isSelected(_ interest: String) -> Bool {
        selectedInterests.contains(interest)
    }

    private func toggle(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
}
