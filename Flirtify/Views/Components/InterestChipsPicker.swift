import SwiftUI

struct InterestChipsPicker: View {
    let categories: [InterestCatalog.Category]
    let maxSelectionCount: Int
    @Binding var selectedInterests: Set<String>

    private let columns = [GridItem(.adaptive(minimum: 106), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(categories) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(category.interests, id: \.self) { interest in
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
                                    .opacity(isEnabled(interest) ? 1 : 0.38)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isEnabled(interest))
                        }
                    }
                }
            }
        }
    }

    private func isSelected(_ interest: String) -> Bool {
        selectedInterests.contains(interest)
    }

    private func isEnabled(_ interest: String) -> Bool {
        isSelected(interest) || selectedInterests.count < maxSelectionCount
    }

    private func toggle(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            guard selectedInterests.count < maxSelectionCount else {
                return
            }
            selectedInterests.insert(interest)
        }
    }
}
