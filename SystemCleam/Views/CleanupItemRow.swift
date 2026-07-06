import SwiftUI

struct CleanupItemRow: View {
    let item: CleanupItem
    let isSelected: Bool
    let toggleSelection: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            checkbox

            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)

                Text(item.shortPath)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            Text(item.formattedSize)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture(perform: toggleSelection)
        .overlay(alignment: .top) {
            Rectangle().fill(AppColors.hairline).frame(height: 1)
        }
    }

    private var checkbox: some View {
        Circle()
            .fill(isSelected ? AppColors.accent : Color.clear)
            .overlay(
                Circle().strokeBorder(isSelected ? Color.clear : AppColors.secondaryText, lineWidth: 1.5)
            )
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 15, height: 15)
    }
}
