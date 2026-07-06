import Foundation

enum CleanupScanner {
    nonisolated private static let largeFileLimit: Int64 = 500 * 1_024 * 1_024
    nonisolated private static let maxItemsPerCategory = 80

    nonisolated static func scanUserFolders() async -> CleanupScanResult {
        await Task.detached(priority: .userInitiated) {
            var items: [CleanupItem] = []
            var errors: [String] = []
            let installedApps = installedAppIdentifiers()

            scanCaches(into: &items, errors: &errors)
            scanLeftovers(into: &items, errors: &errors, installedApps: installedApps)
            scanLargeFiles(into: &items, errors: &errors)

            var seenPaths = Set<String>()
            let uniqueItems = items.filter { item in
                seenPaths.insert(item.url.path).inserted
            }

            return CleanupScanResult(items: uniqueItems, errors: errors)
        }.value
    }

    nonisolated static func moveToTrash(
        _ items: [CleanupItem],
        onProgress: @escaping @MainActor (CleanupItem) -> Void = { _ in }
    ) async -> TrashResult {
        await Task.detached(priority: .userInitiated) {
            var movedIDs = Set<CleanupItem.ID>()
            var failures: [String] = []

            for item in items {
                await onProgress(item)

                do {
                    var resultingURL: NSURL?
                    try FileManager.default.trashItem(at: item.url, resultingItemURL: &resultingURL)
                    movedIDs.insert(item.id)
                } catch {
                    failures.append("\(item.name): \(error.localizedDescription)")
                }
            }

            return TrashResult(movedIDs: movedIDs, failures: failures)
        }.value
    }

    nonisolated private static func scanCaches(into items: inout [CleanupItem], errors: inout [String]) {
        let cachesURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches", isDirectory: true)

        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: cachesURL,
                includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )

            for url in urls.prefix(maxItemsPerCategory) {
                if let ownIdentifier = Bundle.main.bundleIdentifier,
                   url.lastPathComponent.caseInsensitiveCompare(ownIdentifier) == .orderedSame {
                    continue
                }

                let size = folderSize(at: url)
                guard size > 0 else { continue }

                items.append(CleanupItem(
                    id: url.path,
                    url: url,
                    name: url.lastPathComponent,
                    category: .appCaches,
                    size: size,
                    modifiedDate: modifiedDate(at: url),
                    isSelectedByDefault: true
                ))
            }
        } catch {
            errors.append("Caches: \(error.localizedDescription)")
        }
    }

    nonisolated private static func scanLeftovers(
        into items: inout [CleanupItem],
        errors: inout [String],
        installedApps: InstalledApps
    ) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let relativePaths = [
            "Library/Application Support",
            "Library/Preferences",
            "Library/Containers",
            "Library/Saved Application State"
        ]

        for relativePath in relativePaths {
            let directoryURL = home.appendingPathComponent(relativePath, isDirectory: true)

            do {
                let urls = try FileManager.default.contentsOfDirectory(
                    at: directoryURL,
                    includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )

                for url in urls.prefix(200) {
                    guard isOrphanedAppLeftover(url, installedApps: installedApps) else { continue }

                    let size = folderSize(at: url)
                    guard size > 0 else { continue }

                    items.append(CleanupItem(
                        id: url.path,
                        url: url,
                        name: url.lastPathComponent,
                        category: .appLeftovers,
                        size: size,
                        modifiedDate: modifiedDate(at: url),
                        isSelectedByDefault: false
                    ))
                }
            } catch {
                errors.append("\(relativePath): \(error.localizedDescription)")
            }
        }
    }

    struct InstalledApps: Sendable {
        let bundleIdentifiers: Set<String>
    }

    nonisolated private static func installedAppIdentifiers() -> InstalledApps {
        var bundleIdentifiers = Set<String>()

        let searchDirectories = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications", isDirectory: true),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        ]

        for directory in searchDirectories {
            guard let enumerator = FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let appURL as URL in enumerator where appURL.pathExtension == "app" {
                if let identifier = Bundle(url: appURL)?.bundleIdentifier {
                    bundleIdentifiers.insert(identifier.lowercased())
                }
            }
        }

        return InstalledApps(bundleIdentifiers: bundleIdentifiers)
    }

    /// Only names shaped like a reverse-DNS bundle identifier (e.g. `com.vendor.app`)
    /// can be confidently tied to a specific app. Apple's own system/daemon data
    /// (`com.apple.*`) is excluded outright since it's never a "leftover" to trash,
    /// and generic tool/vendor folders (Homebrew, Steam, GeoServices...) are left
    /// alone since we can't tell whether they're still in use.
    nonisolated private static func isOrphanedAppLeftover(_ url: URL, installedApps: InstalledApps) -> Bool {
        var name = url.lastPathComponent
        for suffix in [".plist", ".savedState"] where name.hasSuffix(suffix) {
            name.removeLast(suffix.count)
            break
        }

        guard name.contains(".") else { return false }

        let identifier = name.lowercased()
        guard !identifier.hasPrefix("com.apple.") else { return false }

        if let ownIdentifier = Bundle.main.bundleIdentifier?.lowercased(), identifier == ownIdentifier {
            return false
        }

        return !installedApps.bundleIdentifiers.contains(identifier)
    }

    nonisolated private static func scanLargeFiles(into items: inout [CleanupItem], errors: inout [String]) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let searchFolders = ["Downloads", "Desktop", "Documents"]

        for folder in searchFolders {
            let folderURL = home.appendingPathComponent(folder, isDirectory: true)
            guard let enumerator = FileManager.default.enumerator(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
                errors.append("\(folder): não foi possível abrir a pasta.")
                continue
            }

            var categoryCount = 0
            for case let fileURL as URL in enumerator {
                guard categoryCount < maxItemsPerCategory else { break }

                do {
                    let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .contentModificationDateKey])
                    guard values.isRegularFile == true else { continue }

                    let size = Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
                    guard size >= largeFileLimit else { continue }

                    items.append(CleanupItem(
                        id: fileURL.path,
                        url: fileURL,
                        name: fileURL.lastPathComponent,
                        category: .largeFiles,
                        size: size,
                        modifiedDate: values.contentModificationDate,
                        isSelectedByDefault: true
                    ))
                    categoryCount += 1
                } catch {
                    errors.append("\(fileURL.lastPathComponent): \(error.localizedDescription)")
                }
            }
        }
    }

    nonisolated private static func folderSize(at url: URL) -> Int64 {
        if let directSize = fileSize(at: url) {
            return directSize
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return 0
        }

        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            size += fileSize(at: fileURL) ?? 0
        }

        return size
    }

    nonisolated private static func fileSize(at url: URL) -> Int64? {
        guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey]),
              values.isRegularFile == true else {
            return nil
        }

        // Use real space allocated on disk rather than the logical/apparent size,
        // since sparse files (e.g. VM disk images under com.apple.container) can
        // report a logical size far larger than the space they actually occupy.
        return Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
    }

    nonisolated private static func modifiedDate(at url: URL) -> Date? {
        let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
        return values?.contentModificationDate
    }
}
