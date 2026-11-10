import Foundation

public struct Recipe: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let category: String
    public let prepTimeMinutes: Int

    public init(id: Int, title: String, category: String, prepTimeMinutes: Int) {
        self.id = id
        self.title = title
        self.category = category
        self.prepTimeMinutes = prepTimeMinutes
    }
}
