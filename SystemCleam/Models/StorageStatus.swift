import Foundation
import SwiftUI

struct StorageStatus: Equatable {
    let totalCapacity: Int64
    let freeCapacity: Int64

    var usedCapacity: Int64 {
        max(totalCapacity - freeCapacity, 0)
    }

    var usedRatio: Double {
        guard totalCapacity > 0 else { return 0 }
        return min(max(Double(usedCapacity) / Double(totalCapacity), 0), 1)
    }

    var formattedUsed: String {
        Self.formatBytes(usedCapacity)
    }

    var formattedFree: String {
        Self.formatBytes(freeCapacity)
    }

    var formattedTotal: String {
        Self.formatBytes(totalCapacity)
    }

    var formattedUsedPercentage: String {
        usedRatio.formatted(.percent.precision(.fractionLength(0)))
    }

    var tint: Color {
        usedRatio > 0.85 ? .red : .teal
    }

    static func current() -> StorageStatus {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser

        // volumeAvailableCapacityForImportantUsage accounts for purgeable space
        // (local Time Machine snapshots, reclaimable iCloud caches, etc.) the same
        // way System Settings > Storage does, unlike the raw block count from
        // attributesOfFileSystem(forPath:), which reports "used" space several
        // gigabytes higher than what the user sees in System Settings.
        guard let values = try? homeURL.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ]) else {
            return StorageStatus(totalCapacity: 0, freeCapacity: 0)
        }

        return StorageStatus(
            totalCapacity: Int64(values.volumeTotalCapacity ?? 0),
            freeCapacity: values.volumeAvailableCapacityForImportantUsage ?? 0
        )
    }

    private static func formatBytes(_ value: Int64) -> String {
        ByteCountFormatter.fileSize.string(fromByteCount: value)
    }
}

extension ByteCountFormatter {
    static let fileSize: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useMB, .useGB, .useTB]
        formatter.includesUnit = true
        formatter.includesCount = true
        return formatter
    }()
}
