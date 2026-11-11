import Foundation

public final class LocalUserStorage: @unchecked Sendable {
    public static let shared = LocalUserStorage()

    private let fileManager: FileManager
    private let lock = NSLock()

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private var currentUserURL: URL {
        let baseDirectory: URL
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            baseDirectory = appSupport.appendingPathComponent("Algourmand", isDirectory: true)
        } else {
            baseDirectory = fileManager.temporaryDirectory.appendingPathComponent("Algourmand", isDirectory: true)
        }

        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        return baseDirectory.appendingPathComponent("current_user.json")
    }

    @discardableResult
    public func saveCurrentUser(_ user: UserDTO) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        do {
            let data = try JSONEncoder().encode(user)
            try data.write(to: currentUserURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    public func loadCurrentUser() -> UserDTO? {
        lock.lock()
        defer { lock.unlock() }

        guard let data = try? Data(contentsOf: currentUserURL) else { return nil }
        return try? JSONDecoder().decode(UserDTO.self, from: data)
    }

    @discardableResult
    public func clearCurrentUser() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard fileManager.fileExists(atPath: currentUserURL.path) else { return true }
        do {
            try fileManager.removeItem(at: currentUserURL)
            return true
        } catch {
            return false
        }
    }
}
