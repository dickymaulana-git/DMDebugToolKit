import SwiftUI

struct DeviceInfoView: View {
    private let info = DeviceInfo.current
    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            List {
                infoSection(
                    title: "Device",
                    icon: "iphone",
                    color: DebugUIStyle.accent,
                    rows: [
                        ("Model", info.model),
                        ("System", info.systemName),
                        ("System Version", info.systemVersion)
                    ]
                )

                infoSection(
                    title: "Display",
                    icon: "display",
                    color: DebugUIStyle.info,
                    rows: [
                        ("Screen Size", info.screenSize),
                        ("Screen Scale", info.screenScale)
                    ]
                )

                infoSection(
                    title: "Environment",
                    icon: "globe",
                    color: DebugUIStyle.success,
                    rows: [
                        ("Locale", info.locale),
                        ("Time Zone", info.timezone)
                    ]
                )

                infoSection(
                    title: "Application",
                    icon: "app",
                    color: DebugUIStyle.warning,
                    rows: [
                        ("Bundle ID", info.bundleIdentifier),
                        ("Version", info.appVersion),
                        ("Build", info.appBuild)
                    ]
                )
            }
            .listStyle(.plain)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton(action: onBack)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .overlay {
            Text("Device Info")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .allowsHitTesting(false)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Section

    private func infoSection(
        title: String,
        icon: String,
        color: Color,
        rows: [(String, String)]
    ) -> some View {
        Section {
            ForEach(rows.indices, id: \.self) { index in
                let row = rows[index]
                infoRow(title: row.0, value: row.1, index: index)
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)

                Text(title)
                    .font(DebugUIStyle.sectionTitle)
                    .foregroundStyle(.primary)
            }
            .textCase(nil)
        }
    }

    // MARK: - Info Row

    private func infoRow(title: String, value: String, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(DebugUIStyle.body)
                .foregroundStyle(.secondary)
                .frame(width: 105, alignment: .leading)

            Text(value)
                .font(DebugUIStyle.bodyMedium)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 5)
        .listRowBackground(DebugUIStyle.rowBackground(index: index))
    }
}

#if DEBUG
struct DeviceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DeviceInfoView(onBack: {})
                    .preferredColorScheme(.light)
            }
            .navigationViewStyle(.stack)
            .previewDisplayName("Device Info - Light")

            NavigationView {
                DeviceInfoView(onBack: {})
                    .preferredColorScheme(.dark)
            }
            .navigationViewStyle(.stack)
            .previewDisplayName("Device Info - Dark")
        }
    }
}
#endif
