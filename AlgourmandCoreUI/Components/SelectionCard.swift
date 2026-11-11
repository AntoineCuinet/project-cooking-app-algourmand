import SwiftUI

public struct SelectionCard: View {
    public let title: String
    public let description: String?
    public let systemImage: String?
    public let isSelected: Bool
    public let action: () -> Void

    public init(
        title: String,
        description: String? = nil,
        systemImage: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let systemImage {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.algourmandPrimary : Color.algourmandPrimary.opacity(0.12))
                            .frame(width: 42, height: 42)

                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.algourmandPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.algourmandText)

                    if let description, !description.isEmpty {
                        Text(description)
                            .font(.caption2)
                            .foregroundStyle(Color.algourmandText.opacity(0.7))
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        isSelected ? Color.algourmandPrimary : Color.algourmandText.opacity(0.3)
                    )
            }
            .padding(14)
            .background(
                isSelected ?
                Color.algourmandPrimary.opacity(0.08) :
                Color(uiColor: .tertiarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.algourmandPrimary : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        SelectionCard(
            title: "Option avec image et description",
            description: "Ceci est une description détaillée de l'option.",
            systemImage: "flame.fill",
            isSelected: true
        ) {}

        SelectionCard(
            title: "Option simple sans image",
            description: "Description courte sans icône",
            isSelected: false
        ) {}

        SelectionCard(
            title: "Titre seul",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.algourmandBackground)
}
