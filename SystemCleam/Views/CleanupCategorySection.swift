import SwiftUI

struct CleanupCategorySection: View {
    let category: CleanupCategory
    let items: [CleanupItem]
    let totalCleanableSpace: Int64
    @Binding var selectedItemIDs: Set<CleanupItem.ID>

    @State private var isExpanded = false

    private var totalSize: Int64 {
        items.map(\.size).reduce(0, +)
    }

    private var selectedCount: Int {
        items.filter { selectedItemIDs.contains($0.id) }.count
    }

    private var proportionOfTotal: Double {
        guard totalCleanableSpace > 0 else { return 0 }
        return Double(totalSize) / Double(totalCleanableSpace)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 9) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(category.color.opacity(0.16))
                        Image(systemName: category.icon)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(category.color)
                    }
                    .frame(width: 22, height: 22)

                    Text(category.title)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    SegmentedProgressBar(progress: proportionOfTotal, segmentCount: 10, tint: category.color)
                        .frame(width: 46)

                    Spacer(minLength: 6)

                    Text("\(selectedCount)/\(items.count)")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundStyle(AppColors.secondaryText)

                    Text(ByteCountFormatter.fileSize.string(fromByteCount: totalSize))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.secondaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        CleanupItemRow(
                            item: item,
                            isSelected: selectedItemIDs.contains(item.id),
                            toggleSelection: { toggle(item) }
                        )
                    }
                }
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func toggle(_ item: CleanupItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }
}
