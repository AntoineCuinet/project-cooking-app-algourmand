import SwiftUI

public struct SelectableTag: View {
    public let title: String
    public let isSelected: Bool
    public let systemImage: String?
    public let action: () -> Void

    public init(
        title: String,
        isSelected: Bool,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                Color.algourmandPrimary :
                Color(uiColor: .tertiarySystemGroupedBackground)
            )
            .foregroundStyle(isSelected ? Color.white : Color.algourmandText)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.algourmandText.opacity(0.12),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        SelectableTag(title: "Italienne", isSelected: true) {}
        SelectableTag(title: "Asiatique", isSelected: false, systemImage: "fork.knife") {}
    }
    .padding()
    .background(Color.algourmandBackground)
}
