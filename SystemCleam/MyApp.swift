import SwiftUI
import AppKit

@main struct MyApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
        } label: {
            Label("Limpeza", systemImage: "sparkles")
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            ContentView()
                .frame(width: 380, height: 560)

            Rectangle()
                .fill(AppColors.hairline)
                .frame(height: 1)

            HStack {
                Text("Limpador seguro")
                    .font(.system(size: 10.5))
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()

                Button("Sair", systemImage: "power") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(AppColors.panelBackground)
        }
    }
}
