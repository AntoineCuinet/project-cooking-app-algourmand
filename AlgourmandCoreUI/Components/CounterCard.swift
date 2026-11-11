import SwiftUI

public struct CounterCard: View {
    public let title: String
    public let subtitle: String?
    public let valueText: String
    public let systemImage: String?
    public let canDecrement: Bool
    public let canIncrement: Bool
    public let onDecrement: () -> Void
    public let onIncrement: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        valueText: String,
        systemImage: String? = nil,
        canDecrement: Bool = true,
        canIncrement: Bool = true,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.valueText = valueText
        self.systemImage = systemImage
        self.canDecrement = canDecrement
        self.canIncrement = canIncrement
        self.onDecrement = onDecrement
        self.onIncrement = onIncrement
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let systemImage {
                ZStack {
                    Circle()
                        .fill(Color.algourmandPrimary.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.algourmandPrimary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.algourmandText)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color.algourmandText.opacity(0.65))
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(canDecrement ? Color.algourmandText : Color.algourmandText.opacity(0.25))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(Circle())
                }
                .disabled(!canDecrement)

                Text(valueText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.algourmandText)
                    .frame(minWidth: 32)
                    .multilineTextAlignment(.center)

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(canIncrement ? Color.algourmandText : Color.algourmandText.opacity(0.25))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(Circle())
                }
                .disabled(!canIncrement)
            }
        }
        .padding(14)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    CounterCard(
        title: "Personnes au foyer",
        subtitle: "Nombre de convives habituels",
        valueText: "3",
        systemImage: "person.2.fill",
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
    .background(Color.algourmandBackground)
}
