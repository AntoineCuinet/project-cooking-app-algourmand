import Foundation

public final class LocalWeeklyPlanStorage: @unchecked Sendable {
    public static let shared = LocalWeeklyPlanStorage()

    private let fileManager: FileManager
    private let lock = NSLock()

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private func userDefaultsKey(for userId: UUID) -> String {
        "algourmand_persisted_weekly_plan_\(userId.uuidString)"
    }

    private func planFileURL(for userId: UUID) -> URL {
        let baseDirectory: URL
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            baseDirectory = appSupport.appendingPathComponent("Algourmand", isDirectory: true)
        } else {
            baseDirectory = fileManager.temporaryDirectory.appendingPathComponent("Algourmand", isDirectory: true)
        }

        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        return baseDirectory.appendingPathComponent("weekly_plan_\(userId.uuidString).json")
    }

    @discardableResult
    public func savePlan(_ plan: WeeklyPlan, for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(plan) else { return false }

        UserDefaults.standard.set(data, forKey: userDefaultsKey(for: userId))

        let url = planFileURL(for: userId)
        try? data.write(to: url, options: .atomic)
        return true
    }

    public func loadPlan(for userId: UUID) -> WeeklyPlan? {
        lock.lock()
        defer { lock.unlock() }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let url = planFileURL(for: userId)
        if let data = try? Data(contentsOf: url),
           let plan = try? decoder.decode(WeeklyPlan.self, from: data) {
            return plan
        }

        if let data = UserDefaults.standard.data(forKey: userDefaultsKey(for: userId)),
           let plan = try? decoder.decode(WeeklyPlan.self, from: data) {
            return plan
        }

        return nil
    }

    @discardableResult
    public func deletePlan(for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        UserDefaults.standard.removeObject(forKey: userDefaultsKey(for: userId))

        let url = planFileURL(for: userId)
        guard fileManager.fileExists(atPath: url.path) else { return true }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
