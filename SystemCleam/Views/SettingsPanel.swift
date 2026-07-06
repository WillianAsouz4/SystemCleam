import SwiftUI

struct SettingsPanel: View {
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 42, height: 42)
                    .background(AppColors.accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Preferências")
                        .font(.headline)
                    Text("Comportamento do app")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle("Abrir no login", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .onChange(of: launchAtLogin) { _, newValue in
                    LaunchAtLoginManager.setEnabled(newValue)
                }
        }
        .padding(18)
    }
}
