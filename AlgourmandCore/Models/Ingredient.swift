import Foundation

public struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let quantity: Double
    public let unit: String

    public init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case unit
    }
}
