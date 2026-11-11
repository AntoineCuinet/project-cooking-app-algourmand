import Foundation

public final class LocalWeeklyPreferencesStorage: @unchecked Sendable {
    public static let shared = LocalWeeklyPreferencesStorage()

    private let fileManager: FileManager
    private let lock = NSLock()

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private func userDefaultsKey(for userId: UUID) -> String {
        "algourmand_persisted_weekly_prefs_\(userId.uuidString)"
    }

    private func preferencesFileURL(for userId: UUID) -> URL {
        let baseDirectory: URL
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            baseDirectory = appSupport.appendingPathComponent("Algourmand", isDirectory: true)
        } else {
            baseDirectory = fileManager.temporaryDirectory.appendingPathComponent("Algourmand", isDirectory: true)
        }

        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        return baseDirectory.appendingPathComponent("weekly_preferences_\(userId.uuidString).json")
    }

    @discardableResult
    public func savePreferences(_ preferences: WeeklyPreferences, for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard let data = try? JSONEncoder().encode(preferences) else { return false }

        UserDefaults.standard.set(data, forKey: userDefaultsKey(for: userId))

        let url = preferencesFileURL(for: userId)
        try? data.write(to: url, options: .atomic)
        return true
    }

    public func loadPreferences(for userId: UUID) -> WeeklyPreferences? {
        lock.lock()
        defer { lock.unlock() }

        let url = preferencesFileURL(for: userId)
        if let data = try? Data(contentsOf: url),
           let prefs = try? JSONDecoder().decode(WeeklyPreferences.self, from: data) {
            return prefs
        }

        if let data = UserDefaults.standard.data(forKey: userDefaultsKey(for: userId)),
           let prefs = try? JSONDecoder().decode(WeeklyPreferences.self, from: data) {
            return prefs
        }

        return nil
    }

    @discardableResult
    public func deletePreferences(for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        UserDefaults.standard.removeObject(forKey: userDefaultsKey(for: userId))

        let url = preferencesFileURL(for: userId)
        guard fileManager.fileExists(atPath: url.path) else { return true }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
