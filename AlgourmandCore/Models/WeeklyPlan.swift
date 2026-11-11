import Foundation

public struct WeeklyPlan: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let weekStartDate: Date
    public let meals: [PlannedMeal]
    public let totalBudget: Double

    public init(
        id: UUID = UUID(),
        weekStartDate: Date,
        meals: [PlannedMeal] = [],
        totalBudget: Double = 0.0
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.meals = meals
        self.totalBudget = totalBudget
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case weekStartDate = "week_start_date"
        case meals
        case totalBudget = "total_budget"
    }
}
