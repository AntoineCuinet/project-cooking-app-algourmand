import Foundation

public final class LocalProfileStorage: @unchecked Sendable {
    public static let shared = LocalProfileStorage()

    private let fileManager: FileManager
    private let lock = NSLock()

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private func profileFileURL(for userId: UUID) -> URL {
        let baseDirectory: URL
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            baseDirectory = appSupport.appendingPathComponent("Algourmand", isDirectory: true)
        } else {
            baseDirectory = fileManager.temporaryDirectory.appendingPathComponent("Algourmand", isDirectory: true)
        }

        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        return baseDirectory.appendingPathComponent("profile_\(userId.uuidString).json")
    }

    @discardableResult
    public func saveProfile(_ profile: UserProfile, for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        do {
            let data = try JSONEncoder().encode(profile)
            let url = profileFileURL(for: userId)
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    public func loadProfile(for userId: UUID) -> UserProfile? {
        lock.lock()
        defer { lock.unlock() }

        let url = profileFileURL(for: userId)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    @discardableResult
    public func deleteProfile(for userId: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let url = profileFileURL(for: userId)
        guard fileManager.fileExists(atPath: url.path) else { return true }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
