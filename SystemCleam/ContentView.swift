import SwiftUI
import Foundation

struct ContentView: View {
    @State private var cleanupItems: [CleanupItem] = []
    @State private var selectedItemIDs: Set<CleanupItem.ID> = []
    @State private var isScanning = false
    @State private var isCleaning = false
    @State private var lastScanDate: Date?
    @State private var storageStatus = StorageStatus.current()
    @State private var isStorageStatusPresented = false
    @State private var isSettingsPresented = false
    @State private var isTrashConfirmationPresented = false
    @State private var cleaningProgress: (current: Int, total: Int, itemName: String)?
    @State private var scanMessage: String?
    @State private var cleanupMessage: String?

    private var selectedItems: [CleanupItem] {
        cleanupItems.filter { selectedItemIDs.contains($0.id) }
    }

    private var selectedSpace: Int64 {
        selectedItems.map(\.size).reduce(0, +)
    }

    private var totalCleanableSpace: Int64 {
        cleanupItems.map(\.size).reduce(0, +)
    }

    private var storageUsedRatio: Double {
        storageStatus.usedRatio
    }

    private var groupedItems: [(CleanupCategory, [CleanupItem])] {
        CleanupCategory.allCases.compactMap { category in
            let matches = cleanupItems.filter { $0.category == category }
            return matches.isEmpty ? nil : (category, matches)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 8) {
                    overviewCard

                    if cleanupItems.isEmpty && !isScanning {
                        emptyStateCard
                    } else {
                        if !cleanupItems.isEmpty {
                            foundLine
                        }

                        ForEach(groupedItems, id: \.0) { category, items in
                            CleanupCategorySection(
                                category: category,
                                items: items,
                                totalCleanableSpace: totalCleanableSpace,
                                selectedItemIDs: $selectedItemIDs
                            )
                        }

                        actionCard
                    }

                    safetyCard
                }
                .padding(12)
            }
        }
        .background(AppColors.panelBackground)
        .onAppear {
            refreshStorageStatus()
            if cleanupItems.isEmpty {
                runScan()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.accent)

            Text("Limpeza do Sistema")
                .font(.system(size: 13, weight: .semibold))

            Spacer()

            Button {
                refreshStorageStatus()
                isStorageStatusPresented = true
            } label: {
                Image(systemName: "internaldrive")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColors.secondaryText)
            .popover(isPresented: $isStorageStatusPresented) {
                StorageStatusPanel(status: storageStatus)
                    .frame(minWidth: 260)
            }

            Button(action: runScan) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColors.secondaryText)
            .disabled(isScanning || isCleaning)

            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColors.secondaryText)
            .popover(isPresented: $isSettingsPresented) {
                SettingsPanel()
                    .frame(minWidth: 240)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Rectangle().fill(AppColors.hairline).frame(height: 1)
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(storageStatus.formattedUsedPercentage + " usado")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                Text("\(storageStatus.formattedUsed) / \(storageStatus.formattedTotal)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(AppColors.secondaryText)
            }

            if isScanning {
                ProgressView("Verificando…")
                    .progressViewStyle(.linear)
                    .controlSize(.small)
            } else {
                SegmentedProgressBar(progress: storageUsedRatio, tint: storageTint)
            }

            HStack {
                Text("\(storageStatus.formattedFree) livres")
                Spacer()
                Text(lastScanText)
            }
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(AppColors.secondaryText)

            if let scanMessage {
                Label(scanMessage, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
            }

            if let cleanupMessage {
                Label(cleanupMessage, systemImage: "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var foundLine: some View {
        HStack(alignment: .firstTextBaseline) {
            HStack(spacing: 4) {
                Text("Encontrado")
                    .font(.system(size: 13, weight: .semibold))
                Text(ByteCountFormatter.fileSize.string(fromByteCount: totalCleanableSpace))
                    .font(.system(size: 13, weight: .bold))
            }

            Spacer()

            Text("selecionado \(ByteCountFormatter.fileSize.string(fromByteCount: selectedSpace))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.horizontal, 4)
    }

    private var emptyStateCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22))
                .foregroundStyle(AppColors.secondaryText)

            Text("Nenhum item listado")
                .font(.system(size: 13, weight: .semibold))

            Text("Clique em Verificar para procurar caches, sobras de apps e arquivos grandes.")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let cleaningProgress {
                HStack(spacing: 8) {
                    SegmentedProgressBar(
                        progress: Double(cleaningProgress.current) / Double(max(cleaningProgress.total, 1)),
                        tint: AppColors.danger
                    )

                    Text("\(cleaningProgress.current)/\(cleaningProgress.total)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(AppColors.secondaryText)
                }

                Text("Movendo: \(cleaningProgress.itemName)…")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            } else if isTrashConfirmationPresented {
                Text("Mover \(selectedItems.count) itens para a Lixeira?")
                    .font(.system(size: 12.5, weight: .semibold))

                Text("Libera até \(ByteCountFormatter.fileSize.string(fromByteCount: selectedSpace)).")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.secondaryText)

                HStack {
                    Spacer()

                    Button("Cancelar") {
                        isTrashConfirmationPresented = false
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .padding(.horizontal, 4)

                    Button("Mover para a Lixeira") {
                        isTrashConfirmationPresented = false
                        moveSelectedItemsToTrash()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.danger)
                    .font(.system(size: 12))
                }
            } else {
                HStack {
                    HStack(spacing: 4) {
                        Text("Selecionado")
                            .foregroundStyle(AppColors.secondaryText)
                        Text(ByteCountFormatter.fileSize.string(fromByteCount: selectedSpace))
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    Button {
                        isTrashConfirmationPresented = true
                    } label: {
                        Label("Mover p/ Lixeira", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.danger)
                    .font(.system(size: 12))
                    .disabled(selectedItemIDs.isEmpty || isScanning || isCleaning)
                }
            }
        }
        .font(.system(size: 12))
        .padding(12)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var safetyCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield")
                .foregroundStyle(AppColors.accent)

            Text("Escaneia só pastas do usuário · move para a Lixeira, nunca apaga direto.")
                .font(.system(size: 10.5))
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var storageTint: Color {
        storageUsedRatio > 0.85 ? AppColors.danger : AppColors.accent
    }

    private var lastScanText: String {
        guard let lastScanDate else {
            return "sem verificação"
        }

        return "verificado às \(lastScanDate.formatted(date: .omitted, time: .shortened))"
    }

    private func runScan() {
        isScanning = true
        scanMessage = nil
        cleanupMessage = nil

        Task {
            let result = await CleanupScanner.scanUserFolders()

            await MainActor.run {
                cleanupItems = result.items.sorted { $0.size > $1.size }
                selectedItemIDs = Set(cleanupItems.filter(\.isSelectedByDefault).map(\.id))
                scanMessage = result.errors.isEmpty ? nil : "Alguns locais não puderam ser lidos: \(result.errors.count)."
                lastScanDate = Date()
                refreshStorageStatus()
                isScanning = false
            }
        }
    }

    private func moveSelectedItemsToTrash() {
        let itemsToTrash = selectedItems
        guard !itemsToTrash.isEmpty else { return }

        isCleaning = true
        cleanupMessage = nil
        let total = itemsToTrash.count
        cleaningProgress = (0, total, "")

        Task {
            let result = await CleanupScanner.moveToTrash(itemsToTrash) { item in
                let next = (cleaningProgress?.current ?? 0) + 1
                cleaningProgress = (next, total, item.name)
            }

            await MainActor.run {
                cleanupItems.removeAll { result.movedIDs.contains($0.id) }
                selectedItemIDs.subtract(result.movedIDs)
                cleanupMessage = result.failures.isEmpty
                    ? "\(result.movedIDs.count) itens movidos para a Lixeira."
                    : "\(result.movedIDs.count) itens movidos; \(result.failures.count) falharam."
                refreshStorageStatus()
                isCleaning = false
                cleaningProgress = nil
            }
        }
    }

    private func refreshStorageStatus() {
        storageStatus = StorageStatus.current()
    }
}

#Preview {
    ContentView()
        .frame(width: 380, height: 560)
}
