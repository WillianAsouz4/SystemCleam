import Foundation

struct CleanupItem: Identifiable, Hashable, Sendable {
    let id: String
    let url: URL
    let name: String
    let category: CleanupCategory
    let size: Int64
    let modifiedDate: Date?
    let isSelectedByDefault: Bool

    var formattedSize: String {
        ByteCountFormatter.fileSize.string(fromByteCount: size)
    }

    var shortPath: String {
        url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

enum CleanupCategory: CaseIterable, Hashable, Sendable {
    case appCaches
    case appLeftovers
    case largeFiles

    var title: String {
        switch self {
        case .appCaches:
            return "Caches de apps"
        case .appLeftovers:
            return "Sobras de apps apagados"
        case .largeFiles:
            return "Arquivos grandes"
        }
    }

    var icon: String {
        switch self {
        case .appCaches:
            return "tray.full"
        case .appLeftovers:
            return "shippingbox"
        case .largeFiles:
            return "doc.text.magnifyingglass"
        }
    }
}

struct CleanupScanResult: Sendable {
    let items: [CleanupItem]
    let errors: [String]
}

struct TrashResult: Sendable {
    let movedIDs: Set<CleanupItem.ID>
    let failures: [String]
}
