import SwiftUI

struct StorageStatusPanel: View {
    let status: StorageStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "internaldrive")
                    .font(.title2)
                    .foregroundStyle(status.tint)
                    .frame(width: 42, height: 42)
                    .background(status.tint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Estado do armazenamento")
                        .font(.headline)
                    Text(status.formattedUsedPercentage + " usado")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: status.usedRatio)
                .tint(status.tint)
                .accessibilityLabel("Uso de armazenamento")

            VStack(spacing: 10) {
                StorageMetricRow(title: "Usado", value: status.formattedUsed, icon: "externaldrive.fill")
                StorageMetricRow(title: "Livre", value: status.formattedFree, icon: "checkmark.circle")
                StorageMetricRow(title: "Total", value: status.formattedTotal, icon: "sum")
            }
        }
        .padding(18)
    }
}

struct StorageMetricRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}
